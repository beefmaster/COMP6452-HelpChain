// const ConvertLib = artifacts.require("ConvertLib");
// const MetaCoin = artifacts.require("MetaCoin");
const CorporateFactory = artifacts.require("CorporateFactory");
const SubsidiaryContract = artifacts.require("Subsidiary");
const ReceiverFactory = artifacts.require("ReceiverFactory");
const Receiver = artifacts.require("Receiver");
const Admin = artifacts.require("Admin");
const WhiteList = artifacts.require("WhiteList");
const FundsPool = artifacts.require("FundsPool")

module.exports = async function(deployer) {
  
  
  await deployer.deploy(CorporateFactory).then(async(CorporateFactoryDeployer) => {
    let FundsPoolDeployer = await deployer.deploy(FundsPool);
    let ReceiverFactoryDeployer = await deployer.deploy(ReceiverFactory, FundsPoolDeployer.address);
    // let WhiteListDeployer = await deployer.deploy(WhiteList);
    console.log("funds deployer: ");
    console.log(FundsPoolDeployer.address)
    console.log("Reciever Factory");
    console.log(ReceiverFactoryDeployer.address);
    console.log("corporate Factory deployer:");
    console.log(CorporateFactoryDeployer.address);
    let AdminDeployer = await deployer.deploy(Admin, FundsPoolDeployer.address, ReceiverFactoryDeployer.address, CorporateFactoryDeployer.address);

  })
  
};
