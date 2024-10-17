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
} from "../../../../../../../common";

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

export type MarketStruct = {
  totalSupplyAssets: BigNumberish;
  totalSupplyShares: BigNumberish;
  totalBorrowAssets: BigNumberish;
  totalBorrowShares: BigNumberish;
  lastUpdate: BigNumberish;
  fee: BigNumberish;
};

export type MarketStructOutput = [
  totalSupplyAssets: bigint,
  totalSupplyShares: bigint,
  totalBorrowAssets: bigint,
  totalBorrowShares: bigint,
  lastUpdate: bigint,
  fee: bigint
] & {
  totalSupplyAssets: bigint;
  totalSupplyShares: bigint;
  totalBorrowAssets: bigint;
  totalBorrowShares: bigint;
  lastUpdate: bigint;
  fee: bigint;
};

export type PositionStruct = {
  supplyShares: BigNumberish;
  borrowShares: BigNumberish;
  collateral: BigNumberish;
};

export type PositionStructOutput = [
  supplyShares: bigint,
  borrowShares: bigint,
  collateral: bigint
] & { supplyShares: bigint; borrowShares: bigint; collateral: bigint };

export type AuthorizationStruct = {
  authorizer: AddressLike;
  authorized: AddressLike;
  isAuthorized: boolean;
  nonce: BigNumberish;
  deadline: BigNumberish;
};

export type AuthorizationStructOutput = [
  authorizer: string,
  authorized: string,
  isAuthorized: boolean,
  nonce: bigint,
  deadline: bigint
] & {
  authorizer: string;
  authorized: string;
  isAuthorized: boolean;
  nonce: bigint;
  deadline: bigint;
};

export type SignatureStruct = { v: BigNumberish; r: BytesLike; s: BytesLike };

export type SignatureStructOutput = [v: bigint, r: string, s: string] & {
  v: bigint;
  r: string;
  s: string;
};

