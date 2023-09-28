// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IPool} from "@aave/v3-core/interfaces/IPool.sol";
import {IAToken} from "@aave/v3-core/interfaces/IAToken.sol";

import {SigUtils, Permit} from "test/forge/helpers/SigUtils.sol";
import "src/migration/AaveV3MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract AaveV3MigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    uint256 public constant RATE_MODE = 2;

    AaveV3MigrationBundler bundler;

    uint256 collateralSupplied = 10_000 ether;
    uint256 borrowed = 1 ether;

    function setUp() public override {
        super.setUp();

        _initMarket(DAI, WETH);

        vm.label(AAVE_V3_POOL, "Aave V3 Pool");

        bundler = new AaveV3MigrationBundler(address(morpho), address(AAVE_V3_POOL));
        vm.label(address(bundler), "Aave V3 Migration Bundler");
    }

    function testMigrateBorrowerWithATokenPermit(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(AAVE_V3_POOL, collateralSupplied);
        IPool(AAVE_V3_POOL).supply(marketParams.collateralToken, collateralSupplied, user, 0);
        IPool(AAVE_V3_POOL).borrow(marketParams.loanToken, borrowed, RATE_MODE, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.collateralToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        callbackBundle.push(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0));
        callbackBundle.push(_morphoBorrowCall(borrowed, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1));
        callbackBundle.push(_aaveV3RepayCall(marketParams.loanToken, borrowed));
        callbackBundle.push(_aaveV3PermitATokenCall(aToken, privateKey, aTokenBalance));
        callbackBundle.push(_erc20TransferFromCall(aToken, aTokenBalance));
        callbackBundle.push(_aaveV3WithdrawCall(marketParams.collateralToken, collateralSupplied, address(bundler)));

        bundle.push(_morphoSupplyCollateralCall(collateralSupplied, user, abi.encode(callbackBundle)));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(AAVE_V3_POOL, collateralSupplied);
        IPool(AAVE_V3_POOL).supply(marketParams.collateralToken, collateralSupplied, user, 0);
        IPool(AAVE_V3_POOL).borrow(marketParams.loanToken, borrowed, RATE_MODE, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.collateralToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        callbackBundle.push(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0));
        callbackBundle.push(_morphoBorrowCall(borrowed, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1));
        callbackBundle.push(_aaveV3RepayCall(marketParams.loanToken, borrowed));
        callbackBundle.push(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0));
        callbackBundle.push(_erc20TransferFrom2Call(aToken, aTokenBalance));
        callbackBundle.push(_aaveV3WithdrawCall(marketParams.collateralToken, collateralSupplied, address(bundler)));

        bundle.push(_morphoSupplyCollateralCall(collateralSupplied, user, abi.encode(callbackBundle)));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateUSDTPositionWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        uint256 amountUsdt = collateralSupplied / 1e10;

        _initMarket(USDT, WETH);
        _provideLiquidity(borrowed);

        oracle.setPrice(1e46);
        deal(USDT, user, amountUsdt);

        vm.startPrank(user);
        ERC20(USDT).safeApprove(AAVE_V3_POOL, amountUsdt);
        IPool(AAVE_V3_POOL).supply(USDT, amountUsdt, user, 0);
        IPool(AAVE_V3_POOL).borrow(marketParams.loanToken, borrowed, RATE_MODE, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV3(USDT);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        callbackBundle.push(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0));
        callbackBundle.push(_morphoBorrowCall(borrowed, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1));
        callbackBundle.push(_aaveV3RepayCall(marketParams.loanToken, borrowed));
        callbackBundle.push(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0));
        callbackBundle.push(_erc20TransferFrom2Call(aToken, aTokenBalance));
        callbackBundle.push(_aaveV3WithdrawCall(USDT, amountUsdt, address(bundler)));

        bundle.push(_morphoSupplyCollateralCall(amountUsdt, user, abi.encode(callbackBundle)));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(amountUsdt, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithATokenPermit(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.loanToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(AAVE_V3_POOL, supplied + 1);
        IPool(AAVE_V3_POOL).supply(marketParams.loanToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.loanToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        bundle.push(_aaveV3PermitATokenCall(aToken, privateKey, aTokenBalance));
        bundle.push(_erc20TransferFromCall(aToken, aTokenBalance));
        bundle.push(_aaveV3WithdrawCall(marketParams.loanToken, supplied, address(bundler)));
        bundle.push(_morphoSupplyCall(supplied, user, hex""));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.loanToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(AAVE_V3_POOL, supplied + 1);
        IPool(AAVE_V3_POOL).supply(marketParams.loanToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.loanToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bundle.push(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0));
        bundle.push(_erc20TransferFrom2Call(aToken, aTokenBalance));
        bundle.push(_aaveV3WithdrawCall(marketParams.loanToken, supplied, address(bundler)));
        bundle.push(_morphoSupplyCall(supplied, user, hex""));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithATokenPermit(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.loanToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(AAVE_V3_POOL, supplied + 1);
        IPool(AAVE_V3_POOL).supply(marketParams.loanToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.loanToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        bundle.push(_aaveV3PermitATokenCall(aToken, privateKey, aTokenBalance));
        bundle.push(_erc20TransferFromCall(aToken, aTokenBalance));
        bundle.push(_aaveV3WithdrawCall(marketParams.loanToken, supplied, address(bundler)));
        bundle.push(_erc4626DepositCall(address(suppliersVault), supplied, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.loanToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(AAVE_V3_POOL, supplied + 1);
        IPool(AAVE_V3_POOL).supply(marketParams.loanToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.loanToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bundle.push(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0));
        bundle.push(_erc20TransferFrom2Call(aToken, aTokenBalance));
        bundle.push(_aaveV3WithdrawCall(marketParams.loanToken, supplied, address(bundler)));
        bundle.push(_erc4626DepositCall(address(suppliersVault), supplied, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function _getATokenV3(address asset) internal view returns (address) {
        return IPool(AAVE_V3_POOL).getReserveData(asset).aTokenAddress;
    }

    function _aaveV3PermitATokenCall(address aToken, uint256 privateKey, uint256 amount)
        internal
        view
        returns (bytes memory)
    {
        address user = vm.addr(privateKey);
        uint256 nonce = IAToken(aToken).nonces(user);

        Permit memory permit = Permit(user, address(bundler), amount, nonce, SIGNATURE_DEADLINE);
        bytes32 hashed = SigUtils.toTypedDataHash(IAToken(aToken).DOMAIN_SEPARATOR(), permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hashed);

        return abi.encodeCall(PermitBundler.permit, (aToken, amount, SIGNATURE_DEADLINE, v, r, s, false));
    }

    function _aaveV3RepayCall(address asset, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(AaveV3MigrationBundler.aaveV3Repay, (asset, amount, RATE_MODE));
    }

    function _aaveV3WithdrawCall(address asset, uint256 amount, address to) internal pure returns (bytes memory) {
        return abi.encodeCall(AaveV3MigrationBundler.aaveV3Withdraw, (asset, amount, to));
    }
}
