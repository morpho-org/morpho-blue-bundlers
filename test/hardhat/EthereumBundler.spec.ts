import { expect } from "chai";
import { AbiCoder, MaxUint256, Signature, keccak256, toBigInt, TypedDataDomain, TypedDataField } from "ethers";
import hre from "hardhat";
import { BundlerAction } from "pkg";
import {
  ERC20Mock,
  ERC4626Mock,
  EthereumBundler,
  MorphoMock,
  OracleMock,
  IrmMock,
  EthereumBundler__factory,
} from "types";
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
    PermitSingle: [
      {
        name: "details",
        type: "PermitDetails",
      },
      {
        name: "spender",
        type: "address",
      },
      {
        name: "sigDeadline",
        type: "uint256",
      },
    ],
    PermitDetails: [
      {
        name: "token",
        type: "address",
      },
      {
        name: "amount",
        type: "uint160",
      },
      {
        name: "expiration",
        type: "uint48",
      },
      {
        name: "nonce",
        type: "uint48",
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
  let irm: IrmMock;

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

    const IrmFactory = await hre.ethers.getContractFactory("IrmMock", admin);

    irm = await IrmFactory.deploy();

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
    hre.tracer.nameTags[irmAddress] = "Irm";
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

      const collateralAddress = await collateral.getAddress();

      const approve2 = {
        details: {
          token: collateralAddress,
          amount: assets,
          nonce: 0n,
          expiration: MAX_UINT48,
        },
        spender: bundlerAddress,
        sigDeadline: MAX_UINT48,
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
          BundlerAction.approve2(
            approve2,
            Signature.from(await borrower.signTypedData(permit2Config.domain, permit2Config.types, approve2)),
            false,
          ),
          BundlerAction.transferFrom2(collateralAddress, assets),
          BundlerAction.morphoSupplyCollateral(marketParams, assets, borrower.address, []),
          BundlerAction.morphoBorrow(marketParams, assets / 2n, 0, MaxUint256, borrower.address),
        ]);
    }
  });

  it("should simulate gas cost [erc4626-deposit]", async () => {
    for (let i = 0; i < suppliers.length; ++i) {
      logProgress("erc4626-deposit", i, suppliers.length);

      const supplier = suppliers[i];

      const assets = BigInt.WAD * toBigInt(1 + Math.floor(random() * 100));
      const collateralAddress = await collateral.getAddress();

      const approve2 = {
        details: {
          token: collateralAddress,
          amount: assets,
          expiration: MAX_UINT48,
          nonce: 0n,
        },
        spender: bundlerAddress,
        sigDeadline: MAX_UINT48,
      };

      await collateral.connect(supplier).approve(permit2Address, MaxUint256);

      await randomForwardTimestamp();

      await bundler
        .connect(supplier)
        .multicall([
          BundlerAction.approve2(
            approve2,
            Signature.from(await supplier.signTypedData(permit2Config.domain, permit2Config.types, approve2)),
            false,
          ),
          BundlerAction.transferFrom2(collateralAddress, assets),
          BundlerAction.erc4626Deposit(erc4626Address, assets, 0, supplier.address),
        ]);
    }
  });

  it("should have all batched functions payable", async () => {
    EthereumBundler__factory.createInterface().forEachFunction((func) => {
      if (func.stateMutability === "view" || func.stateMutability === "pure") return;

      const shouldPayable = !func.name.startsWith("onMorpho");

      expect(func.payable).to.equal(shouldPayable);
    });
  });
});
