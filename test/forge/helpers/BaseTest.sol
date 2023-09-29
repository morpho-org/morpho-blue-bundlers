// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@morpho-blue/interfaces/IMorpho.sol";

import {MarketParamsLib} from "@morpho-blue/libraries/MarketParamsLib.sol";
import {SharesMathLib} from "@morpho-blue/libraries/SharesMathLib.sol";
import {MathLib, WAD} from "@morpho-blue/libraries/MathLib.sol";
import {UtilsLib} from "@morpho-blue/libraries/UtilsLib.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";
import {MorphoLib} from "@morpho-blue/libraries/periphery/MorphoLib.sol";
import {MorphoBalancesLib} from "@morpho-blue/libraries/periphery/MorphoBalancesLib.sol";
import {LIQUIDATION_CURSOR, MAX_LIQUIDATION_INCENTIVE_FACTOR} from "@morpho-blue/libraries/ConstantsLib.sol";

import {IrmMock} from "@morpho-blue/mocks/IrmMock.sol";
import {OracleMock} from "@morpho-blue/mocks/OracleMock.sol";

import {BaseBundler} from "src/BaseBundler.sol";
import {ERC4626Bundler} from "src/ERC4626Bundler.sol";
import {UrdBundler} from "src/UrdBundler.sol";

import "@forge-std/Test.sol";
import "@forge-std/console2.sol";

abstract contract BaseTest is Test {
    using MathLib for uint256;
    using SharesMathLib for uint256;
    using MarketParamsLib for MarketParams;
    using SafeTransferLib for ERC20;
    using stdJson for string;

    uint256 internal constant MIN_AMOUNT = 1000;
    uint256 internal constant MAX_AMOUNT = 2 ** 64; // Must be less than or equal to type(uint160).max.
    uint256 internal constant ORACLE_PRICE_SCALE = 1e36;

    address internal constant USER = address(0x1234);
    address internal constant SUPPLIER = address(0x5678);
    address internal constant OWNER = address(0xdead);
    address internal constant RECEIVER = address(uint160(uint256(keccak256(bytes("morpho receiver")))));
    address internal constant LIQUIDATOR = address(uint160(uint256(keccak256(bytes("morpho liquidator")))));

    IMorpho internal morpho;
    IrmMock internal irm;
    OracleMock internal oracle;

    BaseBundler internal bundler;

    bytes[] internal bundle;
    bytes[] internal callbackBundle;

    function setUp() public virtual {
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

    /* TRANSFER */

    function _nativeTransfer(address recipient, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(BaseBundler.nativeTransfer, (recipient, amount));
    }

    /* ERC20 ACTIONS */

    function _erc20Transfer(address asset, address recipient, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(BaseBundler.erc20Transfer, (asset, recipient, amount));
    }

    function _erc20TransferFrom(address asset, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(BaseBundler.erc20TransferFrom, (asset, amount));
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
}
