import "evm-maths";
import "hardhat-gas-reporter";
import "hardhat-tracer";
import "solidity-coverage";

import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-ethers";
import "@typechain/hardhat";

import config from "../../hardhat.config";

config.typechain = {
  outDir: "src/types/",
};

export default config;
