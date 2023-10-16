// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IComptroller} from "../../../src/migration/interfaces/IComptroller.sol";

import "../../../src/migration/CompoundV2MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract CompoundV2EthCollateralMigrationBundlerEthereumTest is EthereumMigrationTest {
    using MathLib for uint256;
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    address[] internal enteredMarkets;

    function setUp() public override {
        super.setUp();

        _initMarket(WETH, DAI);

        bundler = new CompoundV2MigrationBundler(address(morpho), WETH, C_ETH_V2);

        enteredMarkets.push(C_ETH_V2);
    }

    function testCompoundV2RepayZeroAmount() public {
        bundle.push(_compoundV2Repay(C_DAI_V2, 0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }

    function testCompoundV2RepayErr(uint256 privateKey, uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);

        deal(DAI, address(bundler), amount);

        vm.mockCall(C_DAI_V2, abi.encodeWithSelector(ICToken.repayBorrowBehalf.selector), abi.encode(1));

        bundle.push(_compoundV2Repay(C_DAI_V2, amount));

        vm.prank(user);
        vm.expectRevert(bytes(ErrorsLib.REPAY_ERROR));
        bundler.multicall(bundle);
    }

    function testCompoundV2RedeemErr(uint256 privateKey, uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);

        deal(C_DAI_V2, address(bundler), amount);

        vm.mockCall(C_DAI_V2, abi.encodeWithSelector(ICToken.redeem.selector), abi.encode(1));

        bundle.push(_compoundV2Redeem(C_DAI_V2, amount));

        vm.prank(user);
        vm.expectRevert(bytes(ErrorsLib.REDEEM_ERROR));
        bundler.multicall(bundle);
    }

    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        uint256 collateral = 10 ether;
        uint256 borrowed = 1 ether;

        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);

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

        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, true, 0, false));
        callbackBundle.push(_morphoBorrow(marketParams, borrowed, 0, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, false, 1, false));
        callbackBundle.push(_compoundV2Repay(C_DAI_V2, borrowed));
        callbackBundle.push(_permit2TransferFrom(privateKey, C_ETH_V2, cTokenBalance, 0));
        callbackBundle.push(_compoundV2Redeem(C_ETH_V2, cTokenBalance));
        callbackBundle.push(_wrapNative(collateral));

        bundle.push(_morphoSupplyCollateral(marketParams, collateral, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(collateral, borrowed, user, address(bundler));
    }

    /* ACTIONS */

    function _compoundV2Repay(address cToken, uint256 repayAmount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV2MigrationBundler.compoundV2Repay, (cToken, repayAmount));
    }

    function _compoundV2Redeem(address cToken, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV2MigrationBundler.compoundV2Redeem, (cToken, amount));
    }
}
