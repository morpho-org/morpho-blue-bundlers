// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@morpho-blue/interfaces/IMorpho.sol";

import {SigUtils} from "./SigUtils.sol";
import {MarketParamsLib} from "@morpho-blue/libraries/MarketParamsLib.sol";
import {SharesMathLib} from "@morpho-blue/libraries/SharesMathLib.sol";
import {MathLib, WAD} from "@morpho-blue/libraries/MathLib.sol";
import {UtilsLib} from "@morpho-blue/libraries/UtilsLib.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";
import {MorphoLib} from "@morpho-blue/libraries/periphery/MorphoLib.sol";
import {MorphoBalancesLib} from "@morpho-blue/libraries/periphery/MorphoBalancesLib.sol";
import {
    LIQUIDATION_CURSOR,
    MAX_LIQUIDATION_INCENTIVE_FACTOR,
    ORACLE_PRICE_SCALE
} from "@morpho-blue/libraries/ConstantsLib.sol";

import {IrmMock} from "@morpho-blue/mocks/IrmMock.sol";
import {OracleMock} from "@morpho-blue/mocks/OracleMock.sol";

import {BaseBundler} from "src/BaseBundler.sol";
import {TransferBundler} from "src/TransferBundler.sol";
import {ERC4626Bundler} from "src/ERC4626Bundler.sol";
import {UrdBundler} from "src/UrdBundler.sol";
import {MorphoBundler} from "src/MorphoBundler.sol";

import "@forge-std/Test.sol";
import "@forge-std/console2.sol";

uint256 constant MIN_AMOUNT = 1000;
uint256 constant MAX_AMOUNT = 2 ** 64; // Must be less than or equal to type(uint160).max.
uint256 constant SIGNATURE_DEADLINE = type(uint32).max;

