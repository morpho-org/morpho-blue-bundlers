# Morpho Blue Bundlers

[Morpho Blue](https://github.com/morpho-labs/morpho-blue) is a new lending primitive that offers better rates, high capital efficiency and extended flexibility to lenders & borrowers. `morpho-blue-bundlers` hosts the logic that builds alongisde the core protocol like MetaMorpho and bundlers. The contracts in this repository are still in development and further periphery contracts have not yet been built.

Each Bundler is a domain-specific abstract layer of contract that implements some functions that can be bundled in a single call by EOAs to a single contract. They all inherit from [`BaseBundler`](./src/BaseBundler.sol) that enables bundling multiple function calls into a single `multicall(bytes[] calldata data)` call to the end bundler contract. Each chain-specific bundler is available under their chain-specific folder (e.g. [`ethereum-mainnet`](./src/ethereum-mainnet/)).

Some chain-specific domains are also scoped to the chain-specific folder (e.g. wstETH is only available on Ethereum Mainnet), because they are not expected to be used on any other chain.

User-end bundlers are provided in each chain-specific folder, instanciating all the intermediary domain-specific bundlers and associated parameters (such as chain-specific protocol addresses).
