import { BigNumberish, BytesLike, Signature } from "ethers";
import {
  TransferBundler__factory,
  PermitBundler__factory,
  Permit2Bundler__factory,
  ERC4626Bundler__factory,
  MorphoBundler__factory,
  UrdBundler__factory,
  WNativeBundler__factory,
  StEthBundler__factory,
  AaveV2MigrationBundler__factory,
  AaveV3MigrationBundler__factory,
  AaveV3OptimizerMigrationBundler__factory,
  CompoundV2MigrationBundler__factory,
  CompoundV3MigrationBundler__factory,
  EthereumPermitBundler__factory,
  ISignatureTransfer,
} from "types";
import { AuthorizationStruct, MarketParamsStruct } from "types/src/MorphoBundler";

export type BundlerCall = string;

export class BundlerAction {
  private static TRANSFER_BUNDLER_IFC = TransferBundler__factory.createInterface();
  private static PERMIT_BUNDLER_IFC = PermitBundler__factory.createInterface();
  private static PERMIT2_BUNDLER_IFC = Permit2Bundler__factory.createInterface();
  private static ERC4626_BUNDLER_IFC = ERC4626Bundler__factory.createInterface();
  private static MORPHO_BUNDLER_IFC = MorphoBundler__factory.createInterface();
  private static URD_BUNDLER_IFC = UrdBundler__factory.createInterface();
  private static WNATIVE_BUNDLER_IFC = WNativeBundler__factory.createInterface();
  private static ST_ETH_BUNDLER_IFC = StEthBundler__factory.createInterface();
  private static ETHEREUM_PERMIT_BUNDLER_IFC = EthereumPermitBundler__factory.createInterface();

  private static AAVE_V2_BUNDLER_IFC = AaveV2MigrationBundler__factory.createInterface();
  private static AAVE_V3_BUNDLER_IFC = AaveV3MigrationBundler__factory.createInterface();
  private static AAVE_V3_OPTIMIZER_BUNDLER_IFC = AaveV3OptimizerMigrationBundler__factory.createInterface();
  private static COMPOUND_V2_BUNDLER_IFC = CompoundV2MigrationBundler__factory.createInterface();
  private static COMPOUND_V3_BUNDLER_IFC = CompoundV3MigrationBundler__factory.createInterface();

  /* ERC20 */

  static nativeTransfer(recipient: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.TRANSFER_BUNDLER_IFC.encodeFunctionData("nativeTransfer", [recipient, amount]);
  }

  static erc20Transfer(asset: string, recipient: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.TRANSFER_BUNDLER_IFC.encodeFunctionData("erc20Transfer", [asset, recipient, amount]);
  }

  static erc20TransferFrom(asset: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.TRANSFER_BUNDLER_IFC.encodeFunctionData("erc20TransferFrom", [asset, amount]);
  }

  /* Permit */

  static permit(
    asset: string,
    amount: BigNumberish,
    deadline: BigNumberish,
    signature: Signature,
    skipRevert: boolean,
  ): BundlerCall {
    return BundlerAction.PERMIT_BUNDLER_IFC.encodeFunctionData("permit", [
      asset,
      amount,
      deadline,
      signature.v,
      signature.r,
      signature.s,
      skipRevert,
    ]);
  }

  static permitDai(
    nonce: BigNumberish,
    expiry: BigNumberish,
    allowed: boolean,
    signature: Signature,
    skipRevert: boolean,
  ): BundlerCall {
    return BundlerAction.ETHEREUM_PERMIT_BUNDLER_IFC.encodeFunctionData("permitDai", [
      nonce,
      expiry,
      allowed,
      signature.v,
      signature.r,
      signature.s,
      skipRevert,
    ]);
  }

  /* Permit2 */

  static permit2TransferFrom(permit: ISignatureTransfer.PermitTransferFromStruct, signature: Signature): BundlerCall {
    return BundlerAction.PERMIT2_BUNDLER_IFC.encodeFunctionData("permit2TransferFrom", [permit, signature.serialized]);
  }

  /* ERC4626 */

  static erc4626Mint(erc4626: string, shares: BigNumberish, maxAssets: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.ERC4626_BUNDLER_IFC.encodeFunctionData("erc4626Mint", [erc4626, shares, maxAssets, receiver]);
  }

  static erc4626Deposit(erc4626: string, assets: BigNumberish, minShares: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.ERC4626_BUNDLER_IFC.encodeFunctionData("erc4626Deposit", [
      erc4626,
      assets,
      minShares,
      receiver,
    ]);
  }

  static erc4626Withdraw(
    erc4626: string,
    assets: BigNumberish,
    maxShares: BigNumberish,
    receiver: string,
  ): BundlerCall {
    return BundlerAction.ERC4626_BUNDLER_IFC.encodeFunctionData("erc4626Withdraw", [
      erc4626,
      assets,
      maxShares,
      receiver,
    ]);
  }

