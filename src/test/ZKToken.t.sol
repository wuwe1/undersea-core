// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import {ZKToken} from "src/ZKToken.sol";
import {Proof} from "src/interfaces/IZKToken.sol";
import {Verifier} from "../../contracts/TransferVerifier.sol";
import {Constants} from "./utils/Constants.sol";

contract ZKTokenTest is Test, Constants {
    using stdStorage for StdStorage;
    ZKToken token;
    Verifier verifier;

    uint256 internal alicePk = 0xa11ce;
    uint256 internal bobPk = 0xb0b;
    address internal alice;
    address internal bob;

    function setUp() public {
        verifier = new Verifier();
        token = new ZKToken(
            "test",
            "TST",
            0,
            address(verifier),
            address(0),
            address(0)
        );
        alice = vm.addr(alicePk);
        bob = vm.addr(bobPk);
        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(address(token), "token");
    }

    function test_VerifierCanVerifyLegitProof() public {
        uint256[5] memory input;
        input[0] = hashValue;
        input[1] = hashSenderBalanceBefore;
        input[2] = hashSenderBalanceAfter;
        input[3] = hashReceiverBalanceBefore;
        input[4] = hashReceiverBalanceAfter;

        // assertTrue(
            verifier.verifyProof(
                TransferProof.a,
                TransferProof.b,
                TransferProof.c,
                input
            );
        // );
    }

    function test_Transfer() public {
        // keccak256(abi.encode(address(alice), uint(3)));
        uint256 aliceBalanceSlot = stdstore
            .target(address(token))
            .sig(token.balanceHashes.selector)
            .with_key(alice)
            .find();

        vm.store(
            address(token),
            bytes32(aliceBalanceSlot),
            bytes32(hashSenderBalanceBefore)
        );

        // keccak256(abi.encode(address(bob), uint(3)));
        uint256 bobBalanceSlot = stdstore
            .target(address(token))
            .sig(token.balanceHashes.selector)
            .with_key(bob)
            .find();

        vm.store(
            address(token),
            bytes32(bobBalanceSlot),
            bytes32(hashReceiverBalanceBefore)
        );

        vm.prank(alice);
        token.transfer(
            hashValue,
            hashSenderBalanceAfter,
            hashReceiverBalanceAfter,
            bob,
            TransferProof
        );
    }
}
