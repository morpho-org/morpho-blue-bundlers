/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type { UrdBundler, UrdBundlerInterface } from "../../src/UrdBundler";

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
        name: "distributor",
        type: "address",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "reward",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        internalType: "bytes32[]",
        name: "proof",
        type: "bytes32[]",
      },
      {
        internalType: "bool",
        name: "skipRevert",
        type: "bool",
      },
    ],
    name: "urdClaim",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
] as const;

export class UrdBundler__factory {
  static readonly abi = _abi;
  static createInterface(): UrdBundlerInterface {
    return new Interface(_abi) as UrdBundlerInterface;
  }
  static connect(address: string, runner?: ContractRunner | null): UrdBundler {
    return new Contract(address, _abi, runner) as unknown as UrdBundler;
  }
}
