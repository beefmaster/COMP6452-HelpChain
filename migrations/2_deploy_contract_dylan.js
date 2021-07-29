// const ConvertLib = artifacts.require("ConvertLib");
// const MetaCoin = artifacts.require("MetaCoin");
const CorporateFactory = artifacts.require("CorporateFactory");
const SubsidiaryContract = artifacts.require("Subsidiary");
const ReceiverFactory = artifacts.require("ReceiverFactory");
const Receiver = artifacts.require("Receiver");
const Admin = artifacts.require("Admin");
const WhiteList = artifacts.require("WhiteList");
const FundsPool = artifacts.require("FundsPool");
const GiverFactory = artifacts.require("FundsPool");

let AdminD;
let FundsPoolDeployer;
let ReceiverFactoryDeployer;
let CorporateFactoryDeployer;
let GiverFactoryDeployer;

module.exports = async function(deployer) {
  
  
  await deployer.deploy(Admin).then(async(AdminDeployer) => {
    AdminD = AdminDeployer;
    console.log("admin deployer: ");
    console.log(AdminDeployer.address)
    FundsPoolDeployer = await deployer.deploy(FundsPool);
    CorporateFactoryDeployer = await deployer.deploy(CorporateFactory, AdminD.address);
    ReceiverFactoryDeployer = await deployer.deploy(ReceiverFactory, AdminD.address, FundsPoolDeployer.address);
    GiverFactoryDeployer = await deployer.deploy(GiverFactory, AdminD.address);

    // let WhiteListDeployer = await deployer.deploy(WhiteList);
    console.log("Funds Pool:");
    console.log(FundsPoolDeployer.address);
    console.log("Reciever Factory:");
    console.log(ReceiverFactoryDeployer.address);
    console.log("corporate Factory:");
    console.log(CorporateFactoryDeployer.address);
    console.log("Giver Factory:");
    console.log(GiverFactoryDeployer.address);
  }).then(async()=>{
    await AdminD.updateFundsPool(FundsPoolDeployer.address);
    await AdminD.updateCorporateFactory(CorporateFactoryDeployer.address);      
    await AdminD.updateReceiverFactory(ReceiverFactoryDeployer.address);
    await AdminD.updateGiverFactory(GiverFactoryDeployer.address);

      console.log("funds deployer: ");
      console.log(AdminD.fundsPool());
      console.log("Reciever Factory:");
      console.log(AdminD.receiverFactory());
      console.log("corporate Factory:");
      console.log(AdminD.corporateFactory());


  })


  
};
