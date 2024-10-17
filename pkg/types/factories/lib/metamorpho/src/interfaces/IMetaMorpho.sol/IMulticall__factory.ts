/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IMulticall,
  IMulticallInterface,
} from "../../../../../../lib/metamorpho/src/interfaces/IMetaMorpho.sol/IMulticall";

const _abi = [
  {
    inputs: [
      {
        internalType: "bytes[]",
        name: "",
        type: "bytes[]",
      },
    ],
    name: "multicall",
    outputs: [
      {
        internalType: "bytes[]",
        name: "",
        type: "bytes[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IMulticall__factory {
  static readonly abi = _abi;
  static createInterface(): IMulticallInterface {
    return new Interface(_abi) as IMulticallInterface;
  }
  static connect(address: string, runner?: ContractRunner | null): IMulticall {
    return new Contract(address, _abi, runner) as unknown as IMulticall;
  }
}
