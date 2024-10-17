/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IMorphoLiquidateCallback,
  IMorphoLiquidateCallbackInterface,
} from "../../../../../../lib/morpho-blue/src/interfaces/IMorphoCallbacks.sol/IMorphoLiquidateCallback";

const _abi = [
  {
    inputs: [
      {
        internalType: "uint256",
        name: "repaidAssets",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "onMorphoLiquidate",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IMorphoLiquidateCallback__factory {
  static readonly abi = _abi;
  static createInterface(): IMorphoLiquidateCallbackInterface {
    return new Interface(_abi) as IMorphoLiquidateCallbackInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IMorphoLiquidateCallback {
    return new Contract(
      address,
      _abi,
      runner
    ) as unknown as IMorphoLiquidateCallback;
  }
}
