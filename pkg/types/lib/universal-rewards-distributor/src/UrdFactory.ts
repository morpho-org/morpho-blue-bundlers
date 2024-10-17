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
} from "../../../common";

export interface UrdFactoryInterface extends Interface {
  getFunction(nameOrSignature: "createUrd" | "isUrd"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "createUrd",
    values: [AddressLike, BigNumberish, BytesLike, BytesLike, BytesLike]
  ): string;
  encodeFunctionData(functionFragment: "isUrd", values: [AddressLike]): string;

  decodeFunctionResult(functionFragment: "createUrd", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isUrd", data: BytesLike): Result;
}

export interface UrdFactory extends BaseContract {
  connect(runner?: ContractRunner | null): UrdFactory;
  waitForDeployment(): Promise<this>;

  interface: UrdFactoryInterface;

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

  createUrd: TypedContractMethod<
    [
      initialOwner: AddressLike,
      initialTimelock: BigNumberish,
      initialRoot: BytesLike,
      initialIpfsHash: BytesLike,
      salt: BytesLike
    ],
    [string],
    "nonpayable"
  >;

  isUrd: TypedContractMethod<[arg0: AddressLike], [boolean], "view">;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "createUrd"
  ): TypedContractMethod<
    [
      initialOwner: AddressLike,
      initialTimelock: BigNumberish,
      initialRoot: BytesLike,
      initialIpfsHash: BytesLike,
      salt: BytesLike
    ],
    [string],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "isUrd"
  ): TypedContractMethod<[arg0: AddressLike], [boolean], "view">;

  filters: {};
}
