require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "scratch",
  networks: {
    scratch: {
      url: "http://localhost:8545",
      chainId: 10153857,
      accounts: [
        "f6b167c410e16b4cc146c415693df4cfc06c9764d58ad65f195c759638f4f0d1",
      ],
    },
  },
};
