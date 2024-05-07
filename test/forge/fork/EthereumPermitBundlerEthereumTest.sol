// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "../../../src/libraries/ErrorsLib.sol";

import {DaiPermit} from "../helpers/SigUtils.sol";

import "../../../src/mocks/bundlers/ethereum/EthereumPermitBundlerMock.sol";

import "./helpers/EthereumTest.sol";

/// @dev The unique EIP-712 domain domain separator for the DAI token contract on Ethereum.
bytes32 constant DAI_DOMAIN_SEPARATOR = 0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

contract EthereumPermitBundlerEthereumTest is EthereumTest {
    function setUp() public override {
        super.setUp();

        bundler = new EthereumPermitBundlerMock();
    }

    function testPermitDai(uint256 privateKey, uint256 expiry) public onlyEthereum {
        expiry = bound(expiry, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_permitDai(privateKey, expiry, true, false));
        bundle.push(_permitDai(privateKey, expiry, true, true));

        vm.prank(user);
        bundler.multicall(bundle);

        assertEq(ERC20(DAI).allowance(user, address(bundler)), type(uint256).max, "allowance(user, bundler)");
    }

    function testPermitDaiUninitiated() public onlyEthereum {
        vm.expectRevert(bytes(ErrorsLib.UNINITIATED));
        EthereumPermitBundlerMock(address(bundler)).permitDai(0, SIGNATURE_DEADLINE, true, 0, 0, 0, true);
    }

    function testPermitDaiRevert(uint256 privateKey, uint256 expiry) public onlyEthereum {
        expiry = bound(expiry, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_permitDai(privateKey, expiry, true, false));
        bundle.push(_permitDai(privateKey, expiry, true, false));

        vm.prank(user);
        vm.expectRevert("Dai/invalid-nonce");
        bundler.multicall(bundle);
    }

    function _permitDai(uint256 privateKey, uint256 expiry, bool allowed, bool skipRevert)
        internal
        view
        returns (bytes memory)
    {
        address user = vm.addr(privateKey);
        uint256 nonce = IDaiPermit(DAI).nonces(user);

        DaiPermit memory permit = DaiPermit(user, address(bundler), nonce, expiry, allowed);

        bytes32 digest = SigUtils.toTypedDataHash(DAI_DOMAIN_SEPARATOR, permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return abi.encodeCall(EthereumPermitBundler.permitDai, (nonce, expiry, allowed, v, r, s, skipRevert));
    }
}
