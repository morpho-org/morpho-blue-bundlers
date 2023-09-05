// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MerkleProof} from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import {IUniversalRewardsDistributor} from "@universal-rewards-distributor/interfaces/IUniversalRewardsDistributor.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title EVMBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Common bundler layer guaranteeing it can be deployed to the same address on all EVM-compatible chains.
contract URDBundler is BaseBundler {
    IUniversalRewardsDistributor public immutable URD;

    constructor(address urd) {
        require(urd != address(0), ErrorsLib.ZERO_ADDRESS);

        URD = IUniversalRewardsDistributor(urd);
    }

    function claim(uint256 distributionId, address account, address reward, uint256 claimable, bytes32[] calldata proof)
        external
        payable
    {
        URD.claim(distributionId, account, reward, claimable, proof);
    }
}
