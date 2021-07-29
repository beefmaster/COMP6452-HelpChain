// const ConvertLib = artifacts.require("ConvertLib");
// const MetaCoin = artifacts.require("MetaCoin");
const CorporateFactory = artifacts.require("CorporateFactory");
const SubsidiaryContract = artifacts.require("Subsidiary");
const ReceiverFactory = artifacts.require("ReceiverFactory");
const Receiver = artifacts.require("Receiver");
const Admin = artifacts.require("Admin");
const WhiteList = artifacts.require("WhiteList");
const FundsPool = artifacts.require("FundsPool");
const GiverFactory = artifacts.require("GiverFactory");
const Corporate = artifacts.require("Corporate");



let AdminD;
let FundsPoolDeployer;
let ReceiverFactoryDeployer;
let CorporateFactoryDeployer;
let GiverFactoryDeployer;
let CorporateDeployer;
let SubsidiaryDeployer;

module.exports = async function(deployer, accounts) {
  
  
  await deployer.deploy(Admin).then(async(AdminDeployer) => {
    AdminD = AdminDeployer;
    console.log("admin deployer: ");
    console.log(AdminDeployer.address)
    FundsPoolDeployer = await deployer.deploy(FundsPool);
    CorporateFactoryDeployer = await deployer.deploy(CorporateFactory, AdminD.address);
    ReceiverFactoryDeployer = await deployer.deploy(ReceiverFactory, AdminD.address);
    GiverFactoryDeployer = await deployer.deploy(GiverFactory, AdminD.address);
    WLDeployer = await deployer.deploy(WhiteList);
    

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


  }).then(async()=>{
      console.log(accounts[1])
      CorporateDeployer = await deployer.deploy(Corporate, "0xe7E89a3c7f931933bca106e308f29350c0daEB16", AdminD.address, "Woolies");
      console.log("Corporate Instance:");
      console.log(CorporateDeployer.address);
      Sub = await CorporateDeployer.createSub(1); 
  })


  
};
