// const ConvertLib = artifacts.require("ConvertLib");
// const MetaCoin = artifacts.require("MetaCoin");
const CorporateFactory = artifacts.require("CorporateFactory");
const SubsidiaryContract = artifacts.require("Subsidiary");
const RecieverFactory = artifacts.require("RecieverFactory");
const Reciever = artifacts.require("Reciever");

module.exports = function(deployer) {
  

  deployer.deploy(CorporateFactory);
  // deployer.link(ConvertLib, MetaCoin);
  // deployer.deploy(MetaCoin);

};
