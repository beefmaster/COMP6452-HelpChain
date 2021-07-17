const Migrations = artifacts.require("CorporateFactory");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
