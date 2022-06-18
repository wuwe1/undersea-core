pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/poseidon.circom";

template Main() {
  //public input
  signal input mintAmount;
  signal input hashMinterBalanceAfter;

  //private input
  signal input minterBalanceBefore;

  signal minterBalanceAfter;

  minterBalanceAfter <== minterBalanceBefore + mintAmount;

  component minterBalanceAfterHasher = Poseidon(1);
  minterBalanceAfterHasher.inputs[0] <== minterBalanceAfter;
  minterBalanceAfterHasher.out === hashMinterBalanceAfter;
}

component main {public [mintAmount, hashMinterBalanceAfter]} = Main();