pragma solidity ^0.5.16;

import "ds-test/test.sol";
import "../src/core/test/ERC20.sol";
import "../src/core/libraries/SafeMath.sol";

// Certain tests/checks not possible as solc version for UniswapV2 contracts is ^0.5.16
// but version required for forge-std test lib is >=0.6.2

contract UniswapV2ERC20Test is DSTest {
    using SafeMath for uint;
    ERC20 public uniswapV2ERC20;
    address public other;
    uint public TOTAL_SUPPLY;

    function setUp() public {
        // Setting total Supply to max uint256 value to cater to fuzz testing
        TOTAL_SUPPLY = uint256(-1);
        uniswapV2ERC20 = new ERC20(TOTAL_SUPPLY);
        other = 0x567dcbCC0Ded4Bd654485ba4675D5c27BfEB6F36;
    }

    function testInitial() public {
        assertEq(uniswapV2ERC20.name(), "Uniswap V2");
        assertEq(uniswapV2ERC20.symbol(), "UNI-V2");
        // Type of return value- uint8
        assertTrue(uniswapV2ERC20.decimals() == 18);
        assertEq(uniswapV2ERC20.totalSupply(), TOTAL_SUPPLY);
        assertEq(uniswapV2ERC20.balanceOf(address (this)), TOTAL_SUPPLY);
        bytes32 TEST_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes("Uniswap V2")),
                keccak256(bytes('1')),
                31337, // Chain ID for test env
                address(uniswapV2ERC20)
            )
        );
        assertEq(uniswapV2ERC20.DOMAIN_SEPARATOR(), TEST_DOMAIN_SEPARATOR);
        assertEq(uniswapV2ERC20.PERMIT_TYPEHASH(), 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9);
    }

    function testApproval(uint amount) public {
        bool approvalSuccess = uniswapV2ERC20.approve(other, amount);
        assertTrue(approvalSuccess);
        assertEq(uniswapV2ERC20.allowance(address(this), other), amount);
    }

    function testFuzzApproval(uint amount) public {
        bool approvalSuccess = uniswapV2ERC20.approve(other, amount);
        assertTrue(approvalSuccess);
        assertEq(uniswapV2ERC20.allowance(address(this), other), amount);
    }

    function testFuzzTransfer(uint amount) public {
        bool transferSuccess = uniswapV2ERC20.transfer(other, amount);
        assertTrue(transferSuccess);
        assertEq(uniswapV2ERC20.balanceOf(address (this)), TOTAL_SUPPLY.sub(amount));
        assertEq(uniswapV2ERC20.balanceOf(other), amount);
    }

    // Not possible to call vm.expectRevert()
    function testFailTransfer() public {
        bool transferFail = uniswapV2ERC20.transfer(other, TOTAL_SUPPLY + 1);
        assertTrue(!transferFail);
    }

    function testFailFuzzTransferOther(uint amount) public {
        // Transfer should fail as "other" address has no tokens
        bool transferFail = uniswapV2ERC20.transfer(other, amount);
        assertTrue(!transferFail);
    }

    function testFuzzTransferFrom(uint amount) public {
        bool approvalSuccess = uniswapV2ERC20.approve(address(this), amount);
        bool transferSuccess = uniswapV2ERC20.transferFrom(address(this), other, amount);
        assertTrue(approvalSuccess);
        assertTrue(transferSuccess);

        assertEq(uniswapV2ERC20.allowance(address(this), other), 0);
        assertEq(uniswapV2ERC20.balanceOf(address(this)), TOTAL_SUPPLY.sub(amount));
        assertEq(uniswapV2ERC20.balanceOf(other), amount);
    }

    function testPermit() public {
        uint nonce = uniswapV2ERC20.nonces(address(this));
        uint deadline = uint256(-1);
        uint TEST_AMOUNT = 10 * (10**18);
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01', 
                uniswapV2ERC20.DOMAIN_SEPARATOR(), 
                keccak256(
                    abi.encode(
                        uniswapV2ERC20.PERMIT_TYPEHASH(), 
                        address(this), 
                        other, 
                        TEST_AMOUNT, 
                        nonce, 
                        deadline
                    )
                )
            )
        );
        
    }



}