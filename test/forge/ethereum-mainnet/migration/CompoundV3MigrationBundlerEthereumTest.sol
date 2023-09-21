// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ICompoundV3} from "contracts/migration/interfaces/ICompoundV3.sol";

import {CompoundV3MigrationBundler} from "contracts/migration/CompoundV3MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract CompoundV3MigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    CompoundV3MigrationBundler bundler;

    address internal cToken;

    mapping(address => address) _cTokens;

    uint256 collateralSupplied = 10 ether;
    uint256 borrowed = 1 ether;

    function setUp() public override {
        super.setUp();

        _initMarket(CB_ETH, WETH);

        vm.label(C_WETH_V3, "cWETHv3");
        _cTokens[WETH] = C_WETH_V3;

        vm.label(address(bundler), "Compound V3 Migration Bundler");
        cToken = _getCTokenV3(marketParams.borrowableToken);

        bundler = new CompoundV3MigrationBundler(address(morpho));
    }

    /// forge-config: default.fuzz.runs = 3
    function testMigrateBorrowerWithCompoundAllowance(uint256 privateKey) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(cToken, collateralSupplied);
        ICompoundV3(cToken).supply(marketParams.collateralToken, collateralSupplied);
        ICompoundV3(cToken).withdraw(marketParams.borrowableToken, borrowed);
        vm.stopPrank();

        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        callbackBundle.push(Call(_morphoBorrowCall(borrowed, address(bundler)), false));
        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), false, 1), false));
        callbackBundle.push(Call(_compoundV3RepayCall(cToken, marketParams.borrowableToken, borrowed), false));
        callbackBundle.push(Call(_compoundV3AllowCall(privateKey, cToken, address(bundler), true, 0), false));
        callbackBundle.push(
            Call(_compoundV3WithdrawFromCall(cToken, marketParams.collateralToken, collateralSupplied), false)
        );
        callbackBundle.push(Call(_compoundV3AllowCall(privateKey, cToken, address(bundler), false, 1), false));
        bundle.push(Call(_morphoSupplyCollateralCall(collateralSupplied, user, abi.encode(callbackBundle)), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithCompoundAllowance(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 100);

        vm.startPrank(user);
        // Margin necessary due to CompoundV3 roundings.
        ERC20(marketParams.borrowableToken).safeApprove(cToken, supplied + 100);
        ICompoundV3(cToken).supply(marketParams.borrowableToken, supplied + 100);
        vm.stopPrank();

        bundle.push(Call(_compoundV3AllowCall(privateKey, cToken, address(bundler), true, 0), false));
        bundle.push(Call(_compoundV3WithdrawFromCall(cToken, marketParams.borrowableToken, supplied), false));
        bundle.push(Call(_compoundV3AllowCall(privateKey, cToken, address(bundler), false, 1), false));
        bundle.push(Call(_morphoSupplyCall(supplied, user, hex""), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 100);

        vm.startPrank(user);
        // Margin necessary due to CompoundV3 roundings.
        ERC20(marketParams.borrowableToken).safeApprove(cToken, supplied + 100);
        ICompoundV3(cToken).supply(marketParams.borrowableToken, supplied + 100);
        vm.stopPrank();

        uint256 cTokenBalance = ICompoundV3(cToken).balanceOf(user);

        vm.prank(user);
        ERC20(cToken).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);

        bundle.push(Call(_erc20Approve2Call(privateKey, cToken, uint160(cTokenBalance), address(bundler), 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(cToken, cTokenBalance), false));
        bundle.push(Call(_compoundV3WithdrawCall(cToken, marketParams.borrowableToken, supplied), false));
        bundle.push(Call(_morphoSupplyCall(supplied, user, hex""), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithCompoundAllowance(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 100);

        vm.startPrank(user);
        // Margin necessary due to CompoundV3 roundings.
        ERC20(marketParams.borrowableToken).safeApprove(cToken, supplied + 100);
        ICompoundV3(cToken).supply(marketParams.borrowableToken, supplied + 100);
        vm.stopPrank();

        bundle.push(Call(_compoundV3AllowCall(privateKey, cToken, address(bundler), true, 0), false));
        bundle.push(Call(_compoundV3WithdrawFromCall(cToken, marketParams.borrowableToken, supplied), false));
        bundle.push(Call(_compoundV3AllowCall(privateKey, cToken, address(bundler), false, 1), false));
        bundle.push(Call(_erc4626DepositCall(address(suppliersVault), supplied, user), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.borrowableToken, user, supplied + 100);

        vm.startPrank(user);
        // Margin necessary due to CompoundV3 roundings.
        ERC20(marketParams.borrowableToken).safeApprove(cToken, supplied + 100);
        ICompoundV3(cToken).supply(marketParams.borrowableToken, supplied + 100);
        vm.stopPrank();

        uint256 cTokenBalance = ICompoundV3(cToken).balanceOf(user);

        vm.prank(user);
        ERC20(cToken).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);

        bundle.push(Call(_erc20Approve2Call(privateKey, cToken, uint160(cTokenBalance), address(bundler), 0), false));
        bundle.push(Call(_erc20TransferFrom2Call(cToken, cTokenBalance), false));
        bundle.push(Call(_compoundV3WithdrawCall(cToken, marketParams.borrowableToken, supplied), false));
        bundle.push(Call(_erc4626DepositCall(address(suppliersVault), supplied, user), false));

        vm.prank(user);
        bundler.multicall(SIG_DEADLINE, bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function _getCTokenV3(address asset) internal view returns (address) {
        address result = _cTokens[asset];
        require(result != address(0), "unknown compound v3 market");
        return result;
    }

    function _compoundV3AllowCall(uint256 privateKey, address instance, address manager, bool isAllowed, uint256 nonce)
        internal
        view
        returns (bytes memory)
    {
        bytes32 permitTypehash =
            keccak256("Authorization(address owner,address manager,bool isAllowed,uint256 nonce,uint256 expiry)");
        bytes32 domainTypehash =
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        bytes32 domainSeparator = keccak256(
            abi.encode(
                domainTypehash,
                keccak256(bytes(ICompoundV3(instance).name())),
                keccak256(bytes(ICompoundV3(instance).version())),
                block.chainid,
                instance
            )
        );
        bytes32 digest = ECDSA.toTypedDataHash(
            domainSeparator,
            keccak256(abi.encode(permitTypehash, vm.addr(privateKey), manager, isAllowed, nonce, SIG_DEADLINE))
        );

        Signature memory sig;
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        return abi.encodeCall(
            CompoundV3MigrationBundler.compoundV3AllowBySig,
            (instance, isAllowed, nonce, SIG_DEADLINE, sig.v, sig.r, sig.s)
        );
    }

    function _compoundV3RepayCall(address instance, address asset, uint256 amount)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(CompoundV3MigrationBundler.compoundV3Repay, (instance, asset, amount));
    }

    function _compoundV3WithdrawCall(address instance, address asset, uint256 amount)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(CompoundV3MigrationBundler.compoundV3Withdraw, (instance, asset, amount));
    }

    function _compoundV3WithdrawFromCall(address instance, address asset, uint256 amount)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(CompoundV3MigrationBundler.compoundV3WithdrawFrom, (instance, asset, amount));
    }
}
