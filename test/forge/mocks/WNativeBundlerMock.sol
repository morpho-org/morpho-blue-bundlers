pragma solidity ^0.8.21;

import "contracts/WNativeBundler.sol";
import "contracts/Permit2Bundler.sol";

contract WNativeBundlerMock is WNativeBundler, Permit2Bundler {
    constructor(address wNative) WNativeBundler(wNative) {}
}
