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
} from "../../../../../common";

export type MarketParamsStruct = {
  loanToken: AddressLike;
  collateralToken: AddressLike;
  oracle: AddressLike;
  irm: AddressLike;
  lltv: BigNumberish;
};

export type MarketParamsStructOutput = [
  loanToken: string,
  collateralToken: string,
  oracle: string,
  irm: string,
  lltv: bigint
] & {
  loanToken: string;
  collateralToken: string;
  oracle: string;
  irm: string;
  lltv: bigint;
};

export type WithdrawalStruct = {
  marketParams: MarketParamsStruct;
  amount: BigNumberish;
};

export type WithdrawalStructOutput = [
  marketParams: MarketParamsStructOutput,
  amount: bigint
] & { marketParams: MarketParamsStructOutput; amount: bigint };

export type FlowCapsStruct = { maxIn: BigNumberish; maxOut: BigNumberish };

export type FlowCapsStructOutput = [maxIn: bigint, maxOut: bigint] & {
  maxIn: bigint;
  maxOut: bigint;
};

export type FlowCapsConfigStruct = { id: BytesLike; caps: FlowCapsStruct };

export type FlowCapsConfigStructOutput = [
  id: string,
  caps: FlowCapsStructOutput
] & { id: string; caps: FlowCapsStructOutput };

export interface IPublicAllocatorStaticTypingInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "MORPHO"
      | "accruedFee"
      | "admin"
      | "fee"
      | "flowCaps"
      | "reallocateTo"
      | "setAdmin"
      | "setFee"
      | "setFlowCaps"
      | "transferFee"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "MORPHO", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "accruedFee",
    values: [AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "admin", values: [AddressLike]): string;
  encodeFunctionData(functionFragment: "fee", values: [AddressLike]): string;
  encodeFunctionData(
    functionFragment: "flowCaps",
    values: [AddressLike, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "reallocateTo",
    values: [AddressLike, WithdrawalStruct[], MarketParamsStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "setAdmin",
    values: [AddressLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setFee",
    values: [AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "setFlowCaps",
    values: [AddressLike, FlowCapsConfigStruct[]]
  ): string;
  encodeFunctionData(
    functionFragment: "transferFee",
    values: [AddressLike, AddressLike]
  ): string;

  decodeFunctionResult(functionFragment: "MORPHO", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "accruedFee", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "admin", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "fee", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "flowCaps", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "reallocateTo",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "setAdmin", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "setFee", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "setFlowCaps",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "transferFee",
    data: BytesLike
  ): Result;
}

export interface IPublicAllocatorStaticTyping extends BaseContract {
  connect(runner?: ContractRunner | null): IPublicAllocatorStaticTyping;
  waitForDeployment(): Promise<this>;

  interface: IPublicAllocatorStaticTypingInterface;

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

  MORPHO: TypedContractMethod<[], [string], "view">;

  accruedFee: TypedContractMethod<[vault: AddressLike], [bigint], "view">;

  admin: TypedContractMethod<[vault: AddressLike], [string], "view">;

  fee: TypedContractMethod<[vault: AddressLike], [bigint], "view">;

  flowCaps: TypedContractMethod<
    [vault: AddressLike, arg1: BytesLike],
    [[bigint, bigint]],
    "view"
  >;

  reallocateTo: TypedContractMethod<
    [
      vault: AddressLike,
      withdrawals: WithdrawalStruct[],
      supplyMarketParams: MarketParamsStruct
    ],
    [void],
    "payable"
  >;

  setAdmin: TypedContractMethod<
    [vault: AddressLike, newAdmin: AddressLike],
    [void],
    "nonpayable"
  >;

  setFee: TypedContractMethod<
    [vault: AddressLike, newFee: BigNumberish],
    [void],
    "nonpayable"
  >;

  setFlowCaps: TypedContractMethod<
    [vault: AddressLike, config: FlowCapsConfigStruct[]],
    [void],
    "nonpayable"
  >;

  transferFee: TypedContractMethod<
    [vault: AddressLike, feeRecipient: AddressLike],
    [void],
    "nonpayable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "MORPHO"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "accruedFee"
  ): TypedContractMethod<[vault: AddressLike], [bigint], "view">;
  getFunction(
    nameOrSignature: "admin"
  ): TypedContractMethod<[vault: AddressLike], [string], "view">;
  getFunction(
    nameOrSignature: "fee"
  ): TypedContractMethod<[vault: AddressLike], [bigint], "view">;
  getFunction(
    nameOrSignature: "flowCaps"
  ): TypedContractMethod<
    [vault: AddressLike, arg1: BytesLike],
    [[bigint, bigint]],
    "view"
  >;
  getFunction(
    nameOrSignature: "reallocateTo"
  ): TypedContractMethod<
    [
      vault: AddressLike,
      withdrawals: WithdrawalStruct[],
      supplyMarketParams: MarketParamsStruct
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "setAdmin"
  ): TypedContractMethod<
    [vault: AddressLike, newAdmin: AddressLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setFee"
  ): TypedContractMethod<
    [vault: AddressLike, newFee: BigNumberish],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setFlowCaps"
  ): TypedContractMethod<
    [vault: AddressLike, config: FlowCapsConfigStruct[]],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "transferFee"
  ): TypedContractMethod<
    [vault: AddressLike, feeRecipient: AddressLike],
    [void],
    "nonpayable"
  >;

  filters: {};
}
