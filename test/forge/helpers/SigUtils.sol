// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ICompoundV3} from "src/migration/interfaces/ICompoundV3.sol";
import {Authorization} from "@morpho-blue/interfaces/IMorpho.sol";
import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";

import {PermitHash} from "@permit2/libraries/PermitHash.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";
import {AUTHORIZATION_TYPEHASH} from "@morpho-blue/libraries/ConstantsLib.sol";
import {Constants as AaveV3OptimizerConstants} from "@morpho-aave-v3/libraries/Constants.sol";

bytes32 constant PERMIT_TYPEHASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

struct Permit {
    address owner;
    address spender;
    uint256 value;
    uint256 nonce;
    uint256 deadline;
}

struct AaveV3OptimizerAuthorization {
    address delegator;
    address manager;
    bool isAllowed;
    uint256 nonce;
    uint256 deadline;
}

bytes32 constant COMPOUND_V3_DOMAIN_TYPEHASH =
    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

bytes32 constant COMPOUND_V3_AUTHORIZATION_TYPEHASH =
    keccak256("Authorization(address owner,address manager,bool isAllowed,uint256 nonce,uint256 expiry)");

struct CompoundV3Authorization {
    address owner;
    address manager;
    bool isAllowed;
    uint256 nonce;
    uint256 expiry;
}

library SigUtils {
    function toTypedDataHash(bytes32 domainSeparator, Permit memory permit) internal pure returns (bytes32) {
        return ECDSA.toTypedDataHash(
            domainSeparator,
            keccak256(
                abi.encode(PERMIT_TYPEHASH, permit.owner, permit.spender, permit.value, permit.nonce, permit.deadline)
            )
        );
    }

    function toTypedDataHash(bytes32 domainSeparator, Authorization memory authorization)
        internal
        pure
        returns (bytes32)
    {
        return ECDSA.toTypedDataHash(
            domainSeparator,
            keccak256(
                abi.encode(
                    AUTHORIZATION_TYPEHASH,
                    authorization.authorizer,
                    authorization.authorized,
                    authorization.isAuthorized,
                    authorization.nonce,
                    authorization.deadline
                )
            )
        );
    }

    function toTypedDataHash(bytes32 domainSeparator, IAllowanceTransfer.PermitSingle memory permitSingle)
        internal
        pure
        returns (bytes32)
    {
        return ECDSA.toTypedDataHash(domainSeparator, PermitHash.hash(permitSingle));
    }

    function toTypedDataHash(bytes32 domainSeparator, AaveV3OptimizerAuthorization memory authorization)
        internal
        pure
        returns (bytes32)
    {
        return ECDSA.toTypedDataHash(
            domainSeparator,
            keccak256(
                abi.encode(
                    AaveV3OptimizerConstants.EIP712_AUTHORIZATION_TYPEHASH,
                    authorization.delegator,
                    authorization.manager,
                    authorization.isAllowed,
                    authorization.nonce,
                    authorization.deadline
                )
            )
        );
    }

    function toTypedDataHash(address instance, CompoundV3Authorization memory authorization)
        internal
        view
        returns (bytes32)
    {
        return ECDSA.toTypedDataHash(
            keccak256(
                abi.encode(
                    COMPOUND_V3_DOMAIN_TYPEHASH,
                    keccak256(bytes(ICompoundV3(instance).name())),
                    keccak256(bytes(ICompoundV3(instance).version())),
                    block.chainid,
                    instance
                )
            ),
            keccak256(
                abi.encode(
                    COMPOUND_V3_AUTHORIZATION_TYPEHASH,
                    authorization.owner,
                    authorization.manager,
                    authorization.isAllowed,
                    authorization.nonce,
                    authorization.expiry
                )
            )
        );
    }
}
