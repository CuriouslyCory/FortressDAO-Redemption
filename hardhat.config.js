require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.7" },
      { version: "0.8.2" },
      { version: "0.7.5" },
      { version: "0.4.15" },
    ]
  }
};
