// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IPool} from "@aave/v3-core/interfaces/IPool.sol";
import {IAToken} from "@aave/v3-core/interfaces/IAToken.sol";

import {AaveV3MigrationBundler} from "contracts/migration/AaveV3MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract AaveV3MigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

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

    /// forge-config: default.fuzz.runs = 3
    function testMigrateBorrowerWithATokenPermit(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(AAVE_V3_POOL, collateralSupplied);
        IPool(AAVE_V3_POOL).supply(marketParams.collateralToken, collateralSupplied, user, 0);
        IPool(AAVE_V3_POOL).borrow(marketParams.borrowableToken, borrowed, 2, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.collateralToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        callbackBundle.push(Call(_morphoBorrowCall(borrowed, address(bundler)), false));
        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1), false));
        callbackBundle.push(Call(_aaveV3RepayCall(marketParams.borrowableToken, borrowed, 2), false));
        callbackBundle.push(
            Call(_aaveV3PermitATokenCall(privateKey, aToken, address(bundler), aTokenBalance, 0), false)
        );
        callbackBundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        callbackBundle.push(
            Call(_aaveV3WithdrawCall(marketParams.collateralToken, collateralSupplied, address(bundler)), false)
        );
        bundle.push(Call(_morphoSupplyCollateralCall(collateralSupplied, user, abi.encode(callbackBundle)), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    /// forge-config: default.fuzz.runs = 3
    function testMigrateBorrowerWithPermit2(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(AAVE_V3_POOL, collateralSupplied);
        IPool(AAVE_V3_POOL).supply(marketParams.collateralToken, collateralSupplied, user, 0);
        IPool(AAVE_V3_POOL).borrow(marketParams.borrowableToken, borrowed, 2, 0, user);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.collateralToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        callbackBundle.push(Call(_morphoBorrowCall(borrowed, address(bundler)), false));
        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1), false));
        callbackBundle.push(Call(_aaveV3RepayCall(marketParams.borrowableToken, borrowed, 2), false));
        callbackBundle.push(
            Call(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0), false)
        );
        callbackBundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        callbackBundle.push(
            Call(_aaveV3WithdrawCall(marketParams.collateralToken, collateralSupplied, address(bundler)), false)
        );
        bundle.push(Call(_morphoSupplyCollateralCall(collateralSupplied, user, abi.encode(callbackBundle)), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithATokenPermit(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(AAVE_V3_POOL, supplied + 1);
        IPool(AAVE_V3_POOL).supply(marketParams.borrowableToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.borrowableToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        bundle.push(Call(_aaveV3PermitATokenCall(privateKey, aToken, address(bundler), aTokenBalance, 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        bundle.push(Call(_aaveV3WithdrawCall(marketParams.borrowableToken, supplied, address(bundler)), false));
        bundle.push(Call(_morphoSupplyCall(supplied, user, hex""), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(AAVE_V3_POOL, supplied + 1);
        IPool(AAVE_V3_POOL).supply(marketParams.borrowableToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.borrowableToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bundle.push(Call(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        bundle.push(Call(_aaveV3WithdrawCall(marketParams.borrowableToken, supplied, address(bundler)), false));
        bundle.push(Call(_morphoSupplyCall(supplied, user, hex""), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithATokenPermit(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(AAVE_V3_POOL, supplied + 1);
        IPool(AAVE_V3_POOL).supply(marketParams.borrowableToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.borrowableToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        bundle.push(Call(_aaveV3PermitATokenCall(privateKey, aToken, address(bundler), aTokenBalance, 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        bundle.push(Call(_aaveV3WithdrawCall(marketParams.borrowableToken, supplied, address(bundler)), false));
        bundle.push(Call(_erc4626DepositCall(address(suppliersVault), supplied, user), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(AAVE_V3_POOL, supplied + 1);
        IPool(AAVE_V3_POOL).supply(marketParams.borrowableToken, supplied + 1, user, 0);
        vm.stopPrank();

        address aToken = _getATokenV3(marketParams.borrowableToken);
        uint256 aTokenBalance = IAToken(aToken).balanceOf(user);

        vm.prank(user);
        ERC20(aToken).safeApprove(address(Permit2Lib.PERMIT2), aTokenBalance);

        bundle.push(Call(_erc20Approve2Call(privateKey, aToken, uint160(aTokenBalance), address(bundler), 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(aToken, aTokenBalance), false));
        bundle.push(Call(_aaveV3WithdrawCall(marketParams.borrowableToken, supplied, address(bundler)), false));
        bundle.push(Call(_erc4626DepositCall(address(suppliersVault), supplied, user), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function _getATokenV3(address asset) internal view returns (address) {
        return IPool(AAVE_V3_POOL).getReserveData(asset).aTokenAddress;
    }

    function _aaveV3PermitATokenCall(uint256 privateKey, address aToken, address spender, uint256 value, uint256 nonce)
        internal
        view
        returns (bytes memory)
    {
        bytes32 permitTypehash =
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        bytes32 digest = ECDSA.toTypedDataHash(
            IAToken(aToken).DOMAIN_SEPARATOR(),
            keccak256(abi.encode(permitTypehash, vm.addr(privateKey), spender, value, nonce, SIG_DEADLINE))
        );

        Signature memory sig;
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        return abi.encodeCall(
            AaveV3MigrationBundler.aaveV3PermitAToken, (aToken, value, SIG_DEADLINE, sig.v, sig.r, sig.s)
        );
    }

    function _aaveV3RepayCall(address asset, uint256 amount, uint256 interestRateMode)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(AaveV3MigrationBundler.aaveV3Repay, (asset, amount, interestRateMode));
    }

    function _aaveV3WithdrawCall(address asset, uint256 amount, address to) internal pure returns (bytes memory) {
        return abi.encodeCall(AaveV3MigrationBundler.aaveV3Withdraw, (asset, amount, to));
    }
}
