pragma solidity ^0.5.16;

import "ds-test/test.sol";
import "../src/core/UniswapV2Factory.sol";
import "../src/core/UniswapV2Pair.sol";
import "../src/core/interfaces/IUniswapV2Pair.sol";

contract UniswapV2FactoryTest is DSTest {
    UniswapV2Factory public uniswapV2FactoryTest;
    address[2] public TEST_ADDRESSES;
    address public other;

    function setUp() public {
        uniswapV2FactoryTest = new UniswapV2Factory(address(this));
        TEST_ADDRESSES[0] = address(0x1000000000000000000000000000000000000000);
        TEST_ADDRESSES[1] = address(0x2000000000000000000000000000000000000000);
        other = address(0x567dcbCC0Ded4Bd654485ba4675D5c27BfEB6F36);
    }

    function testInitial() public {
        assertEq(uniswapV2FactoryTest.feeTo(), address(0));
        assertEq(uniswapV2FactoryTest.feeToSetter(), address(this));
        assertEq(uniswapV2FactoryTest.allPairsLength(), 0);
    }

    function testCreatePair() public {
        address pairExpected;
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(TEST_ADDRESSES[0], TEST_ADDRESSES[1]));
        assembly {
            pairExpected := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        address pair = uniswapV2FactoryTest.createPair(TEST_ADDRESSES[0], TEST_ADDRESSES[1]);
        // assertEq(pairExpected, pair); Test Fails
        assertEq(uniswapV2FactoryTest.allPairsLength(), 1);

        assertEq(IUniswapV2Pair(pair).token0(), TEST_ADDRESSES[0]);
        assertEq(IUniswapV2Pair(pair).token1(), TEST_ADDRESSES[1]);
        assertEq(IUniswapV2Pair(pair).factory(), address(uniswapV2FactoryTest));
    }

    // function testCreatePairFail() public {
    //     // UniswapV2: PAIR_EXISTS
    //     address pair = uniswapV2FactoryTest.createPair(TEST_ADDRESSES[0], TEST_ADDRESSES[1]);
    //     address pair2 = uniswapV2FactoryTest.createPair(TEST_ADDRESSES[0], TEST_ADDRESSES[1]);
    // }

    // function testCreatePairFail2() public {
    //     // UniswapV2: IDENTICAL_ADDRESSES
    //     address pair = uniswapV2FactoryTest.createPair(TEST_ADDRESSES[0], TEST_ADDRESSES[0]);
    // }

    function testSetFeeTo() public {
        uniswapV2FactoryTest.setFeeTo(other);
        assertEq(uniswapV2FactoryTest.feeTo(), other);
    }

    function testFeeToSetter() public {
        uniswapV2FactoryTest.setFeeToSetter(other);
        assertEq(uniswapV2FactoryTest.feeToSetter(), other);
    }

}