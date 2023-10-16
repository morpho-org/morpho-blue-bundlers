import { AbiCoder, MaxUint256, Signature, keccak256, toBigInt, AddressLike, Contract, TypedDataEncoder } from "ethers";
import hre from "hardhat";
import _range from "lodash/range";
import { ERC20Mock, EthereumBundler, MorphoMock, OracleMock } from "types";
import { SpeedJumpIrm } from "types/@bundlers/morpho-blue-irm/src/SpeedJumpIrm";
import { MarketParamsStruct } from "types/@bundlers/morpho-blue/src/Morpho";
import { AuthorizationStruct } from "types/@bundlers/morpho-blue/src/interfaces/IMorpho";

import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import {
  increaseTo,
  latest,
  setNextBlockTimestamp,
} from "@nomicfoundation/hardhat-network-helpers/dist/src/helpers/time";

// Without the division it overflows.
const initBalance = MaxUint256 / 10000000000000000n;
const oraclePriceScale = 1000000000000000000000000000000000000n;

const LN2 = 693147180560000000n;
const TARGET_UTILIZATION = 800000000000000000n;
const SPEED_FACTOR = 277777777777n;
const INITIAL_RATE = 317097919n;

const MAX_UINT48 = 281474976710655n;

let seed = 42;
const random = () => {
  seed = (seed * 16807) % 2147483647;

  return (seed - 1) / 2147483646;
};

const identifier = (marketParams: MarketParamsStruct) => {
  const encodedMarket = AbiCoder.defaultAbiCoder().encode(
    ["address", "address", "address", "address", "uint256"],
    Object.values(marketParams),
  );

  return Buffer.from(keccak256(encodedMarket).slice(2), "hex");
};

const logProgress = (name: string, i: number, max: number) => {
  if (i % 10 == 0) console.log("[" + name + "]", Math.floor((100 * i) / max), "%");
};

const forwardTimestamp = async (elapsed: number) => {
  const timestamp = await latest();
  const newTimestamp = timestamp + elapsed;

  await increaseTo(newTimestamp);
  await setNextBlockTimestamp(newTimestamp);
};

const randomForwardTimestamp = async () => {
  const elapsed = random() < 1 / 2 ? 0 : (1 + Math.floor(random() * 100)) * 12; // 50% of the time, don't go forward in time.

  await forwardTimestamp(elapsed);
};

