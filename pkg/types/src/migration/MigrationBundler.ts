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
} from "../../common";

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

export type WithdrawalStruct = {
  marketParams: MarketParamsStruct;
  amount: BigNumberish;
};

export type WithdrawalStructOutput = [
  marketParams: MarketParamsStructOutput,
  amount: bigint
] & { marketParams: MarketParamsStructOutput; amount: bigint };

export declare namespace IAllowanceTransfer {
  export type PermitDetailsStruct = {
    token: AddressLike;
    amount: BigNumberish;
    expiration: BigNumberish;
    nonce: BigNumberish;
  };

  export type PermitDetailsStructOutput = [
    token: string,
    amount: bigint,
    expiration: bigint,
    nonce: bigint
  ] & { token: string; amount: bigint; expiration: bigint; nonce: bigint };

  export type PermitSingleStruct = {
    details: IAllowanceTransfer.PermitDetailsStruct;
    spender: AddressLike;
    sigDeadline: BigNumberish;
  };

  export type PermitSingleStructOutput = [
    details: IAllowanceTransfer.PermitDetailsStructOutput,
    spender: string,
    sigDeadline: bigint
  ] & {
    details: IAllowanceTransfer.PermitDetailsStructOutput;
    spender: string;
    sigDeadline: bigint;
  };
}

