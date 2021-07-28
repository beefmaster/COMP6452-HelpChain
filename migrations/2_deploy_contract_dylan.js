// const ConvertLib = artifacts.require("ConvertLib");
// const MetaCoin = artifacts.require("MetaCoin");
const CorporateFactory = artifacts.require("CorporateFactory");
const SubsidiaryContract = artifacts.require("Subsidiary");
const ReceiverFactory = artifacts.require("ReceiverFactory");
const Receiver = artifacts.require("Receiver");
const Admin = artifacts.require("Admin");
const WhiteList = artifacts.require("WhiteList");
const FundsPool = artifacts.require("FundsPool");

let AdminD;
let FundsPoolDeployer;
let ReceiverFactoryDeployer;
let CorporateFactoryDeployer;


module.exports = async function(deployer) {
  
  
  await deployer.deploy(Admin).then(async(AdminDeployer) => {
    AdminD = AdminDeployer;
    console.log("admin deployer: ");
    console.log(AdminDeployer.address)
    FundsPoolDeployer = await deployer.deploy(FundsPool);
    CorporateFactoryDeployer = await deployer.deploy(CorporateFactory);
    ReceiverFactoryDeployer = await deployer.deploy(ReceiverFactory, FundsPoolDeployer.address);
    // let WhiteListDeployer = await deployer.deploy(WhiteList);
    console.log("funds deployer: ");
    console.log(FundsPoolDeployer.address);
    console.log("Reciever Factory");
    console.log(ReceiverFactoryDeployer.address);
    console.log("corporate Factory deployer:");
    console.log(CorporateFactoryDeployer.address);
  }).then(async()=>{
    await AdminD.updateFundsPool(FundsPoolDeployer.address);
    await AdminD.updateCorporateFactory(CorporateFactoryDeployer.address);      
    await AdminD.updateReceiverFactory(ReceiverFactoryDeployer.address);

      console.log("funds deployer: ");
      console.log(AdminD.fundsPool());
      console.log("Reciever Factory:");
      console.log(AdminD.receiverFactory());
      console.log("corporate Factory:");
      console.log(AdminD.corporateFactory());


  })


  
};
