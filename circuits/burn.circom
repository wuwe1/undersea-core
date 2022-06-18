pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/poseidon.circom";

template Main() {
  //public input
  signal input burnAmount;
  signal input hashBurnerBalanceAfter;

  //private input
  signal input burnerBalanceBefore;

  signal burnerBalanceAfter;

  burnerBalanceAfter <== burnerBalanceBefore - burnAmount;

  component burnerBalanceAfterHasher = Poseidon(1);
  burnerBalanceAfterHasher.inputs[0] <== burnerBalanceAfter;
  burnerBalanceAfterHasher.out === hashBurnerBalanceAfter;
}

component main {public [burnAmount, hashBurnerBalanceAfter]} = Main();