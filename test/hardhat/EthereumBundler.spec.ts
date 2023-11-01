import { AbiCoder, MaxUint256, Signature, keccak256, toBigInt, TypedDataDomain, TypedDataField } from "ethers";
import hre from "hardhat";
import { BundlerAction } from "pkg";
import { ERC20Mock, ERC4626Mock, EthereumBundler, MorphoMock, OracleMock, SpeedJumpIrmMock } from "types";
import { MarketParamsStruct } from "types/lib/morpho-blue/src/Morpho";

import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import {
  increaseTo,
  latest,
  setNextBlockTimestamp,
} from "@nomicfoundation/hardhat-network-helpers/dist/src/helpers/time";

interface TypedDataConfig {
  domain: TypedDataDomain;
  types: Record<string, TypedDataField[]>;
}

const permit2Address = "0x000000000022D473030F116dDEE9F6B43aC78BA3";

const permit2Config: TypedDataConfig = {
  domain: {
    name: "Permit2",
    chainId: "0x1",
    verifyingContract: permit2Address,
  },
  types: {
    PermitTransferFrom: [
      {
        name: "permitted",
        type: "TokenPermissions",
      },
      {
        name: "spender",
        type: "address",
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
  },
};

const morphoAuthorizationTypes: TypedDataConfig["types"] = {
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

// Without the division it overflows.
const initBalance = MaxUint256 / 10000000000000000n;
const oraclePriceScale = 1000000000000000000000000000000000000n;

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
  let suppliers: SignerWithAddress[];
  let borrowers: SignerWithAddress[];

  let morpho: MorphoMock;
  let loan: ERC20Mock;
  let collateral: ERC20Mock;
  let oracle: OracleMock;
  let irm: SpeedJumpIrmMock;

  let morphoAuthorizationConfig: TypedDataConfig;

  let erc4626: ERC4626Mock;
  let erc4626Address: string;

  let bundler: EthereumBundler;
  let bundlerAddress: string;

  let marketParams: MarketParamsStruct;
  let id: Buffer;

  const updateMarket = (newMarket: Partial<MarketParamsStruct>) => {
    marketParams = { ...marketParams, ...newMarket };
    id = identifier(marketParams);
  };

  beforeEach(async () => {
    const allSigners = await hre.ethers.getSigners();

    const users = allSigners.slice(0, -3);

    [admin] = allSigners.slice(-1);
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

    const SpeedJumpIrmFactory = await hre.ethers.getContractFactory("SpeedJumpIrmMock", admin);

    irm = await SpeedJumpIrmFactory.deploy(morphoAddress);

    morphoAuthorizationConfig = {
      domain: { chainId: "0x1", verifyingContract: morphoAddress },
      types: morphoAuthorizationTypes,
    };

    const ERC4626MockFactory = await hre.ethers.getContractFactory("ERC4626Mock", admin);

    const collateralAddress = await collateral.getAddress();

    erc4626 = await ERC4626MockFactory.deploy(collateralAddress, "MetaMorpho", "MM");

    erc4626Address = await erc4626.getAddress();

    const loanAddress = await loan.getAddress();
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
      await loan.connect(user).approve(morphoAddress, MaxUint256);
      await collateral.setBalance(user.address, initBalance);
      await collateral.connect(user).approve(morphoAddress, MaxUint256);
    }

    await forwardTimestamp(1);

    hre.tracer.nameTags[morphoAddress] = "Morpho";
    hre.tracer.nameTags[collateralAddress] = "Collateral";
    hre.tracer.nameTags[loanAddress] = "Loan";
    hre.tracer.nameTags[oracleAddress] = "Oracle";
    hre.tracer.nameTags[irmAddress] = "SpeedJumpIrm";
    hre.tracer.nameTags[bundlerAddress] = "EthereumBundler";
  });

  it("should simulate gas cost [morpho-supplyCollateral+borrow]", async () => {
    for (let i = 0; i < suppliers.length; ++i) {
      logProgress("supplyCollateral+borrow", i, suppliers.length);

      const supplier = suppliers[i];

      const assets = BigInt.WAD * toBigInt(1 + Math.floor(random() * 100));

      await morpho.connect(supplier).supply(marketParams, assets, 0, supplier.address, "0x");

      const borrower = borrowers[i];

      const authorization = {
        authorizer: borrower.address,
        authorized: bundlerAddress,
        isAuthorized: true,
        nonce: 0n,
        deadline: MAX_UINT48,
      };

      const permit2TransferFrom = {
        permitted: {
          token: await collateral.getAddress(),
          amount: assets,
        },
        spender: bundlerAddress,
        nonce: 0n,
        deadline: MAX_UINT48,
      };

      await collateral.connect(borrower).approve(permit2Address, MaxUint256);

      await randomForwardTimestamp();

      await bundler
        .connect(borrower)
        .multicall([
          BundlerAction.morphoSetAuthorizationWithSig(
            authorization,
            Signature.from(
              await borrower.signTypedData(
                morphoAuthorizationConfig.domain,
                morphoAuthorizationConfig.types,
                authorization,
              ),
            ),
            false,
          ),
          BundlerAction.permit2TransferFrom(
            permit2TransferFrom,
            Signature.from(
              await borrower.signTypedData(permit2Config.domain, permit2Config.types, permit2TransferFrom),
            ),
          ),
          BundlerAction.morphoSupplyCollateral(marketParams, assets, borrower.address, []),
          BundlerAction.morphoBorrow(marketParams, assets / 2n, 0, borrower.address),
        ]);
    }
  });

  it("should simulate gas cost [erc4626-deposit]", async () => {
    for (let i = 0; i < suppliers.length; ++i) {
      logProgress("erc4626-deposit", i, suppliers.length);

      const supplier = suppliers[i];

      const assets = BigInt.WAD * toBigInt(1 + Math.floor(random() * 100));

      const permit2TransferFrom = {
        permitted: {
          token: await collateral.getAddress(),
          amount: assets,
        },
        spender: bundlerAddress,
        nonce: 0n,
        deadline: MAX_UINT48,
      };

      await collateral.connect(supplier).approve(permit2Address, MaxUint256);

      await randomForwardTimestamp();

      await bundler
        .connect(supplier)
        .multicall([
          BundlerAction.permit2TransferFrom(
            permit2TransferFrom,
            Signature.from(
              await supplier.signTypedData(permit2Config.domain, permit2Config.types, permit2TransferFrom),
            ),
          ),
          BundlerAction.erc4626Deposit(erc4626Address, assets, 0, supplier.address),
        ]);
    }
  });
});
