pragma solidity ^0.5.16;

import "ds-test/test.sol";
import "../src/core/UniswapV2Pair.sol";
import "../src/core/test/MockERC20.sol";
import "../src/core/UniswapV2Factory.sol";
import "../src/core/libraries/SafeMath.sol";
import "../src/core/libraries/Math.sol";

contract UniswapV2PairTest is DSTest {

    using SafeMath for uint;
    uint public constant MINIMUM_LIQUIDITY = 10**3;

    UniswapV2Pair public uniswapV2PairTest;
    MockERC20 public testToken0;
    MockERC20 public testToken1;
    address[2] public TEST_ADDRESSES;
    uint public TOTAL_SUPPLY;

    function setUp() public {
        // Setting total Supply to max uint256 value to cater to fuzz testing
        TOTAL_SUPPLY = uint256(-1);
        testToken0 = new MockERC20("TEST_TOKEN1", "TEST1", uint(-1));
        testToken1 = new MockERC20("TEST_TOKEN2", "TEST2", uint(-1));
        TEST_ADDRESSES = [address(testToken0), address(testToken1)];

        uniswapV2PairTest = new UniswapV2Pair();
        uniswapV2PairTest.initialize(TEST_ADDRESSES[0], TEST_ADDRESSES[1]);
    }

    function feeTo() external pure returns (address feeTo) {
        return address(0);
    }

    function testInitial() public {
        assertEq(uniswapV2PairTest.factory(), address(this));
        assertEq(uniswapV2PairTest.token0(), TEST_ADDRESSES[0]);
        assertEq(uniswapV2PairTest.token1(), TEST_ADDRESSES[1]);
        assertEq(uniswapV2PairTest.totalSupply(), 0);
    }

    // Unable to implement fuzzing as not possible to exclude 0 as arg
    function testMint() public {
        uint token0Amount = 1 * (10**3);
        uint token1Amount = 4 * (10**3);
        testToken0.transfer(address(uniswapV2PairTest), token0Amount);
        testToken1.transfer(address(uniswapV2PairTest), token1Amount);
        uint receivedLiquidity = uniswapV2PairTest.mint(address(this));
        uint expectedLiquidity = Math.sqrt(token0Amount.mul(token1Amount)).sub(MINIMUM_LIQUIDITY);
        
        assertEq(receivedLiquidity, expectedLiquidity);
        assertEq(uniswapV2PairTest.totalSupply(), receivedLiquidity.add(MINIMUM_LIQUIDITY));
        assertEq(uniswapV2PairTest.balanceOf(address(this)), receivedLiquidity);
        assertEq(testToken0.balanceOf(address(uniswapV2PairTest)), token0Amount);
        assertEq(testToken1.balanceOf(address(uniswapV2PairTest)), token1Amount);

        (uint112 _reserve0, uint112 _reserve1, ) = uniswapV2PairTest.getReserves();
        assertEq(_reserve0, token0Amount);
        assertEq(_reserve1, token1Amount);
    }

    function addLiquidity(uint token0Amount, uint token1Amount) public returns (uint) {
        testToken0.transfer(address(uniswapV2PairTest), token0Amount);
        testToken1.transfer(address(uniswapV2PairTest), token1Amount);
        return uniswapV2PairTest.mint(address(this));
    }

    function testBurn() public {
        uint amountToAdd = 4000;
        addLiquidity(amountToAdd, amountToAdd);
        uint expectedLiquidity = 4000;

        uniswapV2PairTest.transfer(address(uniswapV2PairTest), expectedLiquidity.sub(MINIMUM_LIQUIDITY));
        uniswapV2PairTest.burn(address(this));
        assertEq(uniswapV2PairTest.balanceOf(address(this)), 0);
        assertEq(uniswapV2PairTest.totalSupply(), MINIMUM_LIQUIDITY);
        assertEq(testToken0.balanceOf(address(uniswapV2PairTest)), 1000);
        assertEq(testToken1.balanceOf(address(uniswapV2PairTest)), 1000);
    }

    function testSwap() public {
        uint amountToAdd = 4000;
        addLiquidity(amountToAdd, amountToAdd);
    }
}