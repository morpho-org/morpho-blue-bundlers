// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IUniversalRewardsDistributor} from "@universal-rewards-distributor/interfaces/IUniversalRewardsDistributor.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title UrdBudnler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Bundler that allows to claim token rewards on the Universal Rewards Distributor.
abstract contract UrdBundler is BaseBundler {
    /// @notice Claims `amount` of `reward` on behalf of `account` on the given rewards distributor, using `proof`.
    /// @dev Assumes the given distributor implements IUniversalRewardsDistributor.
    /// @dev Pass `skipRevert == true` to avoid failing in case the signature expired and is optional.
    function urdClaim(
        address distributor,
        address account,
        address reward,
        uint256 amount,
        bytes32[] calldata proof,
        bool skipRevert
    ) external payable {
        require(account != address(0), ErrorsLib.ZERO_ADDRESS);
        require(account != address(this), ErrorsLib.BUNDLER_ADDRESS);

        try IUniversalRewardsDistributor(distributor).claim(account, reward, amount, proof) {}
        catch (bytes memory returnData) {
            if (!skipRevert) _revert(returnData);
        }
    }
}
