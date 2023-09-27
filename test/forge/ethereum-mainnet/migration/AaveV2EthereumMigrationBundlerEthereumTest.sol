// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ILendingPool} from "@morpho-v1/aave-v2/interfaces/aave/ILendingPool.sol";
import {IAToken} from "@morpho-v1/aave-v2/interfaces/aave/IAToken.sol";
import {IERC4626} from "@openzeppelin/interfaces/IERC4626.sol";
import {IStEth} from "src/interfaces/IStEth.sol";

import {StEthBundler} from "src/StEthBundler.sol";
import "src/ethereum-mainnet/migration/AaveV2EthereumMigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract AaveV2EthereumMigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    AaveV2EthereumMigrationBundler bundler;

    uint256 collateralSupplied = 10_000 ether;
    uint256 borrowed = 1 ether;

    function setUp() public override {
        super.setUp();

        _initMarket(DAI, WETH);

        vm.label(AAVE_V2_POOL, "Aave V2 Pool");

        bundler = new AaveV2EthereumMigrationBundler(address(morpho));
    }

    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(AAVE_V2_POOL, collateralSupplied);
        ILendingPool(AAVE_V2_POOL).deposit(marketParams.collateralToken, collateralSupplied, user, 0);
        ILendingPool(AAVE_V2_POOL).borrow(marketParams.loanToken, borrowed, 2, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV2(marketParams.collateralToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bytes[] memory data = new bytes[](1);
        bytes[] memory callbackData = new bytes[](7);

        callbackData[0] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0);
        callbackData[1] = _morphoBorrowCall(borrowed, address(bundler));
        callbackData[2] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1);
        callbackData[3] = _aaveV2RepayCall(marketParams.loanToken, borrowed, 2);
        callbackData[4] = _erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0);
        callbackData[5] = _erc20TransferFrom2Call(aToken, aTokenBalance);
        callbackData[6] = _aaveV2WithdrawCall(marketParams.collateralToken, collateralSupplied, address(bundler));
        data[0] = _morphoSupplyCollateralCall(collateralSupplied, user, abi.encode(callbackData));

        vm.prank(user);
        bundler.multicall(SIGNATURE_DEADLINE, data);

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
        ILendingPool(AAVE_V2_POOL).borrow(marketParams.loanToken, borrowed, 2, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV2(DAI);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        uint256 sDaiAmount = IERC4626(S_DAI).previewDeposit(collateralSupplied);

        bytes[] memory data = new bytes[](1);
        bytes[] memory callbackData = new bytes[](8);

        callbackData[0] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0);
        callbackData[1] = _morphoBorrowCall(borrowed, address(bundler));
        callbackData[2] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1);
        callbackData[3] = _aaveV2RepayCall(marketParams.loanToken, borrowed, 2);
        callbackData[4] = _erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0);
        callbackData[5] = _erc20TransferFrom2Call(aToken, aTokenBalance);
        callbackData[6] = _aaveV2WithdrawCall(DAI, collateralSupplied, address(bundler));
        callbackData[7] = _erc4626DepositCall(S_DAI, collateralSupplied, address(bundler));
        data[0] = _morphoSupplyCollateralCall(sDaiAmount, user, abi.encode(callbackData));

        vm.prank(user);
        bundler.multicall(SIGNATURE_DEADLINE, data);

        _assertBorrowerPosition(sDaiAmount, borrowed, user, address(bundler));
    }

    function testMigrateStEthPositionWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _initMarket(WST_ETH, WETH);
        _provideLiquidity(borrowed);

        vm.deal(user, collateralSupplied);
        vm.prank(user);
        IStEth(ST_ETH).submit{value: collateralSupplied}(address(0));

        vm.startPrank(user);
        ERC20(ST_ETH).safeApprove(AAVE_V2_POOL, collateralSupplied);
        ILendingPool(AAVE_V2_POOL).deposit(ST_ETH, collateralSupplied, user, 0);
        ILendingPool(AAVE_V2_POOL).borrow(marketParams.loanToken, borrowed, 2, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV2(ST_ETH);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        uint256 wstEthAmount = IStEth(ST_ETH).getSharesByPooledEth(collateralSupplied - 4);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bytes[] memory data = new bytes[](1);
        bytes[] memory callbackData = new bytes[](8);

        callbackData[0] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0);
        callbackData[1] = _morphoBorrowCall(borrowed, address(bundler));
        callbackData[2] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1);
        callbackData[3] = _aaveV2RepayCall(marketParams.loanToken, borrowed, 2);
        callbackData[4] = _erc20Approve2Call(privateKey, aToken, type(uint160).max, address(bundler), 0);
        callbackData[5] = _erc20TransferFrom2Call(aToken, aTokenBalance);
        callbackData[6] = _aaveV2WithdrawCall(ST_ETH, type(uint256).max, address(bundler));
        // The amount of stEth is decreased by 1 beceause of roundings at each transfer.
        callbackData[7] = _wrapStEthCall(collateralSupplied - 4);
        data[0] = _morphoSupplyCollateralCall(wstEthAmount - 2, user, abi.encode(callbackData));

        vm.prank(user);
        bundler.multicall(SIGNATURE_DEADLINE, data);

        _assertBorrowerPosition(wstEthAmount - 2, borrowed, user, address(bundler));
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

        bytes[] memory data = new bytes[](4);

        data[0] = _erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0);
        data[1] = _erc20TransferFrom2Call(aToken, aTokenBalance);
        data[2] = _aaveV2WithdrawCall(marketParams.loanToken, supplied, address(bundler));
        data[3] = _morphoSupplyCall(supplied, user, hex"");

        vm.prank(user);
        bundler.multicall(SIGNATURE_DEADLINE, data);

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

        bytes[] memory data = new bytes[](4);

        data[0] = _erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0);
        data[1] = _erc20TransferFrom2Call(aToken, aTokenBalance);
        data[2] = _aaveV2WithdrawCall(marketParams.loanToken, supplied, address(bundler));
        data[3] = _erc4626DepositCall(address(suppliersVault), supplied, user);

        vm.prank(user);
        bundler.multicall(SIGNATURE_DEADLINE, data);

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

    function _wrapStEthCall(uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(StEthBundler.wrapStEth, (amount));
    }
}
