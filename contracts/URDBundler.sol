// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IUniversalRewardsDistributor} from "@universal-rewards-distributor/interfaces/IUniversalRewardsDistributor.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title UrdBudnler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Bundler that allows to claim token rewards on the Universal Rewards Distributor.
contract UrdBundler is BaseBundler {
    function claim(address distributor, address account, address reward, uint256 claimable, bytes32[] calldata proof)
        external
        payable
    {
        require(distributor != address(0), ErrorsLib.ZERO_ADDRESS);
        require(account != address(0), ErrorsLib.ZERO_ADDRESS);
        require(account != address(this), ErrorsLib.BUNDLER_ADDRESS);

        IUniversalRewardsDistributor(distributor).claim(account, reward, claimable, proof);
    }
}
