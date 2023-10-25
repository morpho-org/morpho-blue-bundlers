// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {Authorization as AaveV3OptimizerAuthorization} from "../../../../src/migration/interfaces/IAaveV3Optimizer.sol";

import "../../../../src/migration/AaveV3OptimizerMigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract AaveV3OptimizerMigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    uint256 public constant MAX_ITERATIONS = 15;

    uint256 collateralSupplied = 10_000 ether;
    uint256 borrowed = 1 ether;

    function setUp() public override {
        super.setUp();

        _initMarket(DAI, WETH);

        vm.label(AAVE_V3_OPTIMIZER, "AaveV3Optimizer");

        bundler = new AaveV3OptimizerMigrationBundler(address(morpho), address(AAVE_V3_OPTIMIZER));
    }

    function testAaveV3Optimizer3RepayZeroAmount() public {
        bundle.push(_aaveV3OptimizerRepay(marketParams.loanToken, 0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }

    function testMigrateBorrowerWithOptimizerPermit(uint256 privateKey) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(AAVE_V3_OPTIMIZER, collateralSupplied + 1);
        IAaveV3Optimizer(AAVE_V3_OPTIMIZER).supplyCollateral(marketParams.collateralToken, collateralSupplied + 1, user);
        IAaveV3Optimizer(AAVE_V3_OPTIMIZER).borrow(marketParams.loanToken, borrowed, user, user, MAX_ITERATIONS);
        vm.stopPrank();

        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, true, 0, false));
        callbackBundle.push(_morphoBorrow(marketParams, borrowed, 0, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, false, 1, false));
        callbackBundle.push(_aaveV3OptimizerRepay(marketParams.loanToken, borrowed));
        callbackBundle.push(_aaveV3OptimizerApproveManager(privateKey, address(bundler), true, 0));
        callbackBundle.push(
            _aaveV3OptimizerWithdrawCollateral(marketParams.collateralToken, collateralSupplied, address(bundler))
        );
        callbackBundle.push(_aaveV3OptimizerApproveManager(privateKey, address(bundler), false, 1));

        bundle.push(_morphoSupplyCollateral(marketParams, collateralSupplied, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateUSDTBorrowerWithOptimizerPermit(uint256 privateKey) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);

        uint256 amountUsdt = collateralSupplied / 1e10;

        _initMarket(USDT, WETH);
        oracle.setPrice(1e46);

        _provideLiquidity(borrowed);

        deal(USDT, user, amountUsdt + 1);

        vm.startPrank(user);
        ERC20(USDT).safeApprove(AAVE_V3_OPTIMIZER, amountUsdt + 1);
        IAaveV3Optimizer(AAVE_V3_OPTIMIZER).supplyCollateral(USDT, amountUsdt + 1, user);
        IAaveV3Optimizer(AAVE_V3_OPTIMIZER).borrow(marketParams.loanToken, borrowed, user, user, MAX_ITERATIONS);
        vm.stopPrank();

        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, true, 0, false));
        callbackBundle.push(_morphoBorrow(marketParams, borrowed, 0, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, false, 1, false));
        callbackBundle.push(_aaveV3OptimizerRepay(marketParams.loanToken, borrowed));
        callbackBundle.push(_aaveV3OptimizerApproveManager(privateKey, address(bundler), true, 0));
        callbackBundle.push(_aaveV3OptimizerWithdrawCollateral(USDT, amountUsdt, address(bundler)));
        callbackBundle.push(_aaveV3OptimizerApproveManager(privateKey, address(bundler), false, 1));

        bundle.push(_morphoSupplyCollateral(marketParams, amountUsdt, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(amountUsdt, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithOptimizerPermit(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.loanToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(AAVE_V3_OPTIMIZER, supplied + 1);
        IAaveV3Optimizer(AAVE_V3_OPTIMIZER).supply(marketParams.loanToken, supplied + 1, user, MAX_ITERATIONS);
        vm.stopPrank();

        bundle.push(_aaveV3OptimizerApproveManager(privateKey, address(bundler), true, 0));
        bundle.push(_aaveV3OptimizerWithdraw(marketParams.loanToken, supplied, address(bundler)));
        bundle.push(_aaveV3OptimizerApproveManager(privateKey, address(bundler), false, 1));
        bundle.push(_morphoSupply(marketParams, supplied, 0, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithOptimizerPermit(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);
        supplied = bound(supplied, 100, 100 ether);

        deal(marketParams.loanToken, user, supplied + 1);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(AAVE_V3_OPTIMIZER, supplied + 1);
        IAaveV3Optimizer(AAVE_V3_OPTIMIZER).supply(marketParams.loanToken, supplied + 1, user, MAX_ITERATIONS);
        vm.stopPrank();

        bundle.push(_aaveV3OptimizerApproveManager(privateKey, address(bundler), true, 0));
        bundle.push(_aaveV3OptimizerWithdraw(marketParams.loanToken, supplied, address(bundler)));
        bundle.push(_aaveV3OptimizerApproveManager(privateKey, address(bundler), false, 1));
        bundle.push(_erc4626Deposit(address(suppliersVault), supplied, user, false));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    /* ACTIONS */

    function _aaveV3OptimizerApproveManager(uint256 privateKey, address manager, bool isAllowed, uint256 nonce)
        internal
        view
        returns (bytes memory)
    {
        bytes32 digest = SigUtils.toTypedDataHash(
            IAaveV3Optimizer(AAVE_V3_OPTIMIZER).DOMAIN_SEPARATOR(),
            AaveV3OptimizerAuthorization(vm.addr(privateKey), manager, isAllowed, nonce, SIGNATURE_DEADLINE)
        );

        Signature memory sig;
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        return abi.encodeCall(
            AaveV3OptimizerMigrationBundler.aaveV3OptimizerApproveManagerWithSig,
            (isAllowed, nonce, SIGNATURE_DEADLINE, sig)
        );
    }

    function _aaveV3OptimizerRepay(address underlying, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(AaveV3OptimizerMigrationBundler.aaveV3OptimizerRepay, (underlying, amount));
    }

    function _aaveV3OptimizerWithdraw(address underlying, uint256 amount, address receiver)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(
            AaveV3OptimizerMigrationBundler.aaveV3OptimizerWithdraw, (underlying, amount, receiver, MAX_ITERATIONS)
        );
    }

    function _aaveV3OptimizerWithdrawCollateral(address underlying, uint256 amount, address receiver)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(
            AaveV3OptimizerMigrationBundler.aaveV3OptimizerWithdrawCollateral, (underlying, amount, receiver)
        );
    }
}
