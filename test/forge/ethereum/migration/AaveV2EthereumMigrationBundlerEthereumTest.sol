// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ILendingPool} from "@morpho-v1/aave-v2/interfaces/aave/ILendingPool.sol";
import {IAToken} from "@morpho-v1/aave-v2/interfaces/aave/IAToken.sol";
import {IERC4626} from "@openzeppelin/interfaces/IERC4626.sol";
import {IStEth} from "src/interfaces/IStEth.sol";

import "src/ethereum/migration/AaveV2EthereumMigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract AaveV2EthereumMigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    uint256 public constant RATE_MODE = 2;

    uint256 collateralSupplied = 10_000 ether;
    uint256 borrowed = 1 ether;

    function setUp() public override {
        super.setUp();

        _initMarket(DAI, WETH);

        vm.label(AAVE_V2_POOL, "Aave V2 Pool");

        bundler = new AaveV2EthereumMigrationBundler(address(morpho));
    }

    function testAaveV2RepayZeroAmount() public {
        bundle.push(_aaveV2Repay(marketParams.loanToken, 0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }

    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(AAVE_V2_POOL, collateralSupplied);
        ILendingPool(AAVE_V2_POOL).deposit(marketParams.collateralToken, collateralSupplied, user, 0);
        ILendingPool(AAVE_V2_POOL).borrow(marketParams.loanToken, borrowed, RATE_MODE, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV2(marketParams.collateralToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, true, 0, false));
        callbackBundle.push(_morphoBorrow(marketParams, borrowed, 0, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, false, 1, false));
        callbackBundle.push(_aaveV2Repay(marketParams.loanToken, borrowed));
        callbackBundle.push(_permit2TransferFrom(privateKey, aToken, aTokenBalance, 0));
        callbackBundle.push(_aaveV2Withdraw(marketParams.collateralToken, collateralSupplied, address(bundler)));

        bundle.push(_morphoSupplyCollateral(marketParams, collateralSupplied, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateBorrowerDaiToSDaiWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _initMarket(S_DAI, WETH);
        _provideLiquidity(borrowed);

        deal(DAI, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(DAI).safeApprove(AAVE_V2_POOL, collateralSupplied);
        ILendingPool(AAVE_V2_POOL).deposit(DAI, collateralSupplied, user, 0);
        ILendingPool(AAVE_V2_POOL).borrow(marketParams.loanToken, borrowed, RATE_MODE, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV2(DAI);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        uint256 sDaiAmount = IERC4626(S_DAI).previewDeposit(collateralSupplied);

        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, true, 0, false));
        callbackBundle.push(_morphoBorrow(marketParams, borrowed, 0, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, false, 1, false));
        callbackBundle.push(_aaveV2Repay(marketParams.loanToken, borrowed));
        callbackBundle.push(_permit2TransferFrom(privateKey, aToken, aTokenBalance, 0));
        callbackBundle.push(_aaveV2Withdraw(DAI, collateralSupplied, address(bundler)));
        callbackBundle.push(_erc4626Deposit(S_DAI, collateralSupplied, address(bundler)));

        bundle.push(_morphoSupplyCollateral(marketParams, sDaiAmount, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(sDaiAmount, borrowed, user, address(bundler));
    }

    function testMigrateStEthPositionWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _initMarket(WST_ETH, WETH);
        _provideLiquidity(borrowed);

        deal(ST_ETH, user, collateralSupplied);

        collateralSupplied = ERC20(ST_ETH).balanceOf(user);

        vm.startPrank(user);
        ERC20(ST_ETH).safeApprove(AAVE_V2_POOL, collateralSupplied);
        ILendingPool(AAVE_V2_POOL).deposit(ST_ETH, collateralSupplied, user, 0);
        ILendingPool(AAVE_V2_POOL).borrow(marketParams.loanToken, borrowed, RATE_MODE, 0, user);
        vm.stopPrank();

        // The amount of stEth as collateral is decreased by 10 beceause of roundings.
        collateralSupplied -= 10;

        address aToken = _getATokenV2(ST_ETH);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        uint256 wstEthAmount = IStEth(ST_ETH).getSharesByPooledEth(collateralSupplied);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, true, 0, false));
        callbackBundle.push(_morphoBorrow(marketParams, borrowed, 0, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, false, 1, false));
        callbackBundle.push(_aaveV2Repay(marketParams.loanToken, borrowed));
        callbackBundle.push(_permit2TransferFrom(privateKey, aToken, type(uint256).max, 0));
        callbackBundle.push(_aaveV2Withdraw(ST_ETH, type(uint256).max, address(bundler)));
        callbackBundle.push(_wrapStEth(type(uint256).max));

        bundle.push(_morphoSupplyCollateral(marketParams, wstEthAmount, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(wstEthAmount, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.loanToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(AAVE_V2_POOL, supplied + 1);
        ILendingPool(AAVE_V2_POOL).deposit(marketParams.loanToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV2(marketParams.loanToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bundle.push(_permit2TransferFrom(privateKey, aToken, aTokenBalance, 0));
        bundle.push(_aaveV2Withdraw(marketParams.loanToken, supplied, address(bundler)));
        bundle.push(_morphoSupply(marketParams, supplied, 0, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.loanToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(AAVE_V2_POOL, supplied + 1);
        ILendingPool(AAVE_V2_POOL).deposit(marketParams.loanToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV2(marketParams.loanToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bundle.push(_permit2TransferFrom(privateKey, aToken, aTokenBalance, 0));
        bundle.push(_aaveV2Withdraw(marketParams.loanToken, supplied, address(bundler)));
        bundle.push(_erc4626Deposit(address(suppliersVault), supplied, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function _getATokenV2(address asset) internal view returns (address) {
        return ILendingPool(AAVE_V2_POOL).getReserveData(asset).aTokenAddress;
    }

    /* ACTIONS */

    function _aaveV2Repay(address asset, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(AaveV2MigrationBundler.aaveV2Repay, (asset, amount, RATE_MODE));
    }

    function _aaveV2Withdraw(address asset, uint256 amount, address to) internal pure returns (bytes memory) {
        return abi.encodeCall(AaveV2MigrationBundler.aaveV2Withdraw, (asset, amount, to));
    }
}
