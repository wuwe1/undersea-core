// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {ITransferVerifier, IMintVerifier, IBurnVerifier} from "./interfaces/Verifier.sol";
import {IZKToken} from "./interfaces/IZKToken.sol";

contract ZKToken is IZKToken {
    string public name;
    string public symbol;
    mapping(address => uint256) public balanceHashes;

    ITransferVerifier transferVerifier;
    IMintVerifier mintVerifier;
    IBurnVerifier burnVerifier;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupplyHash,
        address _transferVerifier,
        address _mintVerifier,
        address _burnVerifier
    ) {
        name = _name;
        symbol = _symbol;
        balanceHashes[msg.sender] = initialSupplyHash;
        transferVerifier = ITransferVerifier(_transferVerifier);
        mintVerifier = IMintVerifier(_mintVerifier);
        burnVerifier = IBurnVerifier(_burnVerifier);
    }

    /**
     * @notice Move secret amount of token from the caller's account to `to`
     *
     * @param hashValue               Poseidon hash of transfer amount
     * @param hashSenderBalanceAfter  Poseidon hash of sender balance after
     *                                transaction
     * @param hashSenderBalanceAfter  Poseidon hash of receiver balance after
     *                                transaction
     * @param to                      Address of receiver
     */
    function transfer(
        uint256 hashValue,
        uint256 hashSenderBalanceAfter,
        uint256 hashReceiverBalanceAfter,
        address to,
        Proof calldata proof
    ) external override {
        _transfer(
            hashValue,
            hashSenderBalanceAfter,
            hashReceiverBalanceAfter,
            msg.sender,
            to,
            proof
        );
    }

    /**
     * @notice Move secret amount of token from `from` to `to`
     *
     * @param hashValue               Poseidon hash of transfer amount
     * @param hashSenderBalanceAfter  Poseidon hash of sender balance after
     *                                transaction
     * @param hashSenderBalanceAfter  Poseidon hash of receiver balance after
     *                                transaction
     * @param from                    Address of sender
     * @param to                      Address of receiver
     */
    function transferFrom(
        uint256 hashValue,
        uint256 hashSenderBalanceAfter,
        uint256 hashReceiverBalanceAfter,
        address from,
        address to,
        Proof calldata proof
    ) external override {
        _transfer(
            hashValue,
            hashSenderBalanceAfter,
            hashReceiverBalanceAfter,
            from,
            to,
            proof
        );
    }

    function _transfer(
        uint256 hashValue,
        uint256 hashSenderBalanceAfter,
        uint256 hashReceiverBalanceAfter,
        address from,
        address to,
        Proof calldata proof
    ) internal {
        if (to == address(0) || from == address(0)) {
            revert ZeroAddress();
        }
        uint256[5] memory input;
        input[0] = hashValue;
        input[1] = balanceHashes[from];
        input[2] = hashSenderBalanceAfter;
        input[3] = balanceHashes[to];
        input[4] = hashReceiverBalanceAfter;

        if (!transferVerifier.verifyProof(proof.a, proof.b, proof.c, input)) {
            revert InvalidTransferProof();
        }

        balanceHashes[from] = hashSenderBalanceAfter;
        balanceHashes[to] = hashReceiverBalanceAfter;
        emit Transfer(from, to, hashValue);
    }

    /**
     * @notice Deposit ETH to get ZKToken
     *
     * @param hashBalanceAfter  Poseidon hash of caller's balance after
     *                          transaction
     * @param proof             SNARK proof
     */
    function deposit(uint256 hashBalanceAfter, Proof calldata proof)
        external
        payable
        override
    {
        uint256[2] memory input;
        input[0] = msg.value;
        input[1] = hashBalanceAfter;

        if (!mintVerifier.verifyProof(proof.a, proof.b, proof.c, input)) {
            revert InvalidMintProof();
        }
        balanceHashes[msg.sender] = hashBalanceAfter;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw ETH by burning ZKToken
     *
     * @param amount            Amount of ETH to be withdrawn
     *
     * @param hashBalanceAfter  Poseidon hash of caller's balance after
     *                          transaction
     * @param proof             SNARK proof
     */
    function withdraw(
        uint256 amount,
        uint256 hashBalanceAfter,
        Proof calldata proof
    ) external override {
        uint256[2] memory input;
        input[0] = amount;
        input[1] = hashBalanceAfter;

        if (!burnVerifier.verifyProof(proof.a, proof.b, proof.c, input)) {
            revert InvalidBurnProof();
        }
        balanceHashes[msg.sender] = hashBalanceAfter;

        require(address(this).balance >= amount);
        emit Withdraw(msg.sender, amount);
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
    }
}
