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

export interface IUniversalRewardsDistributorStaticTypingInterface
  extends Interface {
  getFunction(
    nameOrSignature:
      | "acceptRoot"
      | "claim"
      | "claimed"
      | "ipfsHash"
      | "isUpdater"
      | "owner"
      | "pendingRoot"
      | "revokePendingRoot"
      | "root"
      | "setOwner"
      | "setRoot"
      | "setRootUpdater"
      | "setTimelock"
      | "submitRoot"
      | "timelock"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "acceptRoot",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "claim",
    values: [AddressLike, AddressLike, BigNumberish, BytesLike[]]
  ): string;
  encodeFunctionData(
    functionFragment: "claimed",
    values: [AddressLike, AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "ipfsHash", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "isUpdater",
    values: [AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "pendingRoot",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "revokePendingRoot",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "root", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "setOwner",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setRoot",
    values: [BytesLike, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setRootUpdater",
    values: [AddressLike, boolean]
  ): string;
  encodeFunctionData(
    functionFragment: "setTimelock",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "submitRoot",
    values: [BytesLike, BytesLike]
  ): string;
  encodeFunctionData(functionFragment: "timelock", values?: undefined): string;

  decodeFunctionResult(functionFragment: "acceptRoot", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "claim", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "claimed", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "ipfsHash", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isUpdater", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "pendingRoot",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "revokePendingRoot",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "root", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "setOwner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "setRoot", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "setRootUpdater",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setTimelock",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "submitRoot", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "timelock", data: BytesLike): Result;
}

export interface IUniversalRewardsDistributorStaticTyping extends BaseContract {
  connect(
    runner?: ContractRunner | null
  ): IUniversalRewardsDistributorStaticTyping;
  waitForDeployment(): Promise<this>;

  interface: IUniversalRewardsDistributorStaticTypingInterface;

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

  acceptRoot: TypedContractMethod<[], [void], "nonpayable">;

  claim: TypedContractMethod<
    [
      account: AddressLike,
      reward: AddressLike,
      claimable: BigNumberish,
      proof: BytesLike[]
    ],
    [bigint],
    "nonpayable"
  >;

  claimed: TypedContractMethod<
    [arg0: AddressLike, arg1: AddressLike],
    [bigint],
    "view"
  >;

  ipfsHash: TypedContractMethod<[], [string], "view">;

  isUpdater: TypedContractMethod<[arg0: AddressLike], [boolean], "view">;

  owner: TypedContractMethod<[], [string], "view">;

  pendingRoot: TypedContractMethod<
    [],
    [
      [string, string, bigint] & {
        root: string;
        ipfsHash: string;
        validAt: bigint;
      }
    ],
    "view"
  >;

  revokePendingRoot: TypedContractMethod<[], [void], "nonpayable">;

  root: TypedContractMethod<[], [string], "view">;

  setOwner: TypedContractMethod<[newOwner: AddressLike], [void], "nonpayable">;

  setRoot: TypedContractMethod<
    [newRoot: BytesLike, newIpfsHash: BytesLike],
    [void],
    "nonpayable"
  >;

  setRootUpdater: TypedContractMethod<
    [updater: AddressLike, active: boolean],
    [void],
    "nonpayable"
  >;

  setTimelock: TypedContractMethod<
    [newTimelock: BigNumberish],
    [void],
    "nonpayable"
  >;

  submitRoot: TypedContractMethod<
    [newRoot: BytesLike, ipfsHash: BytesLike],
    [void],
    "nonpayable"
  >;

  timelock: TypedContractMethod<[], [bigint], "view">;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "acceptRoot"
  ): TypedContractMethod<[], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "claim"
  ): TypedContractMethod<
    [
      account: AddressLike,
      reward: AddressLike,
      claimable: BigNumberish,
      proof: BytesLike[]
    ],
    [bigint],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "claimed"
  ): TypedContractMethod<
    [arg0: AddressLike, arg1: AddressLike],
    [bigint],
    "view"
  >;
  getFunction(
    nameOrSignature: "ipfsHash"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "isUpdater"
  ): TypedContractMethod<[arg0: AddressLike], [boolean], "view">;
  getFunction(
    nameOrSignature: "owner"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "pendingRoot"
  ): TypedContractMethod<
    [],
    [
      [string, string, bigint] & {
        root: string;
        ipfsHash: string;
        validAt: bigint;
      }
    ],
    "view"
  >;
  getFunction(
    nameOrSignature: "revokePendingRoot"
  ): TypedContractMethod<[], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "root"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "setOwner"
  ): TypedContractMethod<[newOwner: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "setRoot"
  ): TypedContractMethod<
    [newRoot: BytesLike, newIpfsHash: BytesLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setRootUpdater"
  ): TypedContractMethod<
    [updater: AddressLike, active: boolean],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setTimelock"
  ): TypedContractMethod<[newTimelock: BigNumberish], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "submitRoot"
  ): TypedContractMethod<
    [newRoot: BytesLike, ipfsHash: BytesLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "timelock"
  ): TypedContractMethod<[], [bigint], "view">;

  filters: {};
}
