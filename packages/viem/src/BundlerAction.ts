import {
  aaveV2MigrationBundlerAbi,
  aaveV3MigrationBundlerAbi,
  aaveV3OptimizerMigrationBundlerAbi,
  compoundV2MigrationBundlerAbi,
  compoundV3MigrationBundlerAbi,
  erc20WrapperBundlerAbi,
  erc4626BundlerAbi,
  ethereumPermitBundlerAbi,
  morphoBundlerAbi,
  permit2BundlerAbi,
  permitBundlerAbi,
  stEthBundlerAbi,
  transferBundlerAbi,
  urdBundlerAbi,
  wNativeBundlerAbi,
} from "./abis";

import { Address, Hex, encodeAbiParameters, encodeFunctionData, parseSignature } from "viem";

export type BundlerCall = Hex;

export interface MarketParams {
  loanToken: Address;
  collateralToken: Address;
  oracle: Address;
  irm: Address;
  lltv: bigint;
}

export interface Authorization {
  authorizer: Address;
  authorized: Address;
  isAuthorized: boolean;
  nonce: bigint;
  deadline: bigint;
}

export interface ReallocationWithdrawal {
  marketParams: MarketParams;
  amount: bigint;
}

export interface Permit2PermitSingleDetails {
  token: Address;
  amount: bigint;
  expiration: number;
  nonce: number;
}

export interface Permit2PermitSingle {
  details: Permit2PermitSingleDetails;
  spender: Address;
  sigDeadline: bigint;
}

/**
 * Namespace to easily encode calls to the Bundler contract, using ethers.
 */
export namespace BundlerAction {
  /* ERC20 */

  /**
   * Encodes a call to the Bundler to transfer native tokens (ETH on ethereum, MATIC on polygon, etc).
   * @param recipient The address to send native tokens to.
   * @param amount The amount of native tokens to send (in wei).
   */
  export function nativeTransfer(recipient: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({ abi: transferBundlerAbi, functionName: "nativeTransfer", args: [recipient, amount] });
  }

