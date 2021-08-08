let Web3 = require('web3');
const testNetWS = "ws://127.0.0.1:7545"
const web3 = new Web3(new Web3.providers.WebsocketProvider(testNetWS))

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
      console.log(await AdminD.fundsPool());
      console.log("Reciever Factory:");
      console.log(await AdminD.receiverFactory());
      console.log("corporate Factory:");
      console.log( await AdminD.corporateFactory());
  }).then(async()=>{
    // Load in the Subsidiary contract ABI 
  const abi = require('../build/contracts/CorporateFactory.json');
  const contract = new web3.eth.Contract(abi.abi, CorporateFactoryDeployer.address, {gas: '3000000'});
  await web3.eth.getAccounts((err, accounts) => {

    // let subAddr = contract.methods.createCorp("Nike", account_1).send({from: account});
    // console.log(subAddr);
    // console.log("helo");
  }).then(async(accounts)=>{
    const account = accounts[0];
    const account_1 = accounts[1];
    await contract.methods.createCorp("Nike", account_1).send({from: account});
    let subAddr = await contract.methods.getCorporate(0).call({from: account});
    let numCorps = await contract.methods.numCorps().call({from: account});
    console.log(subAddr);
    console.log(numCorps)
    console.log("helo");
  });


  })

  
};
