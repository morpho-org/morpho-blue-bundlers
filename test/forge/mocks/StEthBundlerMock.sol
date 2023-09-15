pragma solidity ^0.8.21;

import "contracts/ethereum-mainnet/StEthBundler.sol";
import "contracts/Permit2Bundler.sol";

contract StEthBundlerMock is StEthBundler, Permit2Bundler {}
