pragma solidity ^0.5.16;

import "ds-test/test.sol";
import "../src/core/UniswapV2Pair.sol";
// Import Oppenzepplin ERC20

contract UniswapV2PairTest is DSTest {
    UniswapV2Pair public uniswapV2PairTest;
    ERC20 public testToken0;
    ERC20 public testToken1;
    address[2] public TEST_ADDRESSES;
    uint public TOTAL_SUPPLY;

    function setUp() public {
        // Setting total Supply to max uint256 value to cater to fuzz testing
        TOTAL_SUPPLY = uint256(-1);
        testToken0 = new ERC20(TOTAL_SUPPLY);
        testToken1 = new ERC20(TOTAL_SUPPLY);
        TEST_ADDRESSES = [address(testToken0), address(testToken1)];


        uniswapV2PairTest = new UniswapV2Pair();
        uniswapV2PairTest.initialize(TEST_ADDRESSES[0], TEST_ADDRESSES[1]);
    }

    function testInitial() public {
        assertEq(uniswapV2PairTest.factory(), address(this));
        assertEq(uniswapV2PairTest.token0(), TEST_ADDRESSES[0]);
        assertEq(uniswapV2PairTest.token1(), TEST_ADDRESSES[1]);
        assertEq(testToken0.name(), "TEST");
    }
     
}