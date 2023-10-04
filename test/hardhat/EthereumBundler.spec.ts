import { AbiCoder, MaxUint256, keccak256 } from "ethers";
import hre from "hardhat";
import _range from "lodash/range";
import { ERC20Mock, EthereumBundler, MorphoMock, OracleMock, SpeedJumpIrmMock } from "types";
import { MarketParamsStruct } from "types/@bundlers/morpho-blue/src/Morpho";

import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import {
  increaseTo,
  latest,
  setNextBlockTimestamp,
} from "@nomicfoundation/hardhat-network-helpers/dist/src/helpers/time";

// Without the division it overflows.
const initBalance = MaxUint256 / 10000000000000000n;
const oraclePriceScale = 1000000000000000000000000000000000000n;

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
  let irm: SpeedJumpIrmMock;

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

    const SpeedJumpIrmFactory = await hre.ethers.getContractFactory("SpeedJumpIrmMock", admin);

    irm = await SpeedJumpIrmFactory.deploy(morphoAddress);

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

  it("should simulate gas cost [main]", async () => {});
});
