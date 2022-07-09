// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Proof} from "src/interfaces/IZKToken.sol";

contract Constants {
    Proof internal TransferProof;
    uint256 internal hashValue =                 0x2778f900758cc46e051040641348de3dacc6d2a31e2963f22cbbfb8f65464241;
    uint256 internal hashSenderBalanceBefore =   0x21f6c93b8b701f3c96744fcc5e4d99d95fdbaffe3068c0f1dbfdf753df34a56c;
    uint256 internal hashSenderBalanceAfter =    0x22d0ae462961c4cc15b7a368970afc115a29563a262963d28bf52035f73f2f7f;
    uint256 internal hashReceiverBalanceBefore = 0x22d0ae462961c4cc15b7a368970afc115a29563a262963d28bf52035f73f2f7f;
    uint256 internal hashReceiverBalanceAfter =  0x21f6c93b8b701f3c96744fcc5e4d99d95fdbaffe3068c0f1dbfdf753df34a56c;

    constructor () {
        TransferProof.a[0] =    0x2c3274858296c9cdf9900044be4b967ca741ba0b7a24792a028db32c27594a29;
        TransferProof.a[1] =    0x10c9a52927a1c91b1faa3b1df9041a9a9c5ce15b4c683331fc10f921047f3270;
        TransferProof.b[0][0] = 0x214705eef96dc0bb8c5ba4de5e64e5f0de8b8cfc14597c9cea1a668bfa864e51;
        TransferProof.b[0][1] = 0x1f1a69e50a0741c1f006bd4f492f95e48b94eed361515467665c714e9d6fab30;
        TransferProof.b[1][0] = 0x2d4a0179fb7b3711ad8bf932cb7b582b8dac0c88fce0ed6862678b0cd1f9f005;
        TransferProof.b[1][1] = 0x2d00984a464b94b95cb7eb63faf30f0f3c9619bdc0a60506eb5788295ecba535;
        TransferProof.c[0] =    0x2d4940ce2bf6d11f758fa12660098ba4cf6a6164139e0f6cf75ba526e5557359;
        TransferProof.c[1] =    0x56aeb4e64f8b7234827260cee1affed5ac3dc136dd43951556951c1078e0f2e;
    }
}
