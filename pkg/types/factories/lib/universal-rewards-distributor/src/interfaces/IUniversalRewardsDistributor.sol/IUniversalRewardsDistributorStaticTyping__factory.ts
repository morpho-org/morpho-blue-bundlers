/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IUniversalRewardsDistributorStaticTyping,
  IUniversalRewardsDistributorStaticTypingInterface,
} from "../../../../../../lib/universal-rewards-distributor/src/interfaces/IUniversalRewardsDistributor.sol/IUniversalRewardsDistributorStaticTyping";

const _abi = [
  {
    inputs: [],
    name: "acceptRoot",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
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
        name: "claimable",
        type: "uint256",
      },
      {
        internalType: "bytes32[]",
        name: "proof",
        type: "bytes32[]",
      },
    ],
    name: "claim",
    outputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "claimed",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "ipfsHash",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "isUpdater",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
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
    name: "pendingRoot",
    outputs: [
      {
        internalType: "bytes32",
        name: "root",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "ipfsHash",
        type: "bytes32",
      },
      {
        internalType: "uint256",
        name: "validAt",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "revokePendingRoot",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "root",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "setOwner",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "newRoot",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "newIpfsHash",
        type: "bytes32",
      },
    ],
    name: "setRoot",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "updater",
        type: "address",
      },
      {
        internalType: "bool",
        name: "active",
        type: "bool",
      },
    ],
    name: "setRootUpdater",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "newTimelock",
        type: "uint256",
      },
    ],
    name: "setTimelock",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "newRoot",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "ipfsHash",
        type: "bytes32",
      },
    ],
    name: "submitRoot",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "timelock",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class IUniversalRewardsDistributorStaticTyping__factory {
  static readonly abi = _abi;
  static createInterface(): IUniversalRewardsDistributorStaticTypingInterface {
    return new Interface(
      _abi
    ) as IUniversalRewardsDistributorStaticTypingInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IUniversalRewardsDistributorStaticTyping {
    return new Contract(
      address,
      _abi,
      runner
    ) as unknown as IUniversalRewardsDistributorStaticTyping;
  }
}
