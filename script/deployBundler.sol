// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import {GoerliBundler} from "src/goerli/GoerliBundler.sol";

contract DeployBundler is Script {
    address public immutable MORPHO = 0xC850a9C14454131aE82C28DC7ff51c2dc6ace06e;

    function run() public {
        vm.broadcast();
        console.log(address(new GoerliBundler(MORPHO)));
    }
}
