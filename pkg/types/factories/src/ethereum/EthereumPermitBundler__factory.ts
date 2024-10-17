/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  EthereumPermitBundler,
  EthereumPermitBundlerInterface,
} from "../../../src/ethereum/EthereumPermitBundler";

const _abi = [
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
        internalType: "address",
        name: "asset",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "deadline",
        type: "uint256",
      },
      {
        internalType: "uint8",
        name: "v",
        type: "uint8",
      },
      {
        internalType: "bytes32",
        name: "r",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "s",
        type: "bytes32",
      },
      {
        internalType: "bool",
        name: "skipRevert",
        type: "bool",
      },
    ],
    name: "permit",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "nonce",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "expiry",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "allowed",
        type: "bool",
      },
      {
        internalType: "uint8",
        name: "v",
        type: "uint8",
      },
      {
        internalType: "bytes32",
        name: "r",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "s",
        type: "bytes32",
      },
      {
        internalType: "bool",
        name: "skipRevert",
        type: "bool",
      },
    ],
    name: "permitDai",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
] as const;

export class EthereumPermitBundler__factory {
  static readonly abi = _abi;
  static createInterface(): EthereumPermitBundlerInterface {
    return new Interface(_abi) as EthereumPermitBundlerInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): EthereumPermitBundler {
    return new Contract(
      address,
      _abi,
      runner
    ) as unknown as EthereumPermitBundler;
  }
}
