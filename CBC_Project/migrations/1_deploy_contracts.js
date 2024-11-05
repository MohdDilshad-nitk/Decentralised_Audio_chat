const CallFactory = artifacts.require("CallFactory");

module.exports = function (deployer) {
  deployer.deploy(CallFactory);
};