// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";

import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";
import {ErrorsLib} from "src/libraries/ErrorsLib.sol";
import {MarketParamsLib} from "@morpho-blue/libraries/MarketParamsLib.sol";
import {MorphoLib} from "@morpho-blue/libraries/periphery/MorphoLib.sol";
import {MorphoBalancesLib} from "@morpho-blue/libraries/periphery/MorphoBalancesLib.sol";

import "../../helpers/EthereumTest.sol";
import {BaseBundler} from "src/BaseBundler.sol";
import {PermitBundler} from "src/PermitBundler.sol";
import {Permit2Bundler} from "src/Permit2Bundler.sol";
import {ERC4626Bundler} from "src/ERC4626Bundler.sol";
import {MorphoBundler} from "src/MorphoBundler.sol";
import {ERC4626Mock} from "src/mocks/ERC4626Mock.sol";

uint256 constant SIGNATURE_DEADLINE = type(uint32).max;

contract EthereumMigrationTest is EthereumTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    MarketParams internal marketParams;
    ERC4626Mock internal suppliersVault;

    function _initMarket(address collateral, address loan) internal {
        marketParams.collateralToken = collateral;
        marketParams.loanToken = loan;
        marketParams.oracle = address(oracle);
        marketParams.irm = address(irm);
        marketParams.lltv = 0.8 ether;

        (,,,, uint128 lastUpdate,) = morpho.market(marketParams.id());
        if (lastUpdate == 0) {
            morpho.createMarket(marketParams);
        }

        suppliersVault = new ERC4626Mock(marketParams.loanToken, "suppliers vault", "vault");
        vm.label(address(suppliersVault), "Suppliers Vault");
    }

    function _getUserAndKey(uint256 privateKey) internal returns (uint256, address) {
        privateKey = bound(privateKey, 1, type(uint32).max);
        address user = vm.addr(privateKey);
        vm.label(user, "user");
        return (privateKey, user);
    }

    function _morphoSetAuthorizationWithSigCall(
        uint256 privateKey,
        address authorized,
        bool isAuthorized,
        uint256 nonce
    ) internal view returns (bytes memory) {
        Authorization memory authorization = Authorization({
            authorizer: vm.addr(privateKey),
            authorized: authorized,
            isAuthorized: isAuthorized,
            nonce: nonce,
            deadline: SIGNATURE_DEADLINE
        });

        bytes32 digest = SigUtils.toTypedDataHash(morpho.DOMAIN_SEPARATOR(), authorization);

        Signature memory sig;
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        return abi.encodeCall(MorphoBundler.morphoSetAuthorizationWithSig, (authorization, sig, false));
    }

    function _morphoBorrowCall(uint256 amount, address receiver) internal view returns (bytes memory) {
        return abi.encodeCall(MorphoBundler.morphoBorrow, (marketParams, amount, 0, receiver));
    }

    function _morphoSupplyCall(uint256 amount, address onBehalf, bytes memory callbackData)
        internal
        view
        returns (bytes memory)
    {
        return abi.encodeCall(MorphoBundler.morphoSupply, (marketParams, amount, 0, onBehalf, callbackData));
    }

    function _morphoSupplyCollateralCall(uint256 amount, address onBehalf, bytes memory callbackData)
        internal
        view
        returns (bytes memory)
    {
        return abi.encodeCall(MorphoBundler.morphoSupplyCollateral, (marketParams, amount, onBehalf, callbackData));
    }

    function _erc20TransferFrom2Call(address asset, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(Permit2Bundler.transferFrom2, (asset, amount));
    }

    function _erc20Approve2Call(uint256 privateKey, address asset, uint160 amount, address spender, uint48 nonce)
        internal
        view
        returns (bytes memory)
    {
        bytes32 digest = SigUtils.toTypedDataHash(
            Permit2Lib.PERMIT2.DOMAIN_SEPARATOR(),
            IAllowanceTransfer.PermitSingle({
                details: IAllowanceTransfer.PermitDetails({
                    token: asset,
                    amount: amount,
                    expiration: type(uint48).max,
                    nonce: nonce
                }),
                spender: spender,
                sigDeadline: SIGNATURE_DEADLINE
            })
        );

        Signature memory sig;
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        return abi.encodeCall(Permit2Bundler.approve2, (asset, amount, SIGNATURE_DEADLINE, sig, false));
    }

    function _erc4626DepositCall(address vault, uint256 amount, address receiver)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(ERC4626Bundler.erc4626Deposit, (vault, amount, receiver));
    }

    function _provideLiquidity(uint256 liquidity) internal {
        deal(marketParams.loanToken, address(this), liquidity);
        ERC20(marketParams.loanToken).safeApprove(address(morpho), liquidity);
        morpho.supply(marketParams, liquidity, 0, address(this), hex"");
    }

    function _assertBorrowerPosition(uint256 collateralSupplied, uint256 borrowed, address user, address bundler)
        internal
    {
        assertEq(morpho.expectedSupplyBalance(marketParams, user), 0, "supply != 0");
        assertEq(morpho.collateral(marketParams.id(), user), collateralSupplied, "wrong collateral supply amount");
        assertEq(morpho.expectedBorrowBalance(marketParams, user), borrowed, "wrong borrow amount");
        assertFalse(morpho.isAuthorized(user, bundler), "authorization not revoked");
    }

    function _assertSupplierPosition(uint256 supplied, address user, address bundler) internal {
        assertEq(morpho.expectedSupplyBalance(marketParams, user), supplied, "wrong supply amount");
        assertEq(morpho.collateral(marketParams.id(), user), 0, "collateral supplied != 0");
        assertEq(morpho.expectedBorrowBalance(marketParams, user), 0, "borrow != 0");
        assertFalse(morpho.isAuthorized(user, bundler), "authorization not revoked");
    }

    function _assertVaultSupplierPosition(uint256 supplied, address user, address bundler) internal {
        uint256 shares = suppliersVault.balanceOf(user);
        assertEq(suppliersVault.convertToAssets(shares), supplied, "wrong supply amount");
        assertFalse(morpho.isAuthorized(user, bundler), "authorization not revoked");
    }
}
