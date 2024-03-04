// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

import {SepoliaLib} from "./libraries/SepoliaLib.sol";

import {BaseBundler} from "../BaseBundler.sol";
import {TransferBundler} from "../TransferBundler.sol";
import {PermitBundler} from "../PermitBundler.sol";
import {Permit2Bundler} from "../Permit2Bundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {WNativeBundler} from "../WNativeBundler.sol";
import {StEthBundler} from "../StEthBundler.sol";
import {UrdBundler} from "../UrdBundler.sol";
import {MorphoBundlerV2} from "../MorphoBundlerV2.sol";
import {ERC20WrapperBundler} from "../ERC20WrapperBundler.sol";

/// @title SepoliaBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Sepolia testnet.
contract SepoliaBundler is
    TransferBundler,
    PermitBundler,
    Permit2Bundler,
    ERC4626Bundler,
    WNativeBundler,
    StEthBundler,
    UrdBundler,
    MorphoBundlerV2,
    ERC20WrapperBundler
{
    /* CONSTRUCTOR */

    constructor(address morpho)
        WNativeBundler(SepoliaLib.WETH)
        StEthBundler(SepoliaLib.WST_ETH)
        MorphoBundlerV2(morpho)
    {}

    /* INTERNAL */

    /// @inheritdoc MorphoBundlerV2
    function _isSenderAuthorized() internal view override(BaseBundler, MorphoBundlerV2) returns (bool) {
        return MorphoBundlerV2._isSenderAuthorized();
    }
}
