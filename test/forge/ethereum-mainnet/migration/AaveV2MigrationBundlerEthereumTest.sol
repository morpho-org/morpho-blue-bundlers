// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ILendingPool} from "@morpho-v1/aave-v2/interfaces/aave/ILendingPool.sol";
import {IAToken} from "@morpho-v1/aave-v2/interfaces/aave/IAToken.sol";

import {AaveV2MigrationBundler} from "contracts/migration/AaveV2MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract AaveV2MigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    AaveV2MigrationBundler bundler;

    uint256 collateralSupplied = 10_000 ether;
    uint256 borrowed = 1 ether;

    function setUp() public override {
        super.setUp();

        _initMarket(DAI, WETH);

        vm.label(AAVE_V2_POOL, "Aave V2 Pool");

        bundler = new AaveV2MigrationBundler(address(morpho), address(AAVE_V2_POOL));
        vm.label(address(bundler), "Aave V2 Migration Bundler");
    }

    /// forge-config: default.fuzz.runs = 3
    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(AAVE_V2_POOL, collateralSupplied);
        ILendingPool(AAVE_V2_POOL).deposit(marketParams.collateralToken, collateralSupplied, user, 0);
        ILendingPool(AAVE_V2_POOL).borrow(marketParams.borrowableToken, borrowed, 2, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV2(marketParams.collateralToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        callbackBundle.push(Call(_morphoBorrowCall(borrowed, address(bundler)), false));
        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1), false));
        callbackBundle.push(Call(_aaveV2RepayCall(marketParams.borrowableToken, borrowed, 2), false));
        callbackBundle.push(
            Call(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0), false)
        );
        callbackBundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        callbackBundle.push(
            Call(_aaveV2WithdrawCall(marketParams.collateralToken, collateralSupplied, address(bundler)), false)
        );
        bundle.push(Call(_morphoSupplyCollateralCall(collateralSupplied, user, abi.encode(callbackBundle)), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(AAVE_V2_POOL, supplied + 1);
        ILendingPool(AAVE_V2_POOL).deposit(marketParams.borrowableToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV2(marketParams.borrowableToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bundle.push(Call(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        bundle.push(Call(_aaveV2WithdrawCall(marketParams.borrowableToken, supplied, address(bundler)), false));
        bundle.push(Call(_morphoSupplyCall(supplied, user, hex""), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(AAVE_V2_POOL, supplied + 1);
        ILendingPool(AAVE_V2_POOL).deposit(marketParams.borrowableToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV2(marketParams.borrowableToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bundle.push(Call(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        bundle.push(Call(_aaveV2WithdrawCall(marketParams.borrowableToken, supplied, address(bundler)), false));
        bundle.push(Call(_erc4626DepositCall(address(suppliersVault), supplied, user), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function _getATokenV2(address asset) internal view returns (address) {
        return ILendingPool(AAVE_V2_POOL).getReserveData(asset).aTokenAddress;
    }

    function _aaveV2RepayCall(address asset, uint256 amount, uint256 rateMode) internal pure returns (bytes memory) {
        return abi.encodeCall(AaveV2MigrationBundler.aaveV2Repay, (asset, amount, rateMode));
    }

    function _aaveV2WithdrawCall(address asset, uint256 amount, address to) internal pure returns (bytes memory) {
        return abi.encodeCall(AaveV2MigrationBundler.aaveV2Withdraw, (asset, amount, to));
    }
}