abstract contract BaseTest is Test {
    using MathLib for uint256;
    using SharesMathLib for uint256;
    using MarketParamsLib for MarketParams;
    using SafeTransferLib for ERC20;
    using stdJson for string;

    address internal USER;
    address internal SUPPLIER;
    address internal OWNER;
    address internal RECEIVER;
    address internal LIQUIDATOR;

    IMorpho internal morpho;
    IrmMock internal irm;
    OracleMock internal oracle;

    BaseBundler internal bundler;

    bytes[] internal bundle;
    bytes[] internal callbackBundle;

    function setUp() public virtual {
        USER = makeAddr("User");
        OWNER = makeAddr("Owner");
        SUPPLIER = makeAddr("Supplier");
        RECEIVER = makeAddr("Receiver");
        LIQUIDATOR = makeAddr("Liquidator");

        morpho = IMorpho(_deploy("lib/morpho-blue/out/Morpho.sol/Morpho.json", abi.encode(OWNER)));
        vm.label(address(morpho), "Morpho");

        irm = new IrmMock();

        vm.prank(OWNER);
        morpho.enableIrm(address(irm));

        oracle = new OracleMock();
        oracle.setPrice(ORACLE_PRICE_SCALE);

        vm.prank(USER);
        // So tests can borrow/withdraw on behalf of USER without pranking it.
        morpho.setAuthorization(address(this), true);
    }

    function _deploy(string memory artifactPath, bytes memory constructorArgs) internal returns (address deployed) {
        string memory artifact = vm.readFile(artifactPath);
        bytes memory bytecode = bytes.concat(artifact.readBytes("$.bytecode.object"), constructorArgs);

        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployed != address(0), string.concat("could not deploy `", artifactPath, "`"));
    }

    function _boundPrivateKey(uint256 privateKey) internal returns (uint256, address) {
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);
        vm.label(user, "User");

        return (privateKey, user);
    }

    /* TRANSFER */

    function _nativeTransfer(address recipient, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(TransferBundler.nativeTransfer, (recipient, amount));
    }

    /* ERC20 ACTIONS */

    function _erc20Transfer(address asset, address recipient, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(TransferBundler.erc20Transfer, (asset, recipient, amount));
    }

    function _erc20TransferFrom(address asset, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(TransferBundler.erc20TransferFrom, (asset, amount));
    }

    /* ERC4626 ACTIONS */

    function _erc4626Mint(address vault, uint256 shares, address receiver) internal pure returns (bytes memory) {
        return abi.encodeCall(ERC4626Bundler.erc4626Mint, (vault, shares, receiver));
    }

    function _erc4626Deposit(address vault, uint256 assets, address receiver) internal pure returns (bytes memory) {
        return abi.encodeCall(ERC4626Bundler.erc4626Deposit, (vault, assets, receiver));
    }

    function _erc4626Withdraw(address vault, uint256 assets, address receiver) internal pure returns (bytes memory) {
        return abi.encodeCall(ERC4626Bundler.erc4626Withdraw, (vault, assets, receiver));
    }

    function _erc4626Redeem(address vault, uint256 shares, address receiver) internal pure returns (bytes memory) {
        return abi.encodeCall(ERC4626Bundler.erc4626Redeem, (vault, shares, receiver));
    }

    /* URD ACTIONS */

    function _urdClaim(
        address distributor,
        address account,
        address reward,
        uint256 amount,
        bytes32[] memory proof,
        bool skipRevert
    ) internal pure returns (bytes memory) {
        return abi.encodeCall(UrdBundler.urdClaim, (distributor, account, reward, amount, proof, skipRevert));
    }

    /* MORPHO ACTIONS */

    function _morphoSetAuthorizationWithSig(uint256 privateKey, bool isAuthorized, uint256 nonce, bool skipRevert)
        internal
        view
        returns (bytes memory)
    {
        address user = vm.addr(privateKey);

        Authorization memory authorization = Authorization({
            authorizer: user,
            authorized: address(bundler),
            isAuthorized: isAuthorized,
            nonce: nonce,
            deadline: SIGNATURE_DEADLINE
        });

        bytes32 digest = SigUtils.toTypedDataHash(morpho.DOMAIN_SEPARATOR(), authorization);

        Signature memory signature;
        (signature.v, signature.r, signature.s) = vm.sign(privateKey, digest);

        return abi.encodeCall(MorphoBundler.morphoSetAuthorizationWithSig, (authorization, signature, skipRevert));
    }

    function _morphoSupply(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf)
        internal
        view
        returns (bytes memory)
    {
        return abi.encodeCall(
            MorphoBundler.morphoSupply, (marketParams, assets, shares, onBehalf, abi.encode(callbackBundle))
        );
    }

    function _morphoBorrow(MarketParams memory marketParams, uint256 assets, uint256 shares, address receiver)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(MorphoBundler.morphoBorrow, (marketParams, assets, shares, receiver));
    }

    function _morphoWithdraw(MarketParams memory marketParams, uint256 assets, uint256 shares, address receiver)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(MorphoBundler.morphoWithdraw, (marketParams, assets, shares, receiver));
    }

    function _morphoRepay(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf)
        internal
        view
        returns (bytes memory)
    {
        return abi.encodeCall(
            MorphoBundler.morphoRepay, (marketParams, assets, shares, onBehalf, abi.encode(callbackBundle))
        );
    }

    function _morphoSupplyCollateral(MarketParams memory marketParams, uint256 collateral, address onBehalf)
        internal
        view
        returns (bytes memory)
    {
        return abi.encodeCall(
            MorphoBundler.morphoSupplyCollateral, (marketParams, collateral, onBehalf, abi.encode(callbackBundle))
        );
    }

    function _morphoWithdrawCollateral(MarketParams memory marketParams, uint256 collateral, address receiver)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(MorphoBundler.morphoWithdrawCollateral, (marketParams, collateral, receiver));
    }

    function _morphoLiquidate(
        MarketParams memory marketParams,
        address borrower,
        uint256 seizedCollateral,
        uint256 repaidShares
    ) internal pure returns (bytes memory) {
        return abi.encodeCall(
            MorphoBundler.morphoLiquidate, (marketParams, borrower, seizedCollateral, repaidShares, hex"")
        );
    }

    function _morphoFlashLoan(address asset, uint256 amount) internal view returns (bytes memory) {
        return abi.encodeCall(MorphoBundler.morphoFlashLoan, (asset, amount, abi.encode(callbackBundle)));
    }
}
