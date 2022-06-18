#!/usr/bin/env bash

CIRCUITS_SRC_DIR=../circuits
CIRCUITS_OUT_DIR=../client/public
PHASE1=$CIRCUITS_SRC_DIR/phase1_final.ptau

if [ -f "$PHASE1" ]; then
    echo "Phase 1 file exists, no action"
else
    echo "Phase 1 file does not exist, downloading ..."
    curl -o $PHASE1 https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_14.ptau
fi


for path in "$CIRCUITS_SRC_DIR"/*.circom; do
    base="${path%.*}"
    name="${base##.*/}"
    echo "$name processing..."
    if [ -f "$CIRCUITS_OUT_DIR"/"$name".r1cs ]; then
        # calculate witness
        npx snarkjs wtns calculate \
         "$CIRCUITS_OUT_DIR"/"$name".wasm \
         "$CIRCUITS_SRC_DIR"/"$name".json \
         "$CIRCUITS_OUT_DIR"/"$name".wtns
        # generate proof
        npx snarkjs groth16 prove \
        "$CIRCUITS_OUT_DIR"/"$name".zkey \
        "$CIRCUITS_OUT_DIR"/"$name".wtns \
        "$CIRCUITS_OUT_DIR"/"$name"_proof.json \
        "$CIRCUITS_OUT_DIR"/"$name"_public.json
        # verify proof
        npx snarkjs groth16 verify \
        "$CIRCUITS_OUT_DIR"/"$name".vkey.json \
        "$CIRCUITS_OUT_DIR"/"$name"_public.json \
        "$CIRCUITS_OUT_DIR"/"$name"_proof.json
    else
        echo "$CIRCUITS_OUT_DIR/$name.r1cs is not exist"
        echo "compile $CIRCUITS_SRC_DIR/$name.circom"
        echo "by adding $name to hardhat.config.js and run 'yarn circom:dev'"
    fi
done