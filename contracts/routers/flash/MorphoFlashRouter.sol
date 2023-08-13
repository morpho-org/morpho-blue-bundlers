// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {IMorphoFlashLoanCallback} from "@morpho-blue/interfaces/IMorphoCallbacks.sol";
import {IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";

import {Errors} from "./libraries/Errors.sol";

import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";

import {BaseFlashRouter} from "./BaseFlashRouter.sol";

/// @title MorphoFlashRouter.
/// @author Morpho Labs.
/// @custom:contact security@blue.xyz
abstract contract MorphoFlashRouter is BaseFlashRouter, IMorphoFlashLoanCallback {
    using SafeTransferLib for ERC20;

    /* IMMUTABLES */

    IMorpho internal immutable _MORPHO;

    /* CONSTRUCTOR */

    constructor(address morpho) {
        require(morpho != address(0), Errors.ZERO_ADDRESS);

        _MORPHO = IMorpho(morpho);
    }

    /* CALLBACKS */

    function onMorphoFlashLoan(uint256 amount, bytes calldata data) external {
        (address asset, bytes memory newData) = abi.decode(data, (address, bytes));
        _onCallback(newData);

        ERC20(asset).safeTransferFrom(_initiator, address(this), amount);
    }

    /* ACTIONS */

    /// @dev Triggers a flash loan on Blue.
    function morphoFlashLoan(address asset, uint256 amount, bytes calldata data) external {
        _approveMax(asset, address(_MORPHO));

        _MORPHO.flashLoan(asset, amount, data);
    }
}
