// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IUniversalRewardsDistributor} from "@universal-rewards-distributor/interfaces/IUniversalRewardsDistributor.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {ConditionalCallLib} from "./libraries/ConditionalCallLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title UrdBudnler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Bundler that allows to claim token rewards on the Universal Rewards Distributor.
contract UrdBundler is BaseBundler {
    using ConditionalCallLib for address;

    /// @notice Claims `amount` of `reward` on behalf of `account` on the given rewards distributor, using `proof`.
    /// @dev Assumes the given distributor implements IUniversalRewardsDistributor.
    function urdClaim(
        address distributor,
        address account,
        address reward,
        uint256 amount,
        bytes32[] calldata proof,
        bool allowRevert
    ) external payable {
        require(account != address(0), ErrorsLib.ZERO_ADDRESS);
        require(account != address(this), ErrorsLib.BUNDLER_ADDRESS);

        distributor.conditionalCall(
            abi.encodeCall(IUniversalRewardsDistributor(distributor).claim, (account, reward, amount, proof)),
            allowRevert
        );
    }
}
