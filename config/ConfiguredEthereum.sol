// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./Configured.sol";

abstract contract ConfiguredEthereum is Configured {
    using ConfigLib for Config;

    address internal ST_ETH;
    address internal WST_ETH;
    address internal CB_ETH;
    address[] internal allEthereumMainnetAssets;

    function _network() internal view virtual override returns (string memory){
        return "ethereum-mainnet";
    }

    function _loadConfig() internal virtual override {
        super._loadConfig();

        ST_ETH = CONFIG.getAddress("stETH");
        WST_ETH = CONFIG.getAddress("wstETH");
        CB_ETH = CONFIG.getAddress("cbETH");

        allEthereumMainnetAssets = [ST_ETH, WST_ETH, CB_ETH];

        for (uint256 i; i < allEthereumMainnetAssets.length; ++i) {
            allAssets.push(allEthereumMainnetAssets[i]);
        }
    }
}
