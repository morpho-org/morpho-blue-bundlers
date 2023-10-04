// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ICompoundV3} from "src/migration/interfaces/ICompoundV3.sol";
import {Authorization} from "@bundlers/morpho-blue/src/interfaces/IMorpho.sol";
import {ISignatureTransfer} from "@bundlers/permit2/src/interfaces/ISignatureTransfer.sol";

import {PermitHash} from "@bundlers/permit2/src/libraries/PermitHash.sol";
import {ECDSA} from "@bundlers/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {AUTHORIZATION_TYPEHASH} from "@bundlers/morpho-blue/src/libraries/ConstantsLib.sol";
import {Constants as AaveV3OptimizerConstants} from "@bundlers/morpho-aave-v3/src/libraries/Constants.sol";

bytes32 constant PERMIT_TYPEHASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

struct Permit {
    address owner;
    address spender;
    uint256 value;
    uint256 nonce;
    uint256 deadline;
}

bytes32 constant DAI_PERMIT_TYPEHASH =
    keccak256("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)");

struct DaiPermit {
    address holder;
    address spender;
    uint256 nonce;
    uint256 expiry;
    bool allowed;
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

    function toTypedDataHash(
        bytes32 domainSeparator,
        ISignatureTransfer.PermitTransferFrom memory permit,
        address spender
    ) internal pure returns (bytes32) {
        // Don't use PermitHash.hash(permit) because msg.sender would not correspond to the expected spender.
        bytes32 permitHash = keccak256(
            abi.encode(
                PermitHash._PERMIT_TRANSFER_FROM_TYPEHASH,
                keccak256(abi.encode(PermitHash._TOKEN_PERMISSIONS_TYPEHASH, permit.permitted)),
                spender,
                permit.nonce,
                permit.deadline
            )
        );

        return ECDSA.toTypedDataHash(domainSeparator, permitHash);
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

    function toTypedDataHash(bytes32 domainSeparator, DaiPermit memory permit) internal pure returns (bytes32) {
        return ECDSA.toTypedDataHash(
            domainSeparator,
            keccak256(
                abi.encode(
                    DAI_PERMIT_TYPEHASH, permit.holder, permit.spender, permit.nonce, permit.expiry, permit.allowed
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