  static erc4626Redeem(erc4626: string, shares: BigNumberish, minAssets: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.ERC4626_BUNDLER_IFC.encodeFunctionData("erc4626Redeem", [
      erc4626,
      shares,
      minAssets,
      receiver,
    ]);
  }

  /* Morpho */

  static morphoSetAuthorizationWithSig(
    authorization: AuthorizationStruct,
    signature: Signature,
    skipRevert: boolean,
  ): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoSetAuthorizationWithSig", [
      authorization,
      { v: signature.v, r: signature.r, s: signature.s },
      skipRevert,
    ]);
  }

  static morphoSupply(
    market: MarketParamsStruct,
    assets: BigNumberish,
    shares: BigNumberish,
    slippageAmount: BigNumberish,
    onBehalf: string,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoSupply", [
      market,
      assets,
      shares,
      slippageAmount,
      onBehalf,
      BundlerAction.MORPHO_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  static morphoSupplyCollateral(
    market: MarketParamsStruct,
    assets: BigNumberish,
    onBehalf: string,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoSupplyCollateral", [
      market,
      assets,
      onBehalf,
      BundlerAction.MORPHO_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  static morphoBorrow(
    market: MarketParamsStruct,
    assets: BigNumberish,
    shares: BigNumberish,
    slippageAmount: BigNumberish,
    receiver: string,
  ): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoBorrow", [
      market,
      assets,
      shares,
      slippageAmount,
      receiver,
    ]);
  }

  static morphoRepay(
    market: MarketParamsStruct,
    assets: BigNumberish,
    shares: BigNumberish,
    slippageAmount: BigNumberish,
    onBehalf: string,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoRepay", [
      market,
      assets,
      shares,
      slippageAmount,
      onBehalf,
      BundlerAction.MORPHO_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  static morphoWithdraw(
    market: MarketParamsStruct,
    assets: BigNumberish,
    shares: BigNumberish,
    slippageAmount: BigNumberish,
    receiver: string,
  ): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoWithdraw", [
      market,
      assets,
      shares,
      slippageAmount,
      receiver,
    ]);
  }

  static morphoWithdrawCollateral(market: MarketParamsStruct, assets: BigNumberish, receiver: string): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoWithdrawCollateral", [market, assets, receiver]);
  }

  static morphoLiquidate(
    market: MarketParamsStruct,
    borrower: string,
    seizedAssets: BigNumberish,
    repaidShares: BigNumberish,
    maxRepaidAssets: BigNumberish,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoLiquidate", [
      market,
      borrower,
      seizedAssets,
      repaidShares,
      maxRepaidAssets,
      BundlerAction.MORPHO_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  static morphoFlashLoan(asset: string, amount: BigNumberish, callbackCalls: BundlerCall[]): BundlerCall {
    return BundlerAction.MORPHO_BUNDLER_IFC.encodeFunctionData("morphoFlashLoan", [
      asset,
      amount,
      BundlerAction.MORPHO_BUNDLER_IFC.getAbiCoder().encode(["bytes[]"], [callbackCalls]),
    ]);
  }

  /* Universal Rewards Distributor */

  static urdClaim(
    distributor: string,
    account: string,
    reward: string,
    amount: BigNumberish,
    proof: BytesLike[],
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

  static stakeEth(amount: BigNumberish, minShares: BigNumberish, referral: string): BundlerCall {
    return BundlerAction.ST_ETH_BUNDLER_IFC.encodeFunctionData("stakeEth", [amount, minShares, referral]);
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

  static aaveV2Withdraw(asset: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V2_BUNDLER_IFC.encodeFunctionData("aaveV2Withdraw", [asset, amount]);
  }

  /* AaveV3 */

  static aaveV3Repay(asset: string, amount: BigNumberish, rateMode: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V3_BUNDLER_IFC.encodeFunctionData("aaveV3Repay", [asset, amount, rateMode]);
  }

  static aaveV3Withdraw(asset: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V3_BUNDLER_IFC.encodeFunctionData("aaveV3Withdraw", [asset, amount]);
  }

  /* AaveV3 Optimizer */

  static aaveV3OptimizerRepay(underlying: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V3_OPTIMIZER_BUNDLER_IFC.encodeFunctionData("aaveV3OptimizerRepay", [underlying, amount]);
  }

  static aaveV3OptimizerWithdraw(underlying: string, amount: BigNumberish, maxIterations: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V3_OPTIMIZER_BUNDLER_IFC.encodeFunctionData("aaveV3OptimizerWithdraw", [
      underlying,
      amount,
      maxIterations,
    ]);
  }

  static aaveV3OptimizerWithdrawCollateral(underlying: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.AAVE_V3_OPTIMIZER_BUNDLER_IFC.encodeFunctionData("aaveV3OptimizerWithdrawCollateral", [
      underlying,
      amount,
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

  static compoundV3Repay(instance: string, amount: BigNumberish): BundlerCall {
    return BundlerAction.COMPOUND_V3_BUNDLER_IFC.encodeFunctionData("compoundV3Repay", [instance, amount]);
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
