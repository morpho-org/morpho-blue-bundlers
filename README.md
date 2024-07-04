# Morpho Blue Bundlers

[Morpho Blue](https://github.com/morpho-org/morpho-blue) is a new lending primitive that offers better rates, high capital efficiency and extended flexibility to lenders & borrowers. `morpho-blue-bundlers` hosts the logic that builds alongside the core protocol like MetaMorpho and bundlers.

## Structure

![bundler-3](https://github.com/morpho-org/morpho-blue-bundlers/assets/74971347/827630e1-7abc-4f9d-a494-fe3fa7aa7053)

Each Bundler is a domain-specific abstract layer of contract that implements some functions that can be bundled in a single call by EOAs to a single contract. They all inherit from [`BaseBundler`](./src/BaseBundler.sol) that enables bundling multiple function calls into a single `multicall(bytes[] calldata data)` call to the end bundler contract. Each chain-specific bundler is available under their chain-specific folder (e.g. [`ethereum`](./src/ethereum/)).

Some chain-specific domains are also scoped to the chain-specific folder, because they are not expected to be used on any other chain (e.g. DAI and its specific `permit` function is only available on Ethereum - see [`EthereumPermitBundler`](./src/ethereum/EthereumPermitBundler.sol)).

User-end bundlers are provided in each chain-specific folder, instanciating all the intermediary domain-specific bundlers and associated parameters (such as chain-specific protocol addresses, e.g. [`EthereumBundlerV2`](./src/ethereum/EthereumBundlerV2.sol)).

## Deployments

- [EthereumBundler](https://github.com/morpho-org/morpho-blue-bundlers/releases/tag/v1.0.0)
- [EthereumBundlerV2](https://github.com/morpho-org/morpho-blue-bundlers/releases/tag/v1.2.0)
- (TODO) AgnosticBundlerV2 on Base

## Getting Started

### Installation

```bash
npm install @morpho-org/morpho-blue-bundlers
```

```bash
yarn add @morpho-org/morpho-blue-bundlers
```

### Usage

```typescript
import { Signature } from "ethers";

import { BundlerAction } from "@morpho-org/morpho-blue-bundlers";

const permit2Address = "0x000000000022D473030F116dDEE9F6B43aC78BA3";

const permit2Config = {
  domain: {
    name: "Permit2",
    chainId: "0x1",
    verifyingContract: permit2Address,
  },
  types: {
    PermitSingle: [
      {
        name: "details",
        type: "PermitDetails",
      },
      {
        name: "spender",
        type: "address",
      },
      {
        name: "sigDeadline",
        type: "uint256",
      },
    ],
    PermitDetails: [
      {
        name: "token",
        type: "address",
      },
      {
        name: "amount",
        type: "uint160",
      },
      {
        name: "expiration",
        type: "uint48",
      },
      {
        name: "nonce",
        type: "uint48",
      },
    ],
  },
};

await bundler
  .connect(supplier)
  .multicall([
    BundlerAction.approve2(
      approve2,
      Signature.from(await supplier.signTypedData(permit2Config.domain, permit2Config.types, approve2)),
      false,
    ),
    BundlerAction.transferFrom2(collateralAddress, assets),
    BundlerAction.erc4626Deposit(erc4626Address, assets, 0, supplier.address),
  ]);
```

## Development

Install dependencies with `yarn`.

Run tests with `yarn test:forge --chain <chainid>` (chainid can be 1 or 8453).

Note that the `EthereumBundlerV2` has been deployed with 80 000 optimizer runs.
To compile contracts with the same configuration, run `FOUNDRY_PROFILE=ethereumBundlerV2 forge b`.

## Audits

All audits are stored in the [audits](./audits/)' folder.

## License

Bundlers are licensed under `GPL-2.0-or-later`, see [`LICENSE`](./LICENSE).
