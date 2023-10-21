// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Math} from "../lib/morpho-utils/src/math/Math.sol";

import {BaseBundler} from "./BaseBundler.sol";
import {ERC20Wrapper, ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

/// @title ERC20WrapperBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables the wrapping and unwrapping of ERC20 tokens.
abstract contract ERC20WrapperBundler is BaseBundler {
    /* WRAPPER ACTIONS */

    function depositFor(address asset, address account, uint256 amount) external {
        require(asset != address(0), ErrorsLib.ZERO_ADDRESS);
        require(account != address(0), ErrorsLib.ZERO_ADDRESS);

        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20Wrapper(asset).depositFor(account, amount);
    }

    function withdrawTo(address asset, address account, uint256 amount) external {
        require(asset != address(0), ErrorsLib.ZERO_ADDRESS);
        require(account != address(0), ErrorsLib.ZERO_ADDRESS);
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20Wrapper(asset).withdrawTo(account, amount);
    }
}
