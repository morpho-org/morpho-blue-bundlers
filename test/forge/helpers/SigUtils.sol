// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {Authorization} from "@morpho-blue/interfaces/IMorpho.sol";

import {AUTHORIZATION_TYPEHASH} from "@morpho-blue/libraries/ConstantsLib.sol";

// keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
bytes32 constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

struct Permit {
    address owner;
    address spender;
    uint256 value;
    uint256 nonce;
    uint256 deadline;
}

library SigUtils {
    /// @dev Computes the hash of the EIP-712 encoded data.
    function getTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }

    function getAuthorizationStructHash(Authorization memory authorization) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                AUTHORIZATION_TYPEHASH,
                authorization.authorizer,
                authorization.authorized,
                authorization.isAuthorized,
                authorization.nonce,
                authorization.deadline
            )
        );
    }

    /// @dev Computes the hash of a permit
    function getPermitStructHash(Permit memory permit) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(PERMIT_TYPEHASH, permit.owner, permit.spender, permit.value, permit.nonce, permit.deadline)
        );
    }
}
