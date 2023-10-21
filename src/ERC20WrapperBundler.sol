// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Math} from "../lib/morpho-utils/src/math/Math.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {BaseBundler} from "./BaseBundler.sol";
import {ERC20Wrapper} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

/// @title ERC20WrapperBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables the wrapping and unwrapping of ERC20 tokens.
abstract contract ERC20WrapperBundler is BaseBundler {
    /* WRAPPER ACTIONS */

    function depositFor(address wrapper, address account, uint256 amount) external {
        require(wrapper != address(0), ErrorsLib.ZERO_ADDRESS);
        require(account != address(0), ErrorsLib.ZERO_ADDRESS);

        IERC20 underlying = ERC20Wrapper(wrapper).underlying();

        amount = Math.min(amount, underlying.balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        // Approve 0 first to comply with tokens that implement the anti frontrunning approval fix.
        SafeERC20.safeApprove(underlying, wrapper, 0);
        SafeERC20.safeApprove(underlying, wrapper, amount);
        ERC20Wrapper(wrapper).depositFor(account, amount);
    }

    function withdrawTo(address wrapper, address account, uint256 amount) external {
        require(wrapper != address(0), ErrorsLib.ZERO_ADDRESS);
        require(account != address(0), ErrorsLib.ZERO_ADDRESS);
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20Wrapper(wrapper).withdrawTo(account, amount);
    }
}
