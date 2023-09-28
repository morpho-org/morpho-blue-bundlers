// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IUniversalRewardsDistributor} from "@universal-rewards-distributor/interfaces/IUniversalRewardsDistributor.sol";

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";
import {ErrorsLib as UrdErrorsLib} from "@universal-rewards-distributor/libraries/ErrorsLib.sol";

import {Merkle} from "@murky/src/Merkle.sol";
import {UrdFactory} from "@universal-rewards-distributor/UrdFactory.sol";

import "src/mocks/bundlers/UrdBundlerMock.sol";

import "./helpers/LocalTest.sol";

contract UrdBundlerLocalTest is LocalTest {
    UrdBundlerMock internal bundler;

    UrdFactory internal urdFactory;
    Merkle internal merkle;

    address internal distributor;

    function setUp() public override {
        super.setUp();

        bundler = new UrdBundlerMock(address(morpho));

        urdFactory = new UrdFactory();
        merkle = new Merkle();

        distributor = address(urdFactory.createUrd(OWNER, 0, bytes32(0), hex"", hex""));
    }

    function testClaimRewardsZeroAddressDistributor(uint256 claimable, address account) public {
        vm.assume(account != address(0));
        claimable = bound(claimable, MIN_AMOUNT, MAX_AMOUNT);

        bytes32[] memory proof;

        bundle.push(
            abi.encodeCall(UrdBundler.urdClaim, (address(0), account, address(loanToken), claimable, proof, false))
        );

        vm.prank(USER);
        vm.expectRevert();
        bundler.multicall(block.timestamp, bundle);
    }

    function testClaimRewardsZeroAddressAccount(uint256 claimable) public {
        claimable = bound(claimable, MIN_AMOUNT, MAX_AMOUNT);

        bytes32[] memory proof;

        bundle.push(
            abi.encodeCall(UrdBundler.urdClaim, (distributor, address(0), address(loanToken), claimable, proof, false))
        );

        vm.prank(USER);
        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testClaimRewardsBundlerAddress(uint256 claimable) public {
        claimable = bound(claimable, MIN_AMOUNT, MAX_AMOUNT);

        bytes32[] memory proof;

        bundle.push(
            abi.encodeCall(
                UrdBundler.urdClaim, (distributor, address(bundler), address(loanToken), claimable, proof, false)
            )
        );

        vm.prank(USER);
        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testClaimRewards(uint256 claimable, uint256 size) public {
        claimable = bound(claimable, 1 ether, 1000 ether);
        size = bound(size, 2, 20);

        bytes32[] memory tree = _setupRewards(claimable, size);

        loanToken.setBalance(distributor, claimable);
        collateralToken.setBalance(distributor, claimable);

        bytes32[] memory loanTokenProof = merkle.getProof(tree, 0);
        bytes32[] memory collateralTokenProof = merkle.getProof(tree, 1);

        bundle.push(
            abi.encodeCall(
                UrdBundler.urdClaim, (distributor, USER, address(loanToken), claimable, loanTokenProof, false)
            )
        );
        bundle.push(
            abi.encodeCall(
                UrdBundler.urdClaim,
                (distributor, USER, address(collateralToken), claimable, collateralTokenProof, false)
            )
        );
        bundle.push(
            abi.encodeCall(
                UrdBundler.urdClaim, (distributor, USER, address(loanToken), claimable, collateralTokenProof, true)
            )
        );
        bundle.push(
            abi.encodeCall(
                UrdBundler.urdClaim, (distributor, USER, address(collateralToken), claimable, loanTokenProof, true)
            )
        );

        vm.prank(USER);
        bundler.multicall(block.timestamp, bundle);

        assertEq(loanToken.balanceOf(USER), claimable, "User's loan balance");
        assertEq(collateralToken.balanceOf(USER), claimable, "User's collateral balance");
    }

    function testClaimRewardsRevert(uint256 claimable, uint256 size) public {
        claimable = bound(claimable, 1 ether, 1000 ether);
        size = bound(size, 2, 20);

        bytes32[] memory tree = _setupRewards(claimable, size);

        loanToken.setBalance(distributor, claimable);
        collateralToken.setBalance(distributor, claimable);

        bytes32[] memory loanTokenProof = merkle.getProof(tree, 0);
        bytes32[] memory collateralTokenProof = merkle.getProof(tree, 1);

        bundle.push(
            abi.encodeCall(
                UrdBundler.urdClaim, (distributor, USER, address(loanToken), claimable, loanTokenProof, false)
            )
        );
        bundle.push(
            abi.encodeCall(
                UrdBundler.urdClaim,
                (distributor, USER, address(collateralToken), claimable, collateralTokenProof, false)
            )
        );
        bundle.push(
            abi.encodeCall(
                UrdBundler.urdClaim, (distributor, USER, address(loanToken), claimable, loanTokenProof, false)
            )
        );

        vm.prank(USER);
        vm.expectRevert(bytes(UrdErrorsLib.ALREADY_CLAIMED));
        bundler.multicall(block.timestamp, bundle);
    }

    function _setupRewards(uint256 claimable, uint256 size) internal returns (bytes32[] memory tree) {
        tree = new bytes32[](size);

        tree[0] = keccak256(bytes.concat(keccak256(abi.encode(USER, address(loanToken), claimable))));
        tree[1] = keccak256(bytes.concat(keccak256(abi.encode(USER, address(collateralToken), claimable))));

        for (uint256 i = 2; i < size - 1; i += 2) {
            uint256 rank = i + 1;

            tree[i] = keccak256(
                bytes.concat(keccak256(abi.encode(vm.addr(rank), address(loanToken), uint256(claimable / rank))))
            );
            tree[i + 1] = keccak256(
                bytes.concat(keccak256(abi.encode(vm.addr(rank), address(collateralToken), uint256(claimable / rank))))
            );
        }

        bytes32 root = merkle.getRoot(tree);

        vm.prank(OWNER);
        IUniversalRewardsDistributor(distributor).setRoot(root, bytes32(0));
    }
}
