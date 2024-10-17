/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumberish,
  BytesLike,
  FunctionFragment,
  Result,
  Interface,
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";
import type {
  TypedContractEvent,
  TypedDeferredTopicFilter,
  TypedEventLog,
  TypedListener,
  TypedContractMethod,
} from "../common";

export interface UrdBundlerInterface extends Interface {
  getFunction(
    nameOrSignature: "initiator" | "multicall" | "urdClaim"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "initiator", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "multicall",
    values: [BytesLike[]]
  ): string;
  encodeFunctionData(
    functionFragment: "urdClaim",
    values: [
      AddressLike,
      AddressLike,
      AddressLike,
      BigNumberish,
      BytesLike[],
      boolean
    ]
  ): string;

  decodeFunctionResult(functionFragment: "initiator", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "multicall", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "urdClaim", data: BytesLike): Result;
}

export interface UrdBundler extends BaseContract {
  connect(runner?: ContractRunner | null): UrdBundler;
  waitForDeployment(): Promise<this>;

  interface: UrdBundlerInterface;

  queryFilter<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;
  queryFilter<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;

  on<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  on<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  once<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  once<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  listeners<TCEvent extends TypedContractEvent>(
    event: TCEvent
  ): Promise<Array<TypedListener<TCEvent>>>;
  listeners(eventName?: string): Promise<Array<Listener>>;
  removeAllListeners<TCEvent extends TypedContractEvent>(
    event?: TCEvent
  ): Promise<this>;

  initiator: TypedContractMethod<[], [string], "view">;

  multicall: TypedContractMethod<[data: BytesLike[]], [void], "payable">;

  urdClaim: TypedContractMethod<
    [
      distributor: AddressLike,
      account: AddressLike,
      reward: AddressLike,
      amount: BigNumberish,
      proof: BytesLike[],
      skipRevert: boolean
    ],
    [void],
    "payable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "initiator"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "multicall"
  ): TypedContractMethod<[data: BytesLike[]], [void], "payable">;
  getFunction(
    nameOrSignature: "urdClaim"
  ): TypedContractMethod<
    [
      distributor: AddressLike,
      account: AddressLike,
      reward: AddressLike,
      amount: BigNumberish,
      proof: BytesLike[],
      skipRevert: boolean
    ],
    [void],
    "payable"
  >;

  filters: {};
}
