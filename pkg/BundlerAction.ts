import { BigNumberish, Signature } from "ethers";
import {
  BaseBundler__factory,
  UrdBundler__factory,
  WNativeBundler__factory,
  StEthBundler__factory,
  AaveV2MigrationBundler__factory,
  AaveV3MigrationBundler__factory,
  AaveV3OptimizerMigrationBundler__factory,
  CompoundV2MigrationBundler__factory,
  CompoundV3MigrationBundler__factory,
} from "types";
import { AuthorizationStruct, MarketParamsStruct } from "types/src/BaseBundler";

export type BundlerCall = string;

export class BundlerAction {
  private static BASE_BUNDLER_IFC = BaseBundler__factory.createInterface();
  private static URD_BUNDLER_IFC = UrdBundler__factory.createInterface();
  private static WNATIVE_BUNDLER_IFC = WNativeBundler__factory.createInterface();
  private static ST_ETH_BUNDLER_IFC = StEthBundler__factory.createInterface();
  private static AAVE_V2_BUNDLER_IFC = AaveV2MigrationBundler__factory.createInterface();
  private static AAVE_V3_BUNDLER_IFC = AaveV3MigrationBundler__factory.createInterface();
  private static AAVE_V3_OPTIMIZER_BUNDLER_IFC = AaveV3OptimizerMigrationBundler__factory.createInterface();
  private static COMPOUND_V2_BUNDLER_IFC = CompoundV2MigrationBundler__factory.createInterface();
  private static COMPOUND_V3_BUNDLER_IFC = CompoundV3MigrationBundler__factory.createInterface();

  /* ERC20 */

  static transfer(asset: string, recipient: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("transfer", [asset, recipient, amount]);
  }

  static transferNative(recipient: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("transferNative", [recipient, amount]);
  }

  static transferFrom(asset: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("transferFrom", [asset, amount]);
  }

  /* Permit */

  static permit(
    asset: string,
    amount: BigNumberish,
    deadline: BigNumberish,
    signature: Signature,
    skipRevert: boolean,
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("permit", [
      asset,
      amount,
      deadline,
      signature.v,
      signature.r,
      signature.s,
      skipRevert,
    ]);
  }

  /* Permit2 */

  static approve2(
    asset: string,
    amount: BigNumberish,
    deadline: BigNumberish,
    signature: Signature,
    skipRevert: boolean,
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("approve2", [
      asset,
      amount,
      deadline,
      { v: signature.v, r: signature.r, s: signature.s },
      skipRevert,
    ]);
  }

  static transferFrom2(asset: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("transferFrom2", [asset, amount]);
  }

  /* ERC4626 */

  static erc4626Mint(erc4626: string, amount: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("erc4626Mint", [erc4626, amount, receiver]);
  }

  static erc4626Deposit(erc4626: string, amount: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("erc4626Deposit", [erc4626, amount, receiver]);
  }

  static erc4626Withdraw(erc4626: string, amount: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("erc4626Withdraw", [erc4626, amount, receiver]);
  }

  static erc4626Redeem(erc4626: string, amount: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("erc4626Redeem", [erc4626, amount, receiver]);
  }

  /* Morpho */

