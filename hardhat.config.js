require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.2",
  networks: {
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/qQMpJDUuCgUTc_zs6FpyW3XK6YhJ49aV",
      accounts: ["f4cc5a6f8d91f876379a40efcd83ee778aa8be7e80dadcb2fa9b87c156fabc84"]
    },
  },
};