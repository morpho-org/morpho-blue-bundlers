// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// import {SigUtils} from "@morpho-blue/../test/helpers/SigUtils.sol";

import "@morpho-blue/Blue.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {OracleMock} from "@morpho-blue/mocks/OracleMock.sol";
import {IrmMock} from "@morpho-blue/mocks/IrmMock.sol";

import "@forge-std/Test.sol";
import "@forge-std/console2.sol";

contract BaseBulkerTest is Test {
    using MarketLib for Market;
    using SharesMathLib for uint256;
    using stdStorage for StdStorage;
    using FixedPointMathLib for uint256;

    uint256 internal constant MIN_AMOUNT = 1000;
    uint256 internal constant MAX_AMOUNT = 2 ** 64;

    address internal constant USER = address(0x1234);
    address internal constant SUPPLIER = address(0x5678);
    uint256 internal constant LLTV = 0.8 ether;
    address internal constant OWNER = address(0xdead);

    Blue internal blue;
    ERC20Mock internal borrowableAsset;
    ERC20Mock internal collateralAsset;
    OracleMock internal oracle;
    IrmMock internal irm;
    Market internal market;
    Id internal id;

    function setUp() public virtual {
        // Create Blue.
        blue = new Blue(OWNER);

        // List a market.
        borrowableAsset = new ERC20Mock("borrowable", "B", 18);
        collateralAsset = new ERC20Mock("collateral", "C", 18);
        oracle = new OracleMock();

        irm = new IrmMock(blue);

        market = Market(address(borrowableAsset), address(collateralAsset), address(oracle), address(irm), LLTV);
        id = market.id();

        vm.startPrank(OWNER);
        blue.enableIrm(address(irm));
        blue.enableLltv(LLTV);
        blue.createMarket(market);
        vm.stopPrank();

        oracle.setPrice(WAD);

        borrowableAsset.approve(address(blue), type(uint256).max);
        collateralAsset.approve(address(blue), type(uint256).max);

        vm.prank(SUPPLIER);
        borrowableAsset.approve(address(blue), type(uint256).max);
    }
}