  static morphoSetAuthorizationWithSig(
    authorization: AuthorizationStruct,
    signature: Signature,
    skipRevert: boolean,
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoSetAuthorizationWithSig", [
      authorization,
      { v: signature.v, r: signature.r, s: signature.s },
      skipRevert,
    ]);
  }

  static morphoSupply(
    market: MarketParamsStruct,
    amount: BigNumberish,
    shares: BigNumberish,
    onBehalf: string,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoSupply", [
      market,
      amount,
      shares,
      onBehalf,
      BundlerAction.BASE_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  static morphoSupplyCollateral(
    market: MarketParamsStruct,
    amount: BigNumberish,
    onBehalf: string,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoSupplyCollateral", [
      market,
      amount,
      onBehalf,
      BundlerAction.BASE_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  static morphoBorrow(
    market: MarketParamsStruct,
    amount: BigNumberish,
    shares: BigNumberish,
    receiver: string,
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoBorrow", [market, amount, shares, receiver]);
  }

  static morphoRepay(
    market: MarketParamsStruct,
    amount: BigNumberish,
    shares: BigNumberish,
    onBehalf: string,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoRepay", [
      market,
      amount,
      shares,
      onBehalf,
      BundlerAction.BASE_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  static morphoWithdraw(
    market: MarketParamsStruct,
    amount: BigNumberish,
    shares: BigNumberish,
    receiver: string,
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoWithdraw", [market, amount, shares, receiver]);
  }

  static morphoWithdrawCollateral(market: MarketParamsStruct, amount: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoWithdrawCollateral", [market, amount, receiver]);
  }

  static morphoLiquidate(
    market: MarketParamsStruct,
    borrower: string,
    seizedAssets: BigNumberish,
    repaidShares: BigNumberish,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoLiquidate", [
      market,
      borrower,
      seizedAssets,
      repaidShares,
      BundlerAction.BASE_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  static morphoFlashLoan(asset: string, amount: BigNumberish, callbackCalls: BundlerCall[]): BundlerCall {
    return BundlerAction.BASE_BUNDLER_IFC.encodeFunctionData("morphoFlashLoan", [
      asset,
      amount,
      BundlerAction.BASE_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  /* Universal Rewards Distributor */

  static urdClaim(
    distributor: string,
    account: string,
    reward: string,
    amount: BigNumberish,
    proof: string[],
    skipRevert: boolean,
  ): BundlerCall {
    return BundlerAction.URD_BUNDLER_IFC.encodeFunctionData("urdClaim", [
      distributor,
      account,
      reward,
      amount,
      proof,
      skipRevert,
    ]);
  }

  /* Wrapped Native */

  static wrapNative(amount: BigNumberish): BundlerCall {
    return BundlerAction.WNATIVE_BUNDLER_IFC.encodeFunctionData("wrapNative", [amount]);
  }

  static unwrapNative(amount: BigNumberish): BundlerCall {
    return BundlerAction.WNATIVE_BUNDLER_IFC.encodeFunctionData("unwrapNative", [amount]);
  }

  /* stETH */

  static stakeEth(amount: BigNumberish, referral: string): BundlerCall {
    return BundlerAction.ST_ETH_BUNDLER_IFC.encodeFunctionData("stakeEth", [amount, referral]);
  }

  /* Wrapped stETH */

  static wrapStEth(amount: BigNumberish): BundlerCall {
    return BundlerAction.ST_ETH_BUNDLER_IFC.encodeFunctionData("wrapStEth", [amount]);
  }

  static unwrapStEth(amount: BigNumberish): BundlerCall {
    return BundlerAction.ST_ETH_BUNDLER_IFC.encodeFunctionData("unwrapStEth", [amount]);
  }

  /* AaveV2 */

  static aaveV2Repay(asset: string, amount: BigNumberish, rateMode: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V2_BUNDLER_IFC.encodeFunctionData("aaveV2Repay", [asset, amount, rateMode]);
  }

  static aaveV2Withdraw(asset: string, amount: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.AAVE_V2_BUNDLER_IFC.encodeFunctionData("aaveV2Withdraw", [asset, amount, receiver]);
  }

  /* AaveV3 */

  static aaveV3Repay(asset: string, amount: BigNumberish, rateMode: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V3_BUNDLER_IFC.encodeFunctionData("aaveV3Repay", [asset, amount, rateMode]);
  }

  static aaveV3Withdraw(asset: string, amount: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.AAVE_V3_BUNDLER_IFC.encodeFunctionData("aaveV3Withdraw", [asset, amount, receiver]);
  }

  /* AaveV3 Optimizer */

  static aaveV3OptimizerRepay(underlying: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V3_OPTIMIZER_BUNDLER_IFC.encodeFunctionData("aaveV3OptimizerRepay", [underlying, amount]);
  }

  static aaveV3OptimizerWithdraw(
    underlying: string,
    amount: BigNumberish,
    receiver: string,
    maxIterations: BigNumberish,
  ): BundlerCall {
    return BundlerAction.AAVE_V3_OPTIMIZER_BUNDLER_IFC.encodeFunctionData("aaveV3OptimizerWithdraw", [
      underlying,
      amount,
      receiver,
      maxIterations,
    ]);
  }

  static aaveV3OptimizerWithdrawCollateral(underlying: string, amount: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.AAVE_V3_OPTIMIZER_BUNDLER_IFC.encodeFunctionData("aaveV3OptimizerWithdrawCollateral", [
      underlying,
      amount,
      receiver,
    ]);
  }

  static aaveV3OptimizerApproveManagerWithSig(
    isApproved: boolean,
    nonce: BigNumberish,
    deadline: BigNumberish,
    signature: Signature,
  ): BundlerCall {
    return BundlerAction.AAVE_V3_OPTIMIZER_BUNDLER_IFC.encodeFunctionData("aaveV3OptimizerApproveManagerWithSig", [
      isApproved,
      nonce,
      deadline,
      { v: signature.v, r: signature.r, s: signature.s },
    ]);
  }

  /* CompoundV2 */

  static compoundV2Repay(cToken: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.COMPOUND_V2_BUNDLER_IFC.encodeFunctionData("compoundV2Repay", [cToken, amount]);
  }

  static compoundV2Redeem(cToken: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.COMPOUND_V2_BUNDLER_IFC.encodeFunctionData("compoundV2Redeem", [cToken, amount]);
  }

  /* CompoundV3 */

  static compoundV3Repay(instance: string, asset: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.COMPOUND_V3_BUNDLER_IFC.encodeFunctionData("compoundV3Repay", [instance, asset, amount]);
  }

  static compoundV3Withdraw(instance: string, asset: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.COMPOUND_V3_BUNDLER_IFC.encodeFunctionData("compoundV3Withdraw", [instance, asset, amount]);
  }

  static compoundV3WithdrawFrom(instance: string, asset: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.COMPOUND_V3_BUNDLER_IFC.encodeFunctionData("compoundV3WithdrawFrom", [
      instance,
      asset,
      amount,
    ]);
  }

  static compoundV3AllowBySig(
    instance: string,
    isAllowed: boolean,
    nonce: BigNumberish,
    expiry: BigNumberish,
    signature: Signature,
  ): BundlerCall {
    return BundlerAction.COMPOUND_V3_BUNDLER_IFC.encodeFunctionData("compoundV3AllowBySig", [
      instance,
      isAllowed,
      nonce,
      expiry,
      signature.v,
      signature.r,
      signature.s,
    ]);
  }
}

export default BundlerAction;