export interface MigrationBundlerInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "MORPHO"
      | "approve2"
      | "erc20Transfer"
      | "erc20TransferFrom"
      | "erc4626Deposit"
      | "erc4626Mint"
      | "erc4626Redeem"
      | "erc4626Withdraw"
      | "initiator"
      | "morphoBorrow"
      | "morphoFlashLoan"
      | "morphoRepay"
      | "morphoSetAuthorizationWithSig"
      | "morphoSupply"
      | "morphoSupplyCollateral"
      | "morphoWithdraw"
      | "morphoWithdrawCollateral"
      | "multicall"
      | "nativeTransfer"
      | "onMorphoFlashLoan"
      | "onMorphoRepay"
      | "onMorphoSupply"
      | "onMorphoSupplyCollateral"
      | "permit"
      | "reallocateTo"
      | "transferFrom2"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "MORPHO", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "approve2",
    values: [IAllowanceTransfer.PermitSingleStruct, BytesLike, boolean]
  ): string;
  encodeFunctionData(
    functionFragment: "erc20Transfer",
    values: [AddressLike, AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "erc20TransferFrom",
    values: [AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "erc4626Deposit",
    values: [AddressLike, BigNumberish, BigNumberish, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "erc4626Mint",
    values: [AddressLike, BigNumberish, BigNumberish, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "erc4626Redeem",
    values: [AddressLike, BigNumberish, BigNumberish, AddressLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "erc4626Withdraw",
    values: [AddressLike, BigNumberish, BigNumberish, AddressLike, AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "initiator", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "morphoBorrow",
    values: [
      MarketParamsStruct,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      AddressLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "morphoFlashLoan",
    values: [AddressLike, BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "morphoRepay",
    values: [
      MarketParamsStruct,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      AddressLike,
      BytesLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "morphoSetAuthorizationWithSig",
    values: [AuthorizationStruct, SignatureStruct, boolean]
  ): string;
  encodeFunctionData(
    functionFragment: "morphoSupply",
    values: [
      MarketParamsStruct,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      AddressLike,
      BytesLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "morphoSupplyCollateral",
    values: [MarketParamsStruct, BigNumberish, AddressLike, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "morphoWithdraw",
    values: [
      MarketParamsStruct,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      AddressLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "morphoWithdrawCollateral",
    values: [MarketParamsStruct, BigNumberish, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "multicall",
    values: [BytesLike[]]
  ): string;
  encodeFunctionData(
    functionFragment: "nativeTransfer",
    values: [AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "onMorphoFlashLoan",
    values: [BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "onMorphoRepay",
    values: [BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "onMorphoSupply",
    values: [BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "onMorphoSupplyCollateral",
    values: [BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "permit",
    values: [
      AddressLike,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      BytesLike,
      BytesLike,
      boolean
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "reallocateTo",
    values: [
      AddressLike,
      AddressLike,
      BigNumberish,
      WithdrawalStruct[],
      MarketParamsStruct
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "transferFrom2",
    values: [AddressLike, BigNumberish]
  ): string;

  decodeFunctionResult(functionFragment: "MORPHO", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "approve2", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "erc20Transfer",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "erc20TransferFrom",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "erc4626Deposit",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "erc4626Mint",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "erc4626Redeem",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "erc4626Withdraw",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "initiator", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "morphoBorrow",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "morphoFlashLoan",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "morphoRepay",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "morphoSetAuthorizationWithSig",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "morphoSupply",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "morphoSupplyCollateral",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "morphoWithdraw",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "morphoWithdrawCollateral",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "multicall", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "nativeTransfer",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "onMorphoFlashLoan",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "onMorphoRepay",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "onMorphoSupply",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "onMorphoSupplyCollateral",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "permit", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "reallocateTo",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "transferFrom2",
    data: BytesLike
  ): Result;
}

export interface MigrationBundler extends BaseContract {
  connect(runner?: ContractRunner | null): MigrationBundler;
  waitForDeployment(): Promise<this>;

  interface: MigrationBundlerInterface;

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

  approve2: TypedContractMethod<
    [
      permitSingle: IAllowanceTransfer.PermitSingleStruct,
      signature: BytesLike,
      skipRevert: boolean
    ],
    [void],
    "payable"
  >;

  erc20Transfer: TypedContractMethod<
    [asset: AddressLike, recipient: AddressLike, amount: BigNumberish],
    [void],
    "payable"
  >;

  erc20TransferFrom: TypedContractMethod<
    [asset: AddressLike, amount: BigNumberish],
    [void],
    "payable"
  >;

  erc4626Deposit: TypedContractMethod<
    [
      vault: AddressLike,
      assets: BigNumberish,
      minShares: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;

  erc4626Mint: TypedContractMethod<
    [
      vault: AddressLike,
      shares: BigNumberish,
      maxAssets: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;

  erc4626Redeem: TypedContractMethod<
    [
      vault: AddressLike,
      shares: BigNumberish,
      minAssets: BigNumberish,
      receiver: AddressLike,
      owner: AddressLike
    ],
    [void],
    "payable"
  >;

  erc4626Withdraw: TypedContractMethod<
    [
      vault: AddressLike,
      assets: BigNumberish,
      maxShares: BigNumberish,
      receiver: AddressLike,
      owner: AddressLike
    ],
    [void],
    "payable"
  >;

  initiator: TypedContractMethod<[], [string], "view">;

  morphoBorrow: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      slippageAmount: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;

  morphoFlashLoan: TypedContractMethod<
    [token: AddressLike, assets: BigNumberish, data: BytesLike],
    [void],
    "payable"
  >;

  morphoRepay: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      slippageAmount: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [void],
    "payable"
  >;

  morphoSetAuthorizationWithSig: TypedContractMethod<
    [
      authorization: AuthorizationStruct,
      signature: SignatureStruct,
      skipRevert: boolean
    ],
    [void],
    "payable"
  >;

  morphoSupply: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      slippageAmount: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [void],
    "payable"
  >;

  morphoSupplyCollateral: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [void],
    "payable"
  >;

  morphoWithdraw: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      slippageAmount: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;

  morphoWithdrawCollateral: TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;

  multicall: TypedContractMethod<[data: BytesLike[]], [void], "payable">;

  nativeTransfer: TypedContractMethod<
    [recipient: AddressLike, amount: BigNumberish],
    [void],
    "payable"
  >;

  onMorphoFlashLoan: TypedContractMethod<
    [arg0: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;

  onMorphoRepay: TypedContractMethod<
    [arg0: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;

  onMorphoSupply: TypedContractMethod<
    [arg0: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;

  onMorphoSupplyCollateral: TypedContractMethod<
    [arg0: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;

  permit: TypedContractMethod<
    [
      asset: AddressLike,
      amount: BigNumberish,
      deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      skipRevert: boolean
    ],
    [void],
    "payable"
  >;

  reallocateTo: TypedContractMethod<
    [
      publicAllocator: AddressLike,
      vault: AddressLike,
      value: BigNumberish,
      withdrawals: WithdrawalStruct[],
      supplyMarketParams: MarketParamsStruct
    ],
    [void],
    "payable"
  >;

  transferFrom2: TypedContractMethod<
    [asset: AddressLike, amount: BigNumberish],
    [void],
    "payable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "MORPHO"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "approve2"
  ): TypedContractMethod<
    [
      permitSingle: IAllowanceTransfer.PermitSingleStruct,
      signature: BytesLike,
      skipRevert: boolean
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "erc20Transfer"
  ): TypedContractMethod<
    [asset: AddressLike, recipient: AddressLike, amount: BigNumberish],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "erc20TransferFrom"
  ): TypedContractMethod<
    [asset: AddressLike, amount: BigNumberish],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "erc4626Deposit"
  ): TypedContractMethod<
    [
      vault: AddressLike,
      assets: BigNumberish,
      minShares: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "erc4626Mint"
  ): TypedContractMethod<
    [
      vault: AddressLike,
      shares: BigNumberish,
      maxAssets: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "erc4626Redeem"
  ): TypedContractMethod<
    [
      vault: AddressLike,
      shares: BigNumberish,
      minAssets: BigNumberish,
      receiver: AddressLike,
      owner: AddressLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "erc4626Withdraw"
  ): TypedContractMethod<
    [
      vault: AddressLike,
      assets: BigNumberish,
      maxShares: BigNumberish,
      receiver: AddressLike,
      owner: AddressLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "initiator"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "morphoBorrow"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      slippageAmount: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "morphoFlashLoan"
  ): TypedContractMethod<
    [token: AddressLike, assets: BigNumberish, data: BytesLike],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "morphoRepay"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      slippageAmount: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "morphoSetAuthorizationWithSig"
  ): TypedContractMethod<
    [
      authorization: AuthorizationStruct,
      signature: SignatureStruct,
      skipRevert: boolean
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "morphoSupply"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      slippageAmount: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "morphoSupplyCollateral"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      onBehalf: AddressLike,
      data: BytesLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "morphoWithdraw"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      shares: BigNumberish,
      slippageAmount: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "morphoWithdrawCollateral"
  ): TypedContractMethod<
    [
      marketParams: MarketParamsStruct,
      assets: BigNumberish,
      receiver: AddressLike
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "multicall"
  ): TypedContractMethod<[data: BytesLike[]], [void], "payable">;
  getFunction(
    nameOrSignature: "nativeTransfer"
  ): TypedContractMethod<
    [recipient: AddressLike, amount: BigNumberish],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "onMorphoFlashLoan"
  ): TypedContractMethod<
    [arg0: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "onMorphoRepay"
  ): TypedContractMethod<
    [arg0: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "onMorphoSupply"
  ): TypedContractMethod<
    [arg0: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "onMorphoSupplyCollateral"
  ): TypedContractMethod<
    [arg0: BigNumberish, data: BytesLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "permit"
  ): TypedContractMethod<
    [
      asset: AddressLike,
      amount: BigNumberish,
      deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      skipRevert: boolean
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "reallocateTo"
  ): TypedContractMethod<
    [
      publicAllocator: AddressLike,
      vault: AddressLike,
      value: BigNumberish,
      withdrawals: WithdrawalStruct[],
      supplyMarketParams: MarketParamsStruct
    ],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "transferFrom2"
  ): TypedContractMethod<
    [asset: AddressLike, amount: BigNumberish],
    [void],
    "payable"
  >;

  filters: {};
}
