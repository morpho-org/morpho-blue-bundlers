// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../TransferBundler.sol";
import {ERC20WrapperBundler} from "../../ERC20WrapperBundler.sol";

contract ERC20WrapperBundlerMock is ERC20WrapperBundler, TransferBundler {}
