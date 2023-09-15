// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.2;

import {
    IMorphoRepayCallback,
    IMorphoSupplyCallback,
    IMorphoSupplyCollateralCallback,
    IMorphoFlashLoanCallback
} from "@morpho-blue/interfaces/IMorphoCallbacks.sol";

interface IMorphoBundler is
    IMorphoSupplyCallback,
    IMorphoRepayCallback,
    IMorphoSupplyCollateralCallback,
    IMorphoFlashLoanCallback
{}