  /**
   * Encodes a call to the Bundler to transfer ERC20 tokens.
   * @param asset The address of the ERC20 token to transfer.
   * @param recipient The address to send tokens to.
   * @param amount The amount of tokens to send.
   */
  export function erc20Transfer(asset: Address, recipient: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: transferBundlerAbi,
      functionName: "erc20Transfer",
      args: [asset, recipient, amount],
    });
  }

  /**
   * Encodes a call to the Bundler to transfer ERC20 tokens from the sender to the Bundler.
   * @param asset The address of the ERC20 token to transfer.
   * @param amount The amount of tokens to send.
   */
  export function erc20TransferFrom(asset: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({ abi: transferBundlerAbi, functionName: "erc20TransferFrom", args: [asset, amount] });
  }

  /* Permit */

  /**
   * Encodes a call to the Bundler to permit an ERC20 token.
   * @param asset The address of the ERC20 token to permit.
   * @param amount The amount of tokens to permit.
   * @param deadline The timestamp until which the signature is valid.
   * @param signature The Ethers signature to permit the tokens.
   * @param skipRevert Whether to allow the permit to revert without making the whole multicall revert.
   */
  export function permit(
    asset: Address,
    amount: bigint,
    deadline: bigint,
    signature: Hex,
    skipRevert: boolean,
  ): BundlerCall {
    const { r, s, yParity } = parseSignature(signature);

    return encodeFunctionData({
      abi: permitBundlerAbi,
      functionName: "permit",
      args: [asset, amount, deadline, yParity, r, s, skipRevert],
    });
  }

  /**
   * Encodes a call to the Bundler to permit DAI.
   * @param nonce The permit nonce used.
   * @param expiry The timestamp until which the signature is valid.
   * @param allowed The amount of DAI to permit.
   * @param signature The Ethers signature to permit the tokens.
   * @param skipRevert Whether to allow the permit to revert without making the whole multicall revert.
   */
  export function permitDai(
    nonce: bigint,
    expiry: bigint,
    allowed: boolean,
    signature: Hex,
    skipRevert: boolean,
  ): BundlerCall {
    const { r, s, yParity } = parseSignature(signature);

    return encodeFunctionData({
      abi: ethereumPermitBundlerAbi,
      functionName: "permitDai",
      args: [nonce, expiry, allowed, yParity, r, s, skipRevert],
    });
  }

  /* Permit2 */

  /**
   * Encodes a call to the Bundler to permit ERC20 tokens via Permit2.
   * @param permitSingle The permit details to submit to Permit2.
   * @param signature The Ethers signature to permit the tokens.
   * @param skipRevert Whether to allow the permit to revert without making the whole multicall revert.
   */
  export function approve2(permitSingle: Permit2PermitSingle, signature: Hex, skipRevert: boolean): BundlerCall {
    return encodeFunctionData({
      abi: permit2BundlerAbi,
      functionName: "approve2",
      args: [permitSingle, signature, skipRevert],
    });
  }

  /**
   * Encodes a call to the Bundler to transfer ERC20 tokens via Permit2 from the sender to the Bundler.
   * @param asset The address of the ERC20 token to transfer.
   * @param amount The amount of tokens to send.
   */
  export function transferFrom2(asset: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({ abi: permit2BundlerAbi, functionName: "transferFrom2", args: [asset, amount] });
  }

  /* ERC20 Wrapper */

  /**
   * Encodes a call to the Bundler to wrap ERC20 tokens via the provided ERC20Wrapper.
   * @param wrapper The address of the ERC20 wrapper token.
   * @param amount The amount of tokens to send.
   */
  export function erc20WrapperDepositFor(wrapper: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: erc20WrapperBundlerAbi,
      functionName: "erc20WrapperDepositFor",
      args: [wrapper, amount],
    });
  }

  /**
   * Encodes a call to the Bundler to unwrap ERC20 tokens from the provided ERC20Wrapper.
   * @param wrapper The address of the ERC20 wrapper token.
   * @param account The address to send the underlying ERC20 tokens.
   * @param amount The amount of tokens to send.
   */
  export function erc20WrapperWithdrawTo(wrapper: Address, account: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: erc20WrapperBundlerAbi,
      functionName: "erc20WrapperWithdrawTo",
      args: [wrapper, account, amount],
    });
  }

  /* ERC4626 */

  /**
   * Encodes a call to the Bundler to mint shares of the provided ERC4626 vault.
   * @param erc4626 The address of the ERC4626 vault.
   * @param shares The amount of shares to mint.
   * @param maxAssets The maximum amount of assets to deposit (protects the sender from unexpected slippage).
   * @param receiver The address to send the shares to.
   */
  export function erc4626Mint(erc4626: Address, shares: bigint, maxAssets: bigint, receiver: Address): BundlerCall {
    return encodeFunctionData({
      abi: erc4626BundlerAbi,
      functionName: "erc4626Mint",
      args: [erc4626, shares, maxAssets, receiver],
    });
  }

  /**
   * Encodes a call to the Bundler to deposit assets into the provided ERC4626 vault.
   * @param erc4626 The address of the ERC4626 vault.
   * @param assets The amount of assets to deposit.
   * @param minShares The minimum amount of shares to mint (protects the sender from unexpected slippage).
   * @param receiver The address to send the shares to.
   */
  export function erc4626Deposit(erc4626: Address, assets: bigint, minShares: bigint, receiver: Address): BundlerCall {
    return encodeFunctionData({
      abi: erc4626BundlerAbi,
      functionName: "erc4626Deposit",
      args: [erc4626, assets, minShares, receiver],
    });
  }

  /**
   * Encodes a call to the Bundler to withdraw assets from the provided ERC4626 vault.
   * @param erc4626 The address of the ERC4626 vault.
   * @param assets The amount of assets to withdraw.
   * @param maxShares The maximum amount of shares to redeem (protects the sender from unexpected slippage).
   * @param receiver The address to send the assets to.
   */
  export function erc4626Withdraw(
    erc4626: Address,
    assets: bigint,
    maxShares: bigint,
    receiver: Address,
    owner: Address,
  ): BundlerCall {
    return encodeFunctionData({
      abi: erc4626BundlerAbi,
      functionName: "erc4626Withdraw",
      args: [erc4626, assets, maxShares, receiver, owner],
    });
  }

  /**
   * Encodes a call to the Bundler to redeem shares from the provided ERC4626 vault.
   * @param erc4626 The address of the ERC4626 vault.
   * @param shares The amount of shares to redeem.
   * @param minAssets The minimum amount of assets to withdraw (protects the sender from unexpected slippage).
   * @param receiver The address to send the assets to.
   */
  export function erc4626Redeem(
    erc4626: Address,
    shares: bigint,
    minAssets: bigint,
    receiver: Address,
    owner: Address,
  ): BundlerCall {
    return encodeFunctionData({
      abi: erc4626BundlerAbi,
      functionName: "erc4626Redeem",
      args: [erc4626, shares, minAssets, receiver, owner],
    });
  }

  /* Morpho */

  /**
   * Encodes a call to the Bundler to authorize an account on Morpho Blue.
   * @param authorization The authorization details to submit to Morpho Blue.
   * @param signature The Ethers signature to authorize the account.
   * @param skipRevert Whether to allow the authorization call to revert without making the whole multicall revert.
   */
  export function morphoSetAuthorizationWithSig(
    authorization: Authorization,
    signature: Hex,
    skipRevert: boolean,
  ): BundlerCall {
    const { r, s, yParity } = parseSignature(signature);

    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "morphoSetAuthorizationWithSig",
      args: [authorization, { v: yParity, r, s }, skipRevert],
    });
  }

  /**
   * Encodes a call to the Bundler to supply to a Morpho Blue market.
   * @param market The market params to supply to.
   * @param assets The amount of assets to supply.
   * @param shares The amount of supply shares to mint.
   * @param slippageAmount The maximum (resp. minimum) amount of assets (resp. supply shares) to supply (resp. mint) (protects the sender from unexpected slippage).
   * @param onBehalf The address to supply on behalf of.
   * @param callbackCalls The array of calls to execute inside Morpho Blue's `onMorphoSupply` callback.
   */
  export function morphoSupply(
    market: MarketParams,
    assets: bigint,
    shares: bigint,
    slippageAmount: bigint,
    onBehalf: Address,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "morphoSupply",
      args: [
        market,
        assets,
        shares,
        slippageAmount,
        onBehalf,
        encodeAbiParameters([{ type: "bytes[]" }], [callbackCalls]),
      ],
    });
  }

  /**
   * Encodes a call to the Bundler to supply collateral to a Morpho Blue market.
   * @param market The market params to supply to.
   * @param assets The amount of assets to supply.
   * @param onBehalf The address to supply on behalf of.
   * @param callbackCalls The array of calls to execute inside Morpho Blue's `onMorphoSupplyCollateral` callback.
   */
  export function morphoSupplyCollateral(
    market: MarketParams,
    assets: bigint,
    onBehalf: Address,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "morphoSupplyCollateral",
      args: [market, assets, onBehalf, encodeAbiParameters([{ type: "bytes[]" }], [callbackCalls])],
    });
  }

  /**
   * Encodes a call to the Bundler to borrow from a Morpho Blue market.
   * @param market The market params to borrow from.
   * @param assets The amount of assets to borrow.
   * @param shares The amount of borrow shares to mint.
   * @param slippageAmount The minimum (resp. maximum) amount of assets (resp. borrow shares) to borrow (resp. mint) (protects the sender from unexpected slippage).
   * @param receiver The address to send borrowed tokens to.
   */
  export function morphoBorrow(
    market: MarketParams,
    assets: bigint,
    shares: bigint,
    slippageAmount: bigint,
    receiver: Address,
  ): BundlerCall {
    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "morphoBorrow",
      args: [market, assets, shares, slippageAmount, receiver],
    });
  }

  /**
   * Encodes a call to the Bundler to repay to a Morpho Blue market.
   * @param market The market params to repay to.
   * @param assets The amount of assets to repay.
   * @param shares The amount of borrow shares to redeem.
   * @param slippageAmount The maximum (resp. minimum) amount of assets (resp. borrow shares) to repay (resp. redeem) (protects the sender from unexpected slippage).
   * @param onBehalf The address to repay on behalf of.
   * @param callbackCalls The array of calls to execute inside Morpho Blue's `onMorphoSupply` callback.
   */
  export function morphoRepay(
    market: MarketParams,
    assets: bigint,
    shares: bigint,
    slippageAmount: bigint,
    onBehalf: Address,
    callbackCalls: BundlerCall[],
  ): BundlerCall {
    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "morphoRepay",
      args: [
        market,
        assets,
        shares,
        slippageAmount,
        onBehalf,
        encodeAbiParameters([{ type: "bytes[]" }], [callbackCalls]),
      ],
    });
  }

  /**
   * Encodes a call to the Bundler to withdraw from a Morpho Blue market.
   * @param market The market params to withdraw from.
   * @param assets The amount of assets to withdraw.
   * @param shares The amount of supply shares to redeem.
   * @param slippageAmount The minimum (resp. maximum) amount of assets (resp. supply shares) to withdraw (resp. redeem) (protects the sender from unexpected slippage).
   * @param receiver The address to send withdrawn tokens to.
   */
  export function morphoWithdraw(
    market: MarketParams,
    assets: bigint,
    shares: bigint,
    slippageAmount: bigint,
    receiver: Address,
  ): BundlerCall {
    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "morphoWithdraw",
      args: [market, assets, shares, slippageAmount, receiver],
    });
  }

  /**
   * Encodes a call to the Bundler to withdraw collateral from a Morpho Blue market.
   * @param market The market params to withdraw from.
   * @param assets The amount of assets to withdraw.
   * @param receiver The address to send withdrawn tokens to.
   */
  export function morphoWithdrawCollateral(market: MarketParams, assets: bigint, receiver: Address): BundlerCall {
    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "morphoWithdrawCollateral",
      args: [market, assets, receiver],
    });
  }

  /**
   * Encodes a call to the Bundler to flash loan from Morpho Blue.
   * @param asset The address of the ERC20 token to flash loan.
   * @param amount The amount of tokens to flash loan.
   * @param callbackCalls The array of calls to execute inside Morpho Blue's `onMorphoFlashLoan` callback.
   */
  export function morphoFlashLoan(asset: Address, amount: bigint, callbackCalls: BundlerCall[]): BundlerCall {
    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "morphoFlashLoan",
      args: [asset, amount, encodeAbiParameters([{ type: "bytes[]" }], [callbackCalls])],
    });
  }

  /**
   * Encodes a call to the Bundler to trigger a public reallocation on the PublicAllocator.
   * @param publicAllocator The address of the PublicAllocator to use.
   * @param vault The vault to reallocate.
   * @param value The value of the call. Can be used to pay the vault reallocation fees.
   * @param withdrawals The array of withdrawals to perform, before supplying everything to the supply market.
   * @param supplyMarketParams The market params to reallocate to.
   */
  export function metaMorphoReallocateTo(
    publicAllocator: Address,
    vault: Address,
    value: bigint,
    withdrawals: ReallocationWithdrawal[],
    supplyMarketParams: MarketParams,
  ): BundlerCall {
    return encodeFunctionData({
      abi: morphoBundlerAbi,
      functionName: "reallocateTo",
      args: [publicAllocator, vault, value, withdrawals, supplyMarketParams],
    });
  }

  /* Universal Rewards Distributor */

  /**
   * Encodes a call to the Bundler to claim rewards from the Universal Rewards Distributor.
   * @param distributor The address of the distributor to claim rewards from.
   * @param account The address to claim rewards for.
   * @param reward The address of the reward token to claim.
   * @param amount The amount of rewards to claim.
   * @param proof The Merkle proof to claim the rewards.
   * @param skipRevert Whether to allow the claim to revert without making the whole multicall revert.
   */
  export function urdClaim(
    distributor: Address,
    account: Address,
    reward: Address,
    amount: bigint,
    proof: Hex[],
    skipRevert: boolean,
  ): BundlerCall {
    return encodeFunctionData({
      abi: urdBundlerAbi,
      functionName: "urdClaim",
      args: [distributor, account, reward, amount, proof, skipRevert],
    });
  }

  /* Wrapped Native */

  /**
   * Encodes a call to the Bundler to wrap native tokens (ETH to WETH on ethereum, MATIC to WMATIC on polygon, etc).
   * @param amount The amount of native tokens to wrap (in wei).
   */
  export function wrapNative(amount: bigint): BundlerCall {
    return encodeFunctionData({ abi: wNativeBundlerAbi, functionName: "wrapNative", args: [amount] });
  }

  /**
   * Encodes a call to the Bundler to unwrap native tokens (WETH to ETH on ethereum, WMATIC to MATIC on polygon, etc).
   * @param amount The amount of native tokens to unwrap (in wei).
   */
  export function unwrapNative(amount: bigint): BundlerCall {
    return encodeFunctionData({ abi: wNativeBundlerAbi, functionName: "unwrapNative", args: [amount] });
  }

  /* stETH */

  /**
   * Encodes a call to the Bundler to stake native tokens using Lido (ETH to stETH on ethereum).
   * @param amount The amount of native tokens to stake (in wei).
   * @param minShares The minimum amount of shares to mint (protects the sender from unexpected slippage).
   * @param referral The referral address to use.
   */
  export function stakeEth(amount: bigint, minShares: bigint, referral: Address): BundlerCall {
    return encodeFunctionData({ abi: stEthBundlerAbi, functionName: "stakeEth", args: [amount, minShares, referral] });
  }

  /* Wrapped stETH */

  /**
   * Encodes a call to the Bundler to wrap stETH (stETH to wstETH on ethereum).
   * @param amount The amount of stETH to wrap (in wei).
   */
  export function wrapStEth(amount: bigint): BundlerCall {
    return encodeFunctionData({ abi: stEthBundlerAbi, functionName: "wrapStEth", args: [amount] });
  }

  /**
   * Encodes a call to the Bundler to unwrap wstETH (wstETH to stETH on ethereum).
   * @param amount The amount of wstETH to unwrap (in wei).
   */
  export function unwrapStEth(amount: bigint): BundlerCall {
    return encodeFunctionData({ abi: stEthBundlerAbi, functionName: "unwrapStEth", args: [amount] });
  }

  /* AaveV2 */

  /**
   * ! Only available on AaveV2MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to repay a debt on AaveV2.
   * @param asset The debt asset to repay.
   * @param amount The amount of debt to repay.
   * @param rateMode The interest rate mode used by the debt to repay.
   */
  export function aaveV2Repay(asset: Address, amount: bigint, rateMode: bigint): BundlerCall {
    return encodeFunctionData({
      abi: aaveV2MigrationBundlerAbi,
      functionName: "aaveV2Repay",
      args: [asset, amount, rateMode],
    });
  }

  /**
   * ! Only available on AaveV2MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to withdrawn from AaveV2.
   * @param asset The asset to withdraw.
   * @param amount The amount of asset to withdraw.
   */
  export function aaveV2Withdraw(asset: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: aaveV2MigrationBundlerAbi,
      functionName: "aaveV2Withdraw",
      args: [asset, amount],
    });
  }

  /* AaveV3 */

  /**
   * ! Only available on AaveV3MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to repay a debt on AaveV3.
   * @param asset The debt asset to repay.
   * @param amount The amount of debt to repay.
   * @param rateMode The interest rate mode used by the debt to repay.
   */
  export function aaveV3Repay(asset: Address, amount: bigint, rateMode: bigint): BundlerCall {
    return encodeFunctionData({
      abi: aaveV3MigrationBundlerAbi,
      functionName: "aaveV3Repay",
      args: [asset, amount, rateMode],
    });
  }

  /**
   * ! Only available on AaveV3MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to withdrawn from AaveV3.
   * @param asset The asset to withdraw.
   * @param amount The amount of asset to withdraw.
   */
  export function aaveV3Withdraw(asset: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: aaveV3MigrationBundlerAbi,
      functionName: "aaveV3Withdraw",
      args: [asset, amount],
    });
  }

  /* AaveV3 Optimizer */

  /**
   * ! Only available on AaveV3OptimizerMigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to repay a debt on Morpho's AaveV3Optimizer.
   * @param underlying The underlying debt asset to repay.
   * @param amount The amount of debt to repay.
   * @param maxIterations The maximum amount of iterations to use for the repayment.
   */
  export function aaveV3OptimizerRepay(underlying: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: aaveV3OptimizerMigrationBundlerAbi,
      functionName: "aaveV3OptimizerRepay",
      args: [underlying, amount],
    });
  }

  /**
   * ! Only available on AaveV3OptimizerMigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to withdraw from Morpho's AaveV3Optimizer.
   * @param underlying The underlying asset to withdraw.
   * @param amount The amount to withdraw.
   * @param maxIterations The maximum amount of iterations to use for the withdrawal.
   */
  export function aaveV3OptimizerWithdraw(underlying: Address, amount: bigint, maxIterations: bigint): BundlerCall {
    return encodeFunctionData({
      abi: aaveV3OptimizerMigrationBundlerAbi,
      functionName: "aaveV3OptimizerWithdraw",
      args: [underlying, amount, maxIterations],
    });
  }

  /**
   * ! Only available on AaveV3OptimizerMigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to withdraw collateral from Morpho's AaveV3Optimizer.
   * @param underlying The underlying asset to withdraw.
   * @param amount The amount to withdraw.
   */
  export function aaveV3OptimizerWithdrawCollateral(underlying: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: aaveV3OptimizerMigrationBundlerAbi,
      functionName: "aaveV3OptimizerWithdrawCollateral",
      args: [underlying, amount],
    });
  }

  /**
   * ! Only available on AaveV3OptimizerMigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to approve the Bundler as the sender's manager on Morpho's AaveV3Optimizer.
   * @param isApproved Whether the manager is approved.
   * @param nonce The nonce used to sign.
   * @param deadline The timestamp until which the signature is valid.
   * @param signature The Ethers signature to submit.
   * @param skipRevert Whether to allow the signature to revert without making the whole multicall revert.
   */
  export function aaveV3OptimizerApproveManagerWithSig(
    isApproved: boolean,
    nonce: bigint,
    deadline: bigint,
    signature: Hex,
    skipRevert: boolean,
  ): BundlerCall {
    const { r, s, yParity } = parseSignature(signature);

    return encodeFunctionData({
      abi: aaveV3OptimizerMigrationBundlerAbi,
      functionName: "aaveV3OptimizerApproveManagerWithSig",
      args: [isApproved, nonce, deadline, { v: yParity, r, s }, skipRevert],
    });
  }

  /* CompoundV2 */

  /**
   * ! Only available on CompoundV2MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to repay a debt on CompoundV2.
   * @param cToken The cToken on which to repay the debt.
   * @param amount The amount of debt to repay.
   */
  export function compoundV2Repay(cToken: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: compoundV2MigrationBundlerAbi,
      functionName: "compoundV2Repay",
      args: [cToken, amount],
    });
  }

  /**
   * ! Only available on CompoundV2MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to withdraw collateral from CompoundV2.
   * @param cToken The cToken on which to withdraw.
   * @param amount The amount to withdraw.
   */
  export function compoundV2Redeem(cToken: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: compoundV2MigrationBundlerAbi,
      functionName: "compoundV2Redeem",
      args: [cToken, amount],
    });
  }

  /* CompoundV3 */

  /**
   * ! Only available on CompoundV3MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to repay a debt on CompoundV3.
   * @param instance The CompoundV3 instance on which to repay the debt.
   * @param amount The amount of debt to repay.
   */
  export function compoundV3Repay(instance: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: compoundV3MigrationBundlerAbi,
      functionName: "compoundV3Repay",
      args: [instance, amount],
    });
  }

  /**
   * ! Only available on CompoundV3MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to withdraw collateral from CompoundV3.
   * @param instance The CompoundV3 instance on which to withdraw.
   * @param amount The amount to withdraw.
   */
  export function compoundV3WithdrawFrom(instance: Address, asset: Address, amount: bigint): BundlerCall {
    return encodeFunctionData({
      abi: compoundV3MigrationBundlerAbi,
      functionName: "compoundV3WithdrawFrom",
      args: [instance, asset, amount],
    });
  }

  /**
   * ! Only available on CompoundV3MigrationBundler instances (not the main Bundler contract!).
   * Encodes a call to the Bundler to allow the Bundler to act on the sender's position on CompoundV3.
   * @param instance The CompoundV3 instance on which to submit the signature.
   * @param isAllowed Whether the manager is allowed.
   * @param nonce The nonce used to sign.
   * @param expiry The timestamp until which the signature is valid.
   * @param signature The Ethers signature to submit.
   * @param skipRevert Whether to allow the signature to revert without making the whole multicall revert.
   */
  export function compoundV3AllowBySig(
    instance: Address,
    isAllowed: boolean,
    nonce: bigint,
    expiry: bigint,
    signature: Hex,
    skipRevert: boolean,
  ): BundlerCall {
    const { r, s, yParity } = parseSignature(signature);

    return encodeFunctionData({
      abi: compoundV3MigrationBundlerAbi,
      functionName: "compoundV3AllowBySig",
      args: [instance, isAllowed, nonce, expiry, yParity, r, s, skipRevert],
    });
  }
}

export default BundlerAction;
