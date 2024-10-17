/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  EthereumStEthBundler,
  EthereumStEthBundlerInterface,
} from "../../../src/ethereum/EthereumStEthBundler";

const _abi = [
  {
    inputs: [],
    name: "ST_ETH",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "WST_ETH",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "initiator",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes[]",
        name: "data",
        type: "bytes[]",
      },
    ],
    name: "multicall",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "minShares",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "referral",
        type: "address",
      },
    ],
    name: "stakeEth",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "unwrapStEth",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "wrapStEth",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
] as const;

export class EthereumStEthBundler__factory {
  static readonly abi = _abi;
  static createInterface(): EthereumStEthBundlerInterface {
    return new Interface(_abi) as EthereumStEthBundlerInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): EthereumStEthBundler {
    return new Contract(
      address,
      _abi,
      runner
    ) as unknown as EthereumStEthBundler;
  }
}
