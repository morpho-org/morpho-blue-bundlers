// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../lib/morpho-blue/src/interfaces/IMorpho.sol";
import "../../lib/universal-rewards-distributor/src/interfaces/IUniversalRewardsDistributor.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC4626.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

// The bundler can do call to arbitrary contracts, we make sure no selectors clash by inheriting all the interfaces in
// one single contract.
abstract contract SelectorClashTest is IMorpho, IUniversalRewardsDistributor, IERC4626, IERC20Permit, ERC20Wrapper {
    // Overriedes of functions that are present in multiple interfaces contract ("acknoledged clashes").
    function setOwner(address) public override(IMorphoBase, IUniversalRewardsDistributorBase) {}
    function owner() public view override(IMorphoBase, IUniversalRewardsDistributorBase) returns (address) {}
    function DOMAIN_SEPARATOR() public view override(IMorphoBase, IERC20Permit) returns (bytes32) {}
}

// An example to be convinced that it is actually checking that there is no clash (to uncomment and try to compile).
// interface IA { function transferFrom(address, address, uint256) external; }
// interface IB { function gasprice_bit_ether(int128) external; }
// abstract contract C is IA, IB {}
