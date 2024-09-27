export const baseBundlerAbi = [
  {
    type: "function",
    name: "initiator",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "multicall",
    inputs: [{ name: "data", type: "bytes[]", internalType: "bytes[]" }],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const transferBundlerAbi = [
  ...baseBundlerAbi,
  {
    type: "function",
    name: "erc20Transfer",
    inputs: [
      { name: "asset", type: "address", internalType: "address" },
      { name: "recipient", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "erc20TransferFrom",
    inputs: [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "nativeTransfer",
    inputs: [
      { name: "recipient", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const permitBundlerAbi = [
  ...baseBundlerAbi,
  {
    type: "function",
    name: "permit",
    inputs: [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
      { name: "deadline", type: "uint256", internalType: "uint256" },
      { name: "v", type: "uint8", internalType: "uint8" },
      { name: "r", type: "bytes32", internalType: "bytes32" },
      { name: "s", type: "bytes32", internalType: "bytes32" },
      { name: "skipRevert", type: "bool", internalType: "bool" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const ethereumPermitBundlerAbi = [
  ...permitBundlerAbi,
  {
    type: "function",
    name: "permitDai",
    inputs: [
      { name: "nonce", type: "uint256", internalType: "uint256" },
      { name: "expiry", type: "uint256", internalType: "uint256" },
      { name: "allowed", type: "bool", internalType: "bool" },
      { name: "v", type: "uint8", internalType: "uint8" },
      { name: "r", type: "bytes32", internalType: "bytes32" },
      { name: "s", type: "bytes32", internalType: "bytes32" },
      { name: "skipRevert", type: "bool", internalType: "bool" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const permit2BundlerAbi = [
  ...baseBundlerAbi,
  {
    type: "function",
    name: "approve2",
    inputs: [
      {
        name: "permitSingle",
        type: "tuple",
        internalType: "struct IAllowanceTransfer.PermitSingle",
        components: [
          {
            name: "details",
            type: "tuple",
            internalType: "struct IAllowanceTransfer.PermitDetails",
            components: [
              { name: "token", type: "address", internalType: "address" },
              { name: "amount", type: "uint160", internalType: "uint160" },
              { name: "expiration", type: "uint48", internalType: "uint48" },
              { name: "nonce", type: "uint48", internalType: "uint48" },
            ],
          },
          { name: "spender", type: "address", internalType: "address" },
          { name: "sigDeadline", type: "uint256", internalType: "uint256" },
        ],
      },
      { name: "signature", type: "bytes", internalType: "bytes" },
      { name: "skipRevert", type: "bool", internalType: "bool" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "transferFrom2",
    inputs: [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  { type: "error", name: "UnsafeCast", inputs: [] },
] as const;

export const erc20WrapperBundlerAbi = [
  ...baseBundlerAbi,
  {
    type: "function",
    name: "erc20WrapperDepositFor",
    inputs: [
      { name: "wrapper", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "erc20WrapperWithdrawTo",
    inputs: [
      { name: "wrapper", type: "address", internalType: "address" },
      { name: "account", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const erc4626BundlerAbi = [
  ...baseBundlerAbi,
  {
    type: "function",
    name: "erc4626Deposit",
    inputs: [
      { name: "vault", type: "address", internalType: "address" },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "minShares", type: "uint256", internalType: "uint256" },
      { name: "receiver", type: "address", internalType: "address" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "erc4626Mint",
    inputs: [
      { name: "vault", type: "address", internalType: "address" },
      { name: "shares", type: "uint256", internalType: "uint256" },
      { name: "maxAssets", type: "uint256", internalType: "uint256" },
      { name: "receiver", type: "address", internalType: "address" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "erc4626Redeem",
    inputs: [
      { name: "vault", type: "address", internalType: "address" },
      { name: "shares", type: "uint256", internalType: "uint256" },
      { name: "minAssets", type: "uint256", internalType: "uint256" },
      { name: "receiver", type: "address", internalType: "address" },
      { name: "owner", type: "address", internalType: "address" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "erc4626Withdraw",
    inputs: [
      { name: "vault", type: "address", internalType: "address" },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "maxShares", type: "uint256", internalType: "uint256" },
      { name: "receiver", type: "address", internalType: "address" },
      { name: "owner", type: "address", internalType: "address" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const morphoBundlerAbi = [
  ...baseBundlerAbi,
  {
    type: "function",
    name: "MORPHO",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "contract IMorpho" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "morphoBorrow",
    inputs: [
      {
        name: "marketParams",
        type: "tuple",
        internalType: "struct MarketParams",
        components: [
          { name: "loanToken", type: "address", internalType: "address" },
          { name: "collateralToken", type: "address", internalType: "address" },
          { name: "oracle", type: "address", internalType: "address" },
          { name: "irm", type: "address", internalType: "address" },
          { name: "lltv", type: "uint256", internalType: "uint256" },
        ],
      },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "shares", type: "uint256", internalType: "uint256" },
      { name: "slippageAmount", type: "uint256", internalType: "uint256" },
      { name: "receiver", type: "address", internalType: "address" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "morphoFlashLoan",
    inputs: [
      { name: "token", type: "address", internalType: "address" },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "data", type: "bytes", internalType: "bytes" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "morphoRepay",
    inputs: [
      {
        name: "marketParams",
        type: "tuple",
        internalType: "struct MarketParams",
        components: [
          { name: "loanToken", type: "address", internalType: "address" },
          { name: "collateralToken", type: "address", internalType: "address" },
          { name: "oracle", type: "address", internalType: "address" },
          { name: "irm", type: "address", internalType: "address" },
          { name: "lltv", type: "uint256", internalType: "uint256" },
        ],
      },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "shares", type: "uint256", internalType: "uint256" },
      { name: "slippageAmount", type: "uint256", internalType: "uint256" },
      { name: "onBehalf", type: "address", internalType: "address" },
      { name: "data", type: "bytes", internalType: "bytes" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "morphoSetAuthorizationWithSig",
    inputs: [
      {
        name: "authorization",
        type: "tuple",
        internalType: "struct Authorization",
        components: [
          { name: "authorizer", type: "address", internalType: "address" },
          { name: "authorized", type: "address", internalType: "address" },
          { name: "isAuthorized", type: "bool", internalType: "bool" },
          { name: "nonce", type: "uint256", internalType: "uint256" },
          { name: "deadline", type: "uint256", internalType: "uint256" },
        ],
      },
      {
        name: "signature",
        type: "tuple",
        internalType: "struct Signature",
        components: [
          { name: "v", type: "uint8", internalType: "uint8" },
          { name: "r", type: "bytes32", internalType: "bytes32" },
          { name: "s", type: "bytes32", internalType: "bytes32" },
        ],
      },
      { name: "skipRevert", type: "bool", internalType: "bool" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "morphoSupply",
    inputs: [
      {
        name: "marketParams",
        type: "tuple",
        internalType: "struct MarketParams",
        components: [
          { name: "loanToken", type: "address", internalType: "address" },
          { name: "collateralToken", type: "address", internalType: "address" },
          { name: "oracle", type: "address", internalType: "address" },
          { name: "irm", type: "address", internalType: "address" },
          { name: "lltv", type: "uint256", internalType: "uint256" },
        ],
      },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "shares", type: "uint256", internalType: "uint256" },
      { name: "slippageAmount", type: "uint256", internalType: "uint256" },
      { name: "onBehalf", type: "address", internalType: "address" },
      { name: "data", type: "bytes", internalType: "bytes" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "morphoSupplyCollateral",
    inputs: [
      {
        name: "marketParams",
        type: "tuple",
        internalType: "struct MarketParams",
        components: [
          { name: "loanToken", type: "address", internalType: "address" },
          { name: "collateralToken", type: "address", internalType: "address" },
          { name: "oracle", type: "address", internalType: "address" },
          { name: "irm", type: "address", internalType: "address" },
          { name: "lltv", type: "uint256", internalType: "uint256" },
        ],
      },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "onBehalf", type: "address", internalType: "address" },
      { name: "data", type: "bytes", internalType: "bytes" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "morphoWithdraw",
    inputs: [
      {
        name: "marketParams",
        type: "tuple",
        internalType: "struct MarketParams",
        components: [
          { name: "loanToken", type: "address", internalType: "address" },
          { name: "collateralToken", type: "address", internalType: "address" },
          { name: "oracle", type: "address", internalType: "address" },
          { name: "irm", type: "address", internalType: "address" },
          { name: "lltv", type: "uint256", internalType: "uint256" },
        ],
      },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "shares", type: "uint256", internalType: "uint256" },
      { name: "slippageAmount", type: "uint256", internalType: "uint256" },
      { name: "receiver", type: "address", internalType: "address" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "morphoWithdrawCollateral",
    inputs: [
      {
        name: "marketParams",
        type: "tuple",
        internalType: "struct MarketParams",
        components: [
          { name: "loanToken", type: "address", internalType: "address" },
          { name: "collateralToken", type: "address", internalType: "address" },
          { name: "oracle", type: "address", internalType: "address" },
          { name: "irm", type: "address", internalType: "address" },
          { name: "lltv", type: "uint256", internalType: "uint256" },
        ],
      },
      { name: "assets", type: "uint256", internalType: "uint256" },
      { name: "receiver", type: "address", internalType: "address" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "onMorphoFlashLoan",
    inputs: [
      { name: "", type: "uint256", internalType: "uint256" },
      { name: "data", type: "bytes", internalType: "bytes" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "onMorphoRepay",
    inputs: [
      { name: "", type: "uint256", internalType: "uint256" },
      { name: "data", type: "bytes", internalType: "bytes" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "onMorphoSupply",
    inputs: [
      { name: "", type: "uint256", internalType: "uint256" },
      { name: "data", type: "bytes", internalType: "bytes" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "onMorphoSupplyCollateral",
    inputs: [
      { name: "", type: "uint256", internalType: "uint256" },
      { name: "data", type: "bytes", internalType: "bytes" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "reallocateTo",
    inputs: [
      { name: "publicAllocator", type: "address", internalType: "address" },
      { name: "vault", type: "address", internalType: "address" },
      { name: "value", type: "uint256", internalType: "uint256" },
      {
        name: "withdrawals",
        type: "tuple[]",
        internalType: "struct Withdrawal[]",
        components: [
          {
            name: "marketParams",
            type: "tuple",
            internalType: "struct MarketParams",
            components: [
              { name: "loanToken", type: "address", internalType: "address" },
              { name: "collateralToken", type: "address", internalType: "address" },
              { name: "oracle", type: "address", internalType: "address" },
              { name: "irm", type: "address", internalType: "address" },
              { name: "lltv", type: "uint256", internalType: "uint256" },
            ],
          },
          { name: "amount", type: "uint128", internalType: "uint128" },
        ],
      },
      {
        name: "supplyMarketParams",
        type: "tuple",
        internalType: "struct MarketParams",
        components: [
          { name: "loanToken", type: "address", internalType: "address" },
          { name: "collateralToken", type: "address", internalType: "address" },
          { name: "oracle", type: "address", internalType: "address" },
          { name: "irm", type: "address", internalType: "address" },
          { name: "lltv", type: "uint256", internalType: "uint256" },
        ],
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const urdBundlerAbi = [
  ...baseBundlerAbi,
  {
    type: "function",
    name: "urdClaim",
    inputs: [
      { name: "distributor", type: "address", internalType: "address" },
      { name: "account", type: "address", internalType: "address" },
      { name: "reward", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
      { name: "proof", type: "bytes32[]", internalType: "bytes32[]" },
      { name: "skipRevert", type: "bool", internalType: "bool" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const wNativeBundlerAbi = [
  ...baseBundlerAbi,
  { type: "receive", stateMutability: "payable" },
  {
    type: "function",
    name: "WRAPPED_NATIVE",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "unwrapNative",
    inputs: [{ name: "amount", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "wrapNative",
    inputs: [{ name: "amount", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const stEthBundlerAbi = [
  ...baseBundlerAbi,
  {
    type: "function",
    name: "ST_ETH",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "WST_ETH",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "stakeEth",
    inputs: [
      { name: "amount", type: "uint256", internalType: "uint256" },
      { name: "minShares", type: "uint256", internalType: "uint256" },
      { name: "referral", type: "address", internalType: "address" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "unwrapStEth",
    inputs: [{ name: "amount", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "wrapStEth",
    inputs: [{ name: "amount", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const aaveV2MigrationBundlerAbi = [
  ...transferBundlerAbi,
  ...permitBundlerAbi,
  ...permit2BundlerAbi,
  ...stEthBundlerAbi,
  ...erc4626BundlerAbi,
  ...morphoBundlerAbi,
  {
    type: "constructor",
    inputs: [
      { name: "morpho", type: "address", internalType: "address" },
      { name: "aaveV2Pool", type: "address", internalType: "address" },
      { name: "wstEth", type: "address", internalType: "address" },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "AAVE_V2_POOL",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "contract IAaveV2" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "aaveV2Repay",
    inputs: [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
      { name: "interestRateMode", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "aaveV2Withdraw",
    inputs: [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  { type: "error", name: "UnsafeCast", inputs: [] },
] as const;

export const aaveV3MigrationBundlerAbi = [
  ...transferBundlerAbi,
  ...permitBundlerAbi,
  ...permit2BundlerAbi,
  ...stEthBundlerAbi,
  ...erc4626BundlerAbi,
  ...morphoBundlerAbi,
  {
    type: "constructor",
    inputs: [
      { name: "morpho", type: "address", internalType: "address" },
      { name: "aaveV3Pool", type: "address", internalType: "address" },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "AAVE_V3_POOL",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "contract IAaveV3" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "aaveV3Repay",
    inputs: [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
      { name: "interestRateMode", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "aaveV3Withdraw",
    inputs: [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  { type: "error", name: "UnsafeCast", inputs: [] },
] as const;

export const aaveV3OptimizerMigrationBundlerAbi = [
  ...transferBundlerAbi,
  ...permitBundlerAbi,
  ...permit2BundlerAbi,
  ...stEthBundlerAbi,
  ...erc4626BundlerAbi,
  ...morphoBundlerAbi,
  {
    type: "constructor",
    inputs: [
      { name: "morpho", type: "address", internalType: "address" },
      { name: "aaveV3Optimizer", type: "address", internalType: "address" },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "AAVE_V3_OPTIMIZER",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "contract IAaveV3Optimizer" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "aaveV3OptimizerApproveManagerWithSig",
    inputs: [
      { name: "isApproved", type: "bool", internalType: "bool" },
      { name: "nonce", type: "uint256", internalType: "uint256" },
      { name: "deadline", type: "uint256", internalType: "uint256" },
      {
        name: "signature",
        type: "tuple",
        internalType: "struct Signature",
        components: [
          { name: "v", type: "uint8", internalType: "uint8" },
          { name: "r", type: "bytes32", internalType: "bytes32" },
          { name: "s", type: "bytes32", internalType: "bytes32" },
        ],
      },
      { name: "skipRevert", type: "bool", internalType: "bool" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "aaveV3OptimizerRepay",
    inputs: [
      { name: "underlying", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "aaveV3OptimizerWithdraw",
    inputs: [
      { name: "underlying", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
      { name: "maxIterations", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "aaveV3OptimizerWithdrawCollateral",
    inputs: [
      { name: "underlying", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  { type: "error", name: "UnsafeCast", inputs: [] },
] as const;

export const compoundV2MigrationBundlerAbi = [
  ...transferBundlerAbi,
  ...permitBundlerAbi,
  ...permit2BundlerAbi,
  ...stEthBundlerAbi,
  ...erc4626BundlerAbi,
  ...morphoBundlerAbi,
  {
    type: "constructor",
    inputs: [
      { name: "morpho", type: "address", internalType: "address" },
      { name: "wNative", type: "address", internalType: "address" },
      { name: "cEth", type: "address", internalType: "address" },
    ],
    stateMutability: "nonpayable",
  },
  { type: "receive", stateMutability: "payable" },
  {
    type: "function",
    name: "C_ETH",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "compoundV2Redeem",
    inputs: [
      { name: "cToken", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "compoundV2Repay",
    inputs: [
      { name: "cToken", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  { type: "error", name: "UnsafeCast", inputs: [] },
] as const;

export const compoundV3MigrationBundlerAbi = [
  ...transferBundlerAbi,
  ...permitBundlerAbi,
  ...permit2BundlerAbi,
  ...stEthBundlerAbi,
  ...erc4626BundlerAbi,
  ...morphoBundlerAbi,
  {
    type: "constructor",
    inputs: [{ name: "morpho", type: "address", internalType: "address" }],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "compoundV3AllowBySig",
    inputs: [
      { name: "instance", type: "address", internalType: "address" },
      { name: "isAllowed", type: "bool", internalType: "bool" },
      { name: "nonce", type: "uint256", internalType: "uint256" },
      { name: "expiry", type: "uint256", internalType: "uint256" },
      { name: "v", type: "uint8", internalType: "uint8" },
      { name: "r", type: "bytes32", internalType: "bytes32" },
      { name: "s", type: "bytes32", internalType: "bytes32" },
      { name: "skipRevert", type: "bool", internalType: "bool" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "compoundV3Repay",
    inputs: [
      { name: "instance", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "compoundV3WithdrawFrom",
    inputs: [
      { name: "instance", type: "address", internalType: "address" },
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  { type: "error", name: "UnsafeCast", inputs: [] },
] as const;
