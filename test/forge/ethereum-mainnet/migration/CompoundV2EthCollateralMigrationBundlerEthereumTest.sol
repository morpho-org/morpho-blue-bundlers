// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IComptroller} from "src/migration/interfaces/IComptroller.sol";

import "src/migration/CompoundV2MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract CompoundV2EthCollateralMigrationBundlerEthereumTest is EthereumMigrationTest {
    using MathLib for uint256;
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    CompoundV2MigrationBundler internal bundler;

    address[] internal enteredMarkets;

    function setUp() public override {
        super.setUp();

        _initMarket(WETH, DAI);

        bundler = new CompoundV2MigrationBundler(address(morpho), WETH, C_ETH_V2);

        enteredMarkets.push(C_ETH_V2);
    }

    function testCompoundV2RepayZeroAmount() public {
        bundle.push(_compoundV2RepayCall(C_DAI_V2, 0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testCompoundV2RepayErr(uint256 privateKey, uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        deal(DAI, address(bundler), amount);

        vm.mockCall(C_DAI_V2, abi.encodeWithSelector(ICToken.repayBorrowBehalf.selector), abi.encode(1));

        bundle.push(_compoundV2RepayCall(C_DAI_V2, amount));

        vm.prank(user);
        vm.expectRevert(bytes(ErrorsLib.REPAY_ERROR));
        bundler.multicall(SIGNATURE_DEADLINE, bundle);
    }

    function testCompoundV2RedeemErr(uint256 privateKey, uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        deal(C_DAI_V2, address(bundler), amount);

        vm.mockCall(C_DAI_V2, abi.encodeWithSelector(ICToken.redeem.selector), abi.encode(1));

        bundle.push(_compoundV2RedeemCall(C_DAI_V2, amount));

        vm.prank(user);
        vm.expectRevert(bytes(ErrorsLib.REDEEM_ERROR));
        bundler.multicall(SIGNATURE_DEADLINE, bundle);
    }

    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        uint256 collateral = 10 ether;
        uint256 borrowed = 1 ether;

        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(user, collateral);

        vm.startPrank(user);
        ICEth(C_ETH_V2).mint{value: collateral}();
        require(IComptroller(COMPTROLLER).enterMarkets(enteredMarkets)[0] == 0, "enter market error");
        require(ICToken(C_DAI_V2).borrow(borrowed) == 0, "borrow error");
        vm.stopPrank();

        uint256 cTokenBalance = ICEth(C_ETH_V2).balanceOf(user);
        collateral = cTokenBalance.wMulDown(ICToken(C_ETH_V2).exchangeRateStored());

        vm.prank(user);
        ERC20(C_ETH_V2).safeApprove(address(Permit2Lib.PERMIT2), cTokenBalance);

        callbackBundle.push(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0));
        callbackBundle.push(_morphoBorrowCall(borrowed, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1));
        callbackBundle.push(_compoundV2RepayCall(C_DAI_V2, borrowed));
        callbackBundle.push(_erc20Approve2Call(privateKey, C_ETH_V2, uint160(cTokenBalance), address(bundler), 0));
        callbackBundle.push(_erc20TransferFrom2Call(C_ETH_V2, cTokenBalance));
        callbackBundle.push(_compoundV2RedeemCall(C_ETH_V2, cTokenBalance));
        callbackBundle.push(abi.encodeCall(WNativeBundler.wrapNative, (collateral)));

        bundle.push(_morphoSupplyCollateralCall(collateral, user, abi.encode(callbackBundle)));

        vm.prank(user);
        bundler.multicall(SIGNATURE_DEADLINE, bundle);

        _assertBorrowerPosition(collateral, borrowed, user, address(bundler));
    }

    function _compoundV2RepayCall(address cToken, uint256 repayAmount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV2MigrationBundler.compoundV2Repay, (cToken, repayAmount));
    }

    function _compoundV2RedeemCall(address cToken, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV2MigrationBundler.compoundV2Redeem, (cToken, amount));
    }
}
