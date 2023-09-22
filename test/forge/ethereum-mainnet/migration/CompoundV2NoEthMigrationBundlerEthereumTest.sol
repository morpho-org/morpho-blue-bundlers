// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IComptroller} from "src/migration/interfaces/IComptroller.sol";

import "src/migration/CompoundV2MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract CompoundV2NoEthMigrationBundlerEthereumTest is EthereumMigrationTest {
    using MathLib for uint256;
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    CompoundV2MigrationBundler bundler;

    address[] internal enteredMarkets;

    function setUp() public override {
        super.setUp();

        _initMarket(DAI, USDC);

        bundler = new CompoundV2MigrationBundler(address(morpho), WETH, C_ETH_V2);

        enteredMarkets.push(C_DAI_V2);
    }

    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        uint256 collateral = 10 ether;
        uint256 borrowed = 1e6;

        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateral);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(C_DAI_V2, collateral);
        require(ICToken(C_DAI_V2).mint(collateral) == 0, "mint error");
        require(IComptroller(COMPTROLLER).enterMarkets(enteredMarkets)[0] == 0, "enter market error");
        require(ICToken(C_USDC_V2).borrow(borrowed) == 0, "borrow error");
        vm.stopPrank();

        uint256 cTokenBalance = ICToken(C_DAI_V2).balanceOf(user);
        collateral = cTokenBalance.wMulDown(ICToken(C_DAI_V2).exchangeRateStored());

        vm.prank(user);
        ERC20(C_DAI_V2).safeApprove(address(Permit2Lib.PERMIT2), cTokenBalance);

        bytes[] memory data = new bytes[](1);
        bytes[] memory callbackData = new bytes[](7);

        callbackData[0] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0);
        callbackData[1] = _morphoBorrowCall(borrowed, address(bundler));
        callbackData[2] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1);
        callbackData[3] = _compoundV2RepayCall(C_USDC_V2, borrowed);
        callbackData[4] = _erc20Approve2Call(privateKey, C_DAI_V2, uint160(cTokenBalance), address(bundler), 0);
        callbackData[5] = _erc20TransferFrom2Call(C_DAI_V2, cTokenBalance);
        callbackData[6] = _compoundV2RedeemCall(C_DAI_V2, cTokenBalance);
        data[0] = _morphoSupplyCollateralCall(collateral, user, abi.encode(callbackData));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, data);

        _assertBorrowerPosition(collateral, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(C_USDC_V2, supplied);
        require(ICToken(C_USDC_V2).mint(supplied) == 0, "mint error");
        vm.stopPrank();

        uint256 cTokenBalance = ICToken(C_USDC_V2).balanceOf(user);
        supplied = cTokenBalance.wMulDown(ICToken(C_USDC_V2).exchangeRateStored());

        vm.prank(user);
        ERC20(C_USDC_V2).safeApprove(address(Permit2Lib.PERMIT2), cTokenBalance);

        bytes[] memory data = new bytes[](4);

        data[0] = _erc20Approve2Call(privateKey, C_USDC_V2, uint160(cTokenBalance), address(bundler), 0);
        data[1] = _erc20TransferFrom2Call(C_USDC_V2, cTokenBalance);
        data[2] = _compoundV2RedeemCall(C_USDC_V2, cTokenBalance);
        data[3] = _morphoSupplyCall(supplied, user, hex"");

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, data);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(C_USDC_V2, supplied);
        require(ICToken(C_USDC_V2).mint(supplied) == 0, "mint error");
        vm.stopPrank();

        uint256 cTokenBalance = ICToken(C_USDC_V2).balanceOf(user);
        supplied = cTokenBalance.wMulDown(ICToken(C_USDC_V2).exchangeRateStored());

        vm.prank(user);
        ERC20(C_USDC_V2).safeApprove(address(Permit2Lib.PERMIT2), cTokenBalance);

        bytes[] memory data = new bytes[](4);

        data[0] = _erc20Approve2Call(privateKey, C_USDC_V2, uint160(cTokenBalance), address(bundler), 0);
        data[1] = _erc20TransferFrom2Call(C_USDC_V2, cTokenBalance);
        data[2] = _compoundV2RedeemCall(C_USDC_V2, cTokenBalance);
        data[3] = _erc4626DepositCall(address(suppliersVault), supplied, user);

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, data);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function _compoundV2RepayCall(address cToken, uint256 repayAmount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV2MigrationBundler.compoundV2Repay, (cToken, repayAmount));
    }

    function _compoundV2RedeemCall(address cToken, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV2MigrationBundler.compoundV2Redeem, (cToken, amount));
    }
}
