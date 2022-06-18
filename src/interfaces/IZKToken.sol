// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IZKToken {
    struct Proof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
    }

    event Deposit(address who, uint256 amount);
    event Withdraw(address who, uint256 amount);
    event Transfer(address from, address to, uint256 hashValue);

    error InvalidTransferProof();
    error InvalidMintProof();
    error InvalidBurnProof();

    function name() external returns (string memory);

    function symbol() external returns (string memory);
}