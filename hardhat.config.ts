import * as dotenv from "dotenv";
import "evm-maths";
import "hardhat-gas-reporter";
import "hardhat-tracer";
import { HardhatUserConfig } from "hardhat/config";
import "solidity-coverage";
import "tsconfig-paths/register";

import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-foundry";
import "@nomicfoundation/hardhat-network-helpers";
import "@typechain/hardhat";

dotenv.config();

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1,
      gasPrice: 0,
      initialBaseFeePerGas: 0,
      allowBlocksWithSameTimestamp: true,
      accounts: {
        count: 151, // must be odd
      },
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_KEY,
        blockNumber: 18340697,
        enabled: true,
      },
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.24",
        settings: {
          optimizer: {
            enabled: true,
            runs: 999999,
          },
          viaIR: true,
        },
      },
      {
        version: "0.8.21",
        settings: {
          optimizer: {
            enabled: true,
            runs: 80000,
          },
          viaIR: true,
        },
      },
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 80000,
          },
          viaIR: true,
        },
      },
    ],
  },
  mocha: {
    timeout: 3000000,
  },
  typechain: {
    target: "ethers-v6",
    outDir: "pkg/types/",
    externalArtifacts: ["deps/**/*.json"],
  },
  tracer: {
    defaultVerbosity: 1,
    gasCost: true,
  },
};

export default config;
