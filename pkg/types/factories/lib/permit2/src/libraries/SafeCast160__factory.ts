/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Contract,
  ContractFactory,
  ContractTransactionResponse,
  Interface,
} from "ethers";
import type { Signer, ContractDeployTransaction, ContractRunner } from "ethers";
import type { NonPayableOverrides } from "../../../../../common";
import type {
  SafeCast160,
  SafeCast160Interface,
} from "../../../../../lib/permit2/src/libraries/SafeCast160";

const _abi = [
  {
    inputs: [],
    name: "UnsafeCast",
    type: "error",
  },
] as const;

const _bytecode =
  "0x60808060405234601757603a9081601d823930815050f35b600080fdfe600080fdfea2646970667358221220b8ae5dcdbb0118ba315fe248c64d1898daf29120b0b74b959926cdf7d3651fa964736f6c63430008180033";

type SafeCast160ConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: SafeCast160ConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class SafeCast160__factory extends ContractFactory {
  constructor(...args: SafeCast160ConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(overrides || {});
  }
  override deploy(overrides?: NonPayableOverrides & { from?: string }) {
    return super.deploy(overrides || {}) as Promise<
      SafeCast160 & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): SafeCast160__factory {
    return super.connect(runner) as SafeCast160__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): SafeCast160Interface {
    return new Interface(_abi) as SafeCast160Interface;
  }
  static connect(address: string, runner?: ContractRunner | null): SafeCast160 {
    return new Contract(address, _abi, runner) as unknown as SafeCast160;
  }
}
