// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import {
    IMorphoRepayCallback,
    IMorphoSupplyCallback,
    IMorphoSupplyCollateralCallback,
    IMorphoFlashLoanCallback
} from "@bundlers/morpho-blue/src/interfaces/IMorphoCallbacks.sol";

interface IMorphoBundler is
    IMorphoSupplyCallback,
    IMorphoRepayCallback,
    IMorphoSupplyCollateralCallback,
    IMorphoFlashLoanCallback
{}
