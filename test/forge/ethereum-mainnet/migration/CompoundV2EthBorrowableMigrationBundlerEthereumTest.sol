// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ICEth} from "contracts/migration/interfaces/ICEth.sol";
import {ICToken} from "contracts/migration/interfaces/ICToken.sol";
import {ICEth} from "contracts/migration/interfaces/ICEth.sol";
import {IComptroller} from "contracts/migration/interfaces/IComptroller.sol";

import {CompoundV2MigrationBundler} from "contracts/migration/CompoundV2MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract CompoundV2EthBorrowableMigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    CompoundV2MigrationBundler bundler;

    mapping(address => address) _cTokens;

    address collateralCToken;

    uint256 collateralSupplied = 10_000 ether;
    uint256 borrowed = 1 ether;

    function setUp() public override {
        super.setUp();

        _initMarket(DAI, WETH);

        vm.label(C_ETH_V2, "cETHv2");
        _cTokens[WETH] = C_ETH_V2;
        vm.label(C_DAI_V2, "cDAIv2");
        _cTokens[DAI] = C_DAI_V2;
        vm.label(C_USDC_V2, "cUSDCv2");
        _cTokens[USDC] = C_USDC_V2;

        bundler = new CompoundV2MigrationBundler(address(morpho), WETH, C_ETH_V2);
        vm.label(address(bundler), "Compound V2 Migration Bundler");

        collateralCToken = _getCToken(DAI);
    }

    /// forge-config: default.fuzz.runs = 3
    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(collateralCToken, collateralSupplied);
        require(ICToken(collateralCToken).mint(collateralSupplied) == 0, "mint error");
        address[] memory enteredMarkets = new address[](1);
        enteredMarkets[0] = collateralCToken;
        require(IComptroller(COMPTROLLER).enterMarkets(enteredMarkets)[0] == 0, "enter market error");
        require(ICEth(C_ETH_V2).borrow(borrowed) == 0, "borrow error");
        vm.stopPrank();

        uint256 cTokenBalance = ICToken(collateralCToken).balanceOf(user);

        vm.prank(user);
        ERC20(collateralCToken).safeApprove(address(Permit2Lib.PERMIT2), cTokenBalance);

        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        callbackBundle.push(Call(_morphoBorrowCall(borrowed, address(bundler)), false));
        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1), false));
        callbackBundle.push(Call(_compoundV2RepayCall(C_ETH_V2, borrowed), false));
        callbackBundle.push(
            Call(_erc20Approve2Call(privateKey, collateralCToken, uint160(cTokenBalance), address(bundler), 0), false)
        );
        callbackBundle.push(Call(_erc20TransferFrom2Call(collateralCToken, cTokenBalance), false));
        callbackBundle.push(Call(_compoundV2WithdrawCall(collateralCToken, collateralSupplied), false));

        bundle.push(Call(_morphoSupplyCollateralCall(collateralSupplied, user, abi.encode(callbackBundle)), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 0.1 ether, 100 ether);

        deal(user, supplied);

        vm.prank(user);
        ICEth(C_ETH_V2).mint{value: supplied}();

        uint256 cTokenBalance = ICEth(C_ETH_V2).balanceOf(user);

        vm.prank(user);
        ERC20(C_ETH_V2).safeApprove(address(Permit2Lib.PERMIT2), cTokenBalance);

        bundle.push(Call(_erc20Approve2Call(privateKey, C_ETH_V2, uint160(cTokenBalance), address(bundler), 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(C_ETH_V2, cTokenBalance), false));
        bundle.push(Call(_compoundV2WithdrawCall(C_ETH_V2, supplied), false));
        bundle.push(Call(_morphoSupplyCall(supplied, user, hex""), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 0.1 ether, 100 ether);

        deal(user, supplied);

        vm.prank(user);
        ICEth(C_ETH_V2).mint{value: supplied}();

        uint256 cTokenBalance = ICEth(C_ETH_V2).balanceOf(user);

        vm.prank(user);
        ERC20(C_ETH_V2).safeApprove(address(Permit2Lib.PERMIT2), cTokenBalance);

        bundle.push(Call(_erc20Approve2Call(privateKey, C_ETH_V2, uint160(cTokenBalance), address(bundler), 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(C_ETH_V2, cTokenBalance), false));
        bundle.push(Call(_compoundV2WithdrawCall(C_ETH_V2, supplied), false));
        bundle.push(Call(_erc4626DepositCall(address(suppliersVault), supplied, user), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function _getCToken(address asset) internal view returns (address res) {
        res = _cTokens[asset];
        require(res != address(0), "unknown compound v2 asset");
    }

    function _compoundV2RepayCall(address cToken, uint256 repayAmount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV2MigrationBundler.compoundV2Repay, (cToken, repayAmount));
    }

    function _compoundV2WithdrawCall(address cToken, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV2MigrationBundler.compoundV2Redeem, (cToken, amount));
    }
}
