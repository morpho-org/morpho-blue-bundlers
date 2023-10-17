// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {IStEth} from "src/interfaces/IStEth.sol";
import {IWstEth} from "src/interfaces/IWstEth.sol";
import {ISignatureTransfer} from "@permit2/interfaces/ISignatureTransfer.sol";

import {Permit2Lib} from "@permit2/libraries/Permit2Lib.sol";

import {Permit2Bundler} from "src/Permit2Bundler.sol";
import {WETHBundler} from "src/WETHBundler.sol";
import {StEthBundler} from "src/StEthBundler.sol";

import "config/Configured.sol";
import "./BaseTest.sol";

abstract contract ForkTest is BaseTest, Configured {
    using ConfigLib for Config;
    using SafeTransferLib for ERC20;

    string internal network;
    uint256 internal forkId;

    uint256 internal snapshotId = type(uint256).max;

    MarketParams[] allMarketParams;

    function setUp() public virtual override {
        _initConfig();
        _loadConfig();

        _fork();
        _label();

        super.setUp();

        for (uint256 i; i < configMarkets.length; ++i) {
            ConfigMarket memory configMarket = configMarkets[i];

            MarketParams memory marketParams = MarketParams({
                collateralToken: configMarket.collateralToken,
                loanToken: configMarket.loanToken,
                oracle: address(oracle),
                irm: address(irm),
                lltv: configMarket.lltv
            });

            vm.startPrank(OWNER);
            if (!morpho.isLltvEnabled(configMarket.lltv)) morpho.enableLltv(configMarket.lltv);
            morpho.createMarket(marketParams);
            vm.stopPrank();

            allMarketParams.push(marketParams);
        }
    }

    function _fork() internal virtual {
        string memory rpcUrl = vm.rpcUrl(_network());
        uint256 forkBlockNumber = CONFIG.getForkBlockNumber();

        forkId = forkBlockNumber == 0 ? vm.createSelectFork(rpcUrl) : vm.createSelectFork(rpcUrl, forkBlockNumber);

        vm.chainId(CONFIG.getChainId());
    }

    function _label() internal virtual {
        for (uint256 i; i < allAssets.length; ++i) {
            address asset = allAssets[i];
            string memory symbol = ERC20(asset).symbol();

            vm.label(asset, symbol);
        }
    }

    function deal(address asset, address recipient, uint256 amount) internal virtual override {
        if (amount == 0) return;

        if (asset == WETH) super.deal(WETH, WETH.balance + amount); // Refill wrapped Ether.

        return super.deal(asset, recipient, amount);
    }

    /// @dev Reverts the fork to its initial fork state.
    function _revert() internal {
        if (snapshotId < type(uint256).max) vm.revertTo(snapshotId);
        snapshotId = vm.snapshot();
    }

    function _assumeNotAsset(address input) internal view {
        for (uint256 i; i < allAssets.length; ++i) {
            vm.assume(input != allAssets[i]);
        }
    }

    function _randomAsset(uint256 seed) internal view returns (address) {
        return allAssets[seed % allAssets.length];
    }

    function _randomMarketParams(uint256 seed) internal view returns (MarketParams memory) {
        return allMarketParams[seed % allMarketParams.length];
    }

    /* PERMIT2 ACTIONS */

    function _permit2TransferFrom(uint256 privateKey, address asset, uint256 amount, uint256 nonce)
        internal
        view
        returns (bytes memory)
    {
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({token: asset, amount: amount}),
            nonce: nonce,
            deadline: SIGNATURE_DEADLINE
        });

        bytes32 digest = SigUtils.toTypedDataHash(Permit2Lib.PERMIT2.DOMAIN_SEPARATOR(), permit, address(bundler));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return abi.encodeCall(Permit2Bundler.permit2TransferFrom, (permit, abi.encodePacked(r, s, v)));
    }

    /* wstETH ACTIONS */

    function _wrapStEth(uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(StEthBundler.wrapStEth, (amount));
    }

    function _unwrapStEth(uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(StEthBundler.unwrapStEth, (amount));
    }

    /* WRAPPED NATIVE ACTIONS */

    function _wrapETH(uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(WETHBundler.wrapETH, (amount));
    }

    function _unwrapETH(uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(WETHBundler.unwrapETH, (amount));
    }
}