describe("EthereumBundler", () => {
  let admin: SignerWithAddress;
  let riskManager: SignerWithAddress;
  let allocator: SignerWithAddress;
  let suppliers: SignerWithAddress[];
  let borrowers: SignerWithAddress[];

  let morpho: MorphoMock;
  let loan: ERC20Mock;
  let collateral: ERC20Mock;
  let oracle: OracleMock;
  let irm: SpeedJumpIrm;

  let bundler: EthereumBundler;
  let bundlerAddress: string;

  let marketParams: MarketParamsStruct;
  let id: Buffer;

  let authorization: AuthorizationStruct;

  const updateMarket = (newMarket: Partial<MarketParamsStruct>) => {
    marketParams = { ...marketParams, ...newMarket };
    id = identifier(marketParams);
  };

  const updateAuthorization = (newAthorization: Partial<AuthorizationStruct>) => {
    authorization = { ...authorization, ...newAthorization };
  };

  const Permit2Domain = {
    name: "Permit2",
    chainId: "0x1",
    verifyingContract: "0x000000000022D473030F116dDEE9F6B43aC78BA3",
  };

  const Permit2Types = {
    PermitTransferFrom: [
      {
        name: "permitted",
        type: "TokenPermissions",
      },
      {
        name: "nonce",
        type: "uint256",
      },
      {
        name: "deadline",
        type: "uint256",
      },
    ],
    TokenPermissions: [
      {
        name: "token",
        type: "address",
      },
      {
        name: "amount",
        type: "uint256",
      },
    ],
  };

  const MorphoAuthorizationTypes = {
    Authorization: [
      {
        name: "authorizer",
        type: "address",
      },
      {
        name: "authorized",
        type: "address",
      },
      {
        name: "isAuthorized",
        type: "bool",
      },
      {
        name: "nonce",
        type: "uint256",
      },
      {
        name: "deadline",
        type: "uint256",
      },
    ],
  };

  beforeEach(async () => {
    const allSigners = await hre.ethers.getSigners();

    const users = allSigners.slice(0, -3);

    [admin, riskManager, allocator] = allSigners.slice(-3);
    suppliers = users.slice(0, users.length / 2);
    borrowers = users.slice(users.length / 2);

    const ERC20MockFactory = await hre.ethers.getContractFactory("ERC20Mock", admin);

    loan = await ERC20MockFactory.deploy("DAI", "DAI");
    collateral = await ERC20MockFactory.deploy("Wrapped BTC", "WBTC");

    const OracleMockFactory = await hre.ethers.getContractFactory("OracleMock", admin);

    oracle = await OracleMockFactory.deploy();

    await oracle.setPrice(oraclePriceScale);

    const MorphoFactory = await hre.ethers.getContractFactory("MorphoMock", admin);

    morpho = await MorphoFactory.deploy(admin.address);

    const morphoAddress = await morpho.getAddress();

    const SpeedJumpIrmFactory = await hre.ethers.getContractFactory("SpeedJumpIrm", admin);

    irm = await SpeedJumpIrmFactory.deploy(morphoAddress, LN2, TARGET_UTILIZATION, SPEED_FACTOR, INITIAL_RATE);

    const loanAddress = await loan.getAddress();
    const collateralAddress = await collateral.getAddress();
    const oracleAddress = await oracle.getAddress();
    const irmAddress = await irm.getAddress();

    updateMarket({
      loanToken: loanAddress,
      collateralToken: collateralAddress,
      oracle: oracleAddress,
      irm: irmAddress,
      lltv: BigInt.WAD / 2n + 1n,
    });

    await morpho.enableIrm(irmAddress);
    await morpho.enableLltv(marketParams.lltv);
    await morpho.createMarket(marketParams);

    const EthereumBundlerFactory = await hre.ethers.getContractFactory("EthereumBundler", admin);

    bundler = await EthereumBundlerFactory.deploy(morphoAddress);

    bundlerAddress = await bundler.getAddress();

    for (const user of users) {
      await loan.setBalance(user.address, initBalance);
      await loan.connect(user).approve(bundlerAddress, MaxUint256);
      await loan.connect(user).approve(morphoAddress, MaxUint256);
      await collateral.setBalance(user.address, initBalance);
      await collateral.connect(user).approve(morphoAddress, MaxUint256);
      // await collateral.connect(user).approve(bundlerAddress, MaxUint256);
    }

    await forwardTimestamp(1);

    hre.tracer.nameTags[morphoAddress] = "Morpho";
    hre.tracer.nameTags[collateralAddress] = "Collateral";
    hre.tracer.nameTags[loanAddress] = "Loan";
    hre.tracer.nameTags[oracleAddress] = "Oracle";
    hre.tracer.nameTags[irmAddress] = "SpeedJumpIrm";
    hre.tracer.nameTags[bundlerAddress] = "EthereumBundler";
  });

  it("should simulate gas cost [supplyCollateral + Borrow]", async () => {
    for (let i = 0; i < suppliers.length; ++i) {
      logProgress("supplyCollateral + Borrow", i, suppliers.length);

      const supplier = suppliers[i];

      let assets = BigInt.WAD * toBigInt(1 + Math.floor(random() * 100));

      await morpho.connect(supplier).supply(marketParams, assets, 0, supplier.address, "0x");

      const borrower = borrowers[i];

      let collateralAddress = await collateral.getAddress();

      await collateral.connect(borrower).approve("0x000000000022D473030F116dDEE9F6B43aC78BA3", MaxUint256);

      updateAuthorization({
        authorizer: borrower.address,
        authorized: bundlerAddress,
        isAuthorized: true,
        nonce: 0n,
        deadline: MAX_UINT48,
      });

      let MorphoAuthorizationDomain = { chainId: "0x1", verifyingContract: await morpho.getAddress() };

      let MorphoSignature = Signature.from(
        await borrower.signTypedData(MorphoAuthorizationDomain, MorphoAuthorizationTypes, authorization),
      );

      let morphoSetAuthorizationWithSigCall = bundler.interface.encodeFunctionData("morphoSetAuthorizationWithSig", [
        authorization,
        MorphoSignature,
        false,
      ]);

      let Permit2Message = {
        permitted: {
          token: collateralAddress,
          amount: assets,
        },
        nonce: 0n,
        deadline: MAX_UINT48,
      };

      let permit2Signature = Signature.from(await borrower.signTypedData(Permit2Domain, Permit2Types, Permit2Message));

      console.log("message", TypedDataEncoder.getPayload(Permit2Domain, Permit2Types, Permit2Message));

      let permit2TransferFromCall = bundler.interface.encodeFunctionData("permit2TransferFrom", [
        Permit2Message,
        permit2Signature.serialized,
      ]);

      let transferFromCall = bundler.interface.encodeFunctionData("erc20TransferFrom", [collateralAddress, assets]);

      let supplyCollateralCall = bundler.interface.encodeFunctionData("morphoSupplyCollateral", [
        marketParams,
        assets,
        borrower.address,
        "0x",
      ]);

      let borrowCall = bundler.interface.encodeFunctionData("morphoBorrow", [
        marketParams,
        assets / 2n,
        0,
        borrower.address,
      ]);

      // const permit2 = new Contract("0x000000000022D473030F116dDEE9F6B43aC78BA3", abi, borrower);

      // let returnValues = await permit2.allowance(borrower.address, collateralAddress, bundlerAddress);

      // console.log(returnValues[2], "nonce");

      await bundler
        .connect(borrower)
        .multicall([morphoSetAuthorizationWithSigCall, permit2TransferFromCall, supplyCollateralCall, borrowCall]);
    }
  });
});
