// const ConvertLib = artifacts.require("ConvertLib");
// const MetaCoin = artifacts.require("MetaCoin");
const CorporateFactory = artifacts.require("CorporateFactory");
const SubsidiaryContract = artifacts.require("Subsidiary");
const ReceiverFactory = artifacts.require("ReceiverFactory");
const Receiver = artifacts.require("Receiver");
const Admin = artifacts.require("Admin");
const WhiteList = artifacts.require("WhiteList");

module.exports = async function(deployer) {
  
  let AdminDeployer = await deployer.deploy(Admin);
  // let CorporateFactoryDeployer = await deployer.deploy(CorporateFactory, Admin.address);
  // let ReceiverFactoryDeployer = await deployer.deploy(ReceiverFactory, Admin.address);
  // let WhiteListDeployer = await deployer.deploy(WhiteList);
};