export interface IMorphoInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "DOMAIN_SEPARATOR"
      | "accrueInterest"
      | "borrow"
      | "createMarket"
      | "enableIrm"
      | "enableLltv"
      | "extSloads"
      | "feeRecipient"
      | "flashLoan"
      | "idToMarketParams"
      | "isAuthorized"
      | "isIrmEnabled"
      | "isLltvEnabled"
      | "liquidate"
      | "market"
      | "nonce"
      | "owner"
      | "position"
      | "repay"
      | "setAuthorization"
      | "setAuthorizationWithSig"
      | "setFee"
      | "setFeeRecipient"
      | "setOwner"
      | "supply"
      | "supplyCollateral"
      | "withdraw"
      | "withdrawCollateral"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "DOMAIN_SEPARATOR",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "accrueInterest",
    values: [MarketParamsStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "borrow",
    values: [
      MarketParamsStruct,
      BigNumberish,
      BigNumberish,
      AddressLike,
      AddressLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "createMarket",
    values: [MarketParamsStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "enableIrm",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "enableLltv",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "extSloads",
    values: [BytesLike[]]
  ): string;
  encodeFunctionData(
    functionFragment: "feeRecipient",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "flashLoan",
    values: [AddressLike, BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "idToMarketParams",
    values: [BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "isAuthorized",
    values: [AddressLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "isIrmEnabled",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "isLltvEnabled",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "liquidate",
    values: [
      MarketParamsStruct,
      AddressLike,
      BigNumberish,
      BigNumberish,
      BytesLike
    ]
  ): string;
  encodeFunctionData(functionFragment: "market", values: [BytesLike]): string;
  encodeFunctionData(functionFragment: "nonce", values: [AddressLike]): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "position",
    values: [BytesLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "repay",
    values: [
      MarketParamsStruct,
      BigNumberish,
      BigNumberish,
      AddressLike,
      BytesLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "setAuthorization",
    values: [AddressLike, boolean]
  ): string;
  encodeFunctionData(
    functionFragment: "setAuthorizationWithSig",
    values: [AuthorizationStruct, SignatureStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "setFee",
    values: [MarketParamsStruct, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "setFeeRecipient",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setOwner",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "supply",
    values: [
      MarketParamsStruct,
      BigNumberish,
      BigNumberish,
      AddressLike,
      BytesLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "supplyCollateral",
    values: [MarketParamsStruct, BigNumberish, AddressLike, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "withdraw",
    values: [
      MarketParamsStruct,
      BigNumberish,
      BigNumberish,
      AddressLike,
      AddressLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawCollateral",
    values: [MarketParamsStruct, BigNumberish, AddressLike, AddressLike]
  ): string;

  decodeFunctionResult(
    functionFragment: "DOMAIN_SEPARATOR",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "accrueInterest",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "borrow", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "createMarket",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "enableIrm", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "enableLltv", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "extSloads", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "feeRecipient",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "flashLoan", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "idToMarketParams",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "isAuthorized",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "isIrmEnabled",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "isLltvEnabled",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "liquidate", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "market", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "nonce", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "position", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "repay", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "setAuthorization",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setAuthorizationWithSig",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "setFee", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "setFeeRecipient",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "setOwner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "supply", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "supplyCollateral",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "withdraw", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "withdrawCollateral",
    data: BytesLike
  ): Result;
}

export interface IMorpho extends BaseContract {
  connect(runner?: ContractRunner | null): IMorpho;
  waitForDeployment(): Promise<this>;

  interface: IMorphoInterface;

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

  DOMAIN_SEPARATOR: TypedContractMethod<[], [string], "view">;

  accrueInterest: TypedContractMethod<
    [marketParams: MarketParamsStruct],
    [void],
    "nonpayable"
  >;

  borrow: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      onBehalf: AddressLike,
      receiver: AddressLike
    ],
    [[bigint, bigint] & { assetsBorrowed: bigint; sharesBorrowed: bigint }],
    "nonpayable"
  >;

  createMarket: TypedContractMethod<
    [marketParams: MarketParamsStruct],
    [void],
    "nonpayable"
  >;

  enableIrm: TypedContractMethod<[irm: AddressLike], [void], "nonpayable">;

  enableLltv: TypedContractMethod<[lltv: BigNumberish], [void], "nonpayable">;

  extSloads: TypedContractMethod<[slots: BytesLike[]], [string[]], "view">;

  feeRecipient: TypedContractMethod<[], [string], "view">;

  flashLoan: TypedContractMethod<
    [token: AddressLike, assets: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;

  idToMarketParams: TypedContractMethod<
    [id: BytesLike],
    [MarketParamsStructOutput],
    "view"
  >;

  isAuthorized: TypedContractMethod<
    [authorizer: AddressLike, authorized: AddressLike],
    [boolean],
    "view"
  >;

  isIrmEnabled: TypedContractMethod<[irm: AddressLike], [boolean], "view">;

  isLltvEnabled: TypedContractMethod<[lltv: BigNumberish], [boolean], "view">;

  liquidate: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      borrower: AddressLike,
      seizedAssets: BigNumberish,
      repaidShares: BigNumberish,
      data: BytesLike
    ],
    [[bigint, bigint]],
    "nonpayable"
  >;

  market: TypedContractMethod<[id: BytesLike], [MarketStructOutput], "view">;

  nonce: TypedContractMethod<[authorizer: AddressLike], [bigint], "view">;

  owner: TypedContractMethod<[], [string], "view">;

  position: TypedContractMethod<
    [id: BytesLike, user: AddressLike],
    [PositionStructOutput],
    "view"
  >;

  repay: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [[bigint, bigint] & { assetsRepaid: bigint; sharesRepaid: bigint }],
    "nonpayable"
  >;

  setAuthorization: TypedContractMethod<
    [authorized: AddressLike, newIsAuthorized: boolean],
    [void],
    "nonpayable"
  >;

  setAuthorizationWithSig: TypedContractMethod<
    [authorization: AuthorizationStruct, signature: SignatureStruct],
    [void],
    "nonpayable"
  >;

  setFee: TypedContractMethod<
    [marketParams: MarketParamsStruct, newFee: BigNumberish],
    [void],
    "nonpayable"
  >;

  setFeeRecipient: TypedContractMethod<
    [newFeeRecipient: AddressLike],
    [void],
    "nonpayable"
  >;

  setOwner: TypedContractMethod<[newOwner: AddressLike], [void], "nonpayable">;

  supply: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [[bigint, bigint] & { assetsSupplied: bigint; sharesSupplied: bigint }],
    "nonpayable"
  >;

  supplyCollateral: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [void],
    "nonpayable"
  >;

  withdraw: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      onBehalf: AddressLike,
      receiver: AddressLike
    ],
    [[bigint, bigint] & { assetsWithdrawn: bigint; sharesWithdrawn: bigint }],
    "nonpayable"
  >;

  withdrawCollateral: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      onBehalf: AddressLike,
      receiver: AddressLike
    ],
    [void],
    "nonpayable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "DOMAIN_SEPARATOR"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "accrueInterest"
  ): TypedContractMethod<
    [marketParams: MarketParamsStruct],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "borrow"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      onBehalf: AddressLike,
      receiver: AddressLike
    ],
    [[bigint, bigint] & { assetsBorrowed: bigint; sharesBorrowed: bigint }],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "createMarket"
  ): TypedContractMethod<
    [marketParams: MarketParamsStruct],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "enableIrm"
  ): TypedContractMethod<[irm: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "enableLltv"
  ): TypedContractMethod<[lltv: BigNumberish], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "extSloads"
  ): TypedContractMethod<[slots: BytesLike[]], [string[]], "view">;
  getFunction(
    nameOrSignature: "feeRecipient"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "flashLoan"
  ): TypedContractMethod<
    [token: AddressLike, assets: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "idToMarketParams"
  ): TypedContractMethod<[id: BytesLike], [MarketParamsStructOutput], "view">;
  getFunction(
    nameOrSignature: "isAuthorized"
  ): TypedContractMethod<
    [authorizer: AddressLike, authorized: AddressLike],
    [boolean],
    "view"
  >;
  getFunction(
    nameOrSignature: "isIrmEnabled"
  ): TypedContractMethod<[irm: AddressLike], [boolean], "view">;
  getFunction(
    nameOrSignature: "isLltvEnabled"
  ): TypedContractMethod<[lltv: BigNumberish], [boolean], "view">;
  getFunction(
    nameOrSignature: "liquidate"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      borrower: AddressLike,
      seizedAssets: BigNumberish,
      repaidShares: BigNumberish,
      data: BytesLike
    ],
    [[bigint, bigint]],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "market"
  ): TypedContractMethod<[id: BytesLike], [MarketStructOutput], "view">;
  getFunction(
    nameOrSignature: "nonce"
  ): TypedContractMethod<[authorizer: AddressLike], [bigint], "view">;
  getFunction(
    nameOrSignature: "owner"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "position"
  ): TypedContractMethod<
    [id: BytesLike, user: AddressLike],
    [PositionStructOutput],
    "view"
  >;
  getFunction(
    nameOrSignature: "repay"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [[bigint, bigint] & { assetsRepaid: bigint; sharesRepaid: bigint }],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setAuthorization"
  ): TypedContractMethod<
    [authorized: AddressLike, newIsAuthorized: boolean],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setAuthorizationWithSig"
  ): TypedContractMethod<
    [authorization: AuthorizationStruct, signature: SignatureStruct],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setFee"
  ): TypedContractMethod<
    [marketParams: MarketParamsStruct, newFee: BigNumberish],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setFeeRecipient"
  ): TypedContractMethod<[newFeeRecipient: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "setOwner"
  ): TypedContractMethod<[newOwner: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "supply"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [[bigint, bigint] & { assetsSupplied: bigint; sharesSupplied: bigint }],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "supplyCollateral"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "withdraw"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      onBehalf: AddressLike,
      receiver: AddressLike
    ],
    [[bigint, bigint] & { assetsWithdrawn: bigint; sharesWithdrawn: bigint }],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "withdrawCollateral"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      onBehalf: AddressLike,
      receiver: AddressLike
    ],
    [void],
    "nonpayable"
  >;

  filters: {};
}
