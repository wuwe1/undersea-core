require('hardhat-circom');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    circom: {
        inputBasePath: "./circuits",
        outputBasePath: "./client/public",
        ptau: "phase1_final.ptau",
        circuits: [
            {
                name: "transfer",
            },
            {
                name: "mint",
            },
            {
                name: "burn",
            }
        ]
    },
};
