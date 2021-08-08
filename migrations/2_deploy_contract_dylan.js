let Web3 = require('web3');
const testNetWS = "ws://127.0.0.1:7545";
const web3 = new Web3(new Web3.providers.WebsocketProvider(testNetWS));
const fs = require('fs');

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
    GiverFactoryDeployer = await deployer.deploy(GiverFactory, AdminD.address, FundsPoolDeployer.address);
    

    // let WhiteListDeployer = await deployer.deploy(WhiteList);
    console.log("Core Contracts Created:")
    console.log("Funds Pool: " + FundsPoolDeployer.address);
    console.log("Reciever Factory: " + ReceiverFactoryDeployer.address);
    console.log("Corporate Factory:" + CorporateFactoryDeployer.address);
    console.log("Giver Factory: " + GiverFactoryDeployer.address);
    console.log("\n");
  }).then(async()=>{
    await AdminD.updateFundsPool(FundsPoolDeployer.address);
    await AdminD.updateCorporateFactory(CorporateFactoryDeployer.address);      
    await AdminD.updateReceiverFactory(ReceiverFactoryDeployer.address);
    await AdminD.updateGiverFactory(GiverFactoryDeployer.address);

    console.log("Successfully integrated with Admin Contract...\n")
    
  }).then(async()=>{
    // Load in the Corporate Factory contract ABI 
  const abi = require('../build/contracts/CorporateFactory.json');
  const contract = new web3.eth.Contract(abi.abi, CorporateFactoryDeployer.address, {gas: '3000000'});
  await web3.eth.getAccounts((err, accounts) => {

  }).then(async(accounts)=>{

    const account = accounts[0]; // admin account owner
    const account_1 = accounts[1]; // corp contract owner
    
    await contract.methods.createCorp("Woolies", account_1).send({from: account}); // Create new Corporate Contract
    let corpAddr = await contract.methods.getCorporate(0).call({from: account}); // get the address of the new corporate
    console.log("New Corporate Created at: " + corpAddr);

    //load in newly created Corporate contract
    const abi = require('../build/contracts/Corporate.json');
    const corporate = new web3.eth.Contract(abi.abi, corpAddr, {gas: '3000000'});
    let sub1 = await corporate.methods.createSub().call({from: account}); // Create new Subsidiary
    await corporate.methods.createSub().send({from: account}); 
    let sub2 = await corporate.methods.createSub().call({from: account}); // Create new Subsidiary
    await corporate.methods.createSub().send({from: account});
    let sub3 = await corporate.methods.createSub().call({from: account}); // Create new Subsidiary
    await corporate.methods.createSub().send({from: account});

    console.log("New Subsidiaries Created:")
    console.log("Sub 1 Address: " + sub1);
    console.log("Sub 2 Address: " + sub2);
    console.log("Sub 3 Address: " + sub3);
    console.log("\n")

    // create dic of subs
    subs = {
      0 : sub1,
      1 : sub2, 
      2 : sub3
    };

    let path = "./subAddresses.json";
    //save it to file 
   fs.writeFileSync(path, JSON.stringify(subs));
   console.log("Saved Subsidiary Addresses to " + path);

   //create Receiver Factory
    const rec_abi = require('../build/contracts/ReceiverFactory.json');
    const rec_contract = new web3.eth.Contract(rec_abi.abi,ReceiverFactoryDeployer.address, {gas: '3000000'});
    
    let recAddress = await rec_contract.methods.createreceiver().call({from: account});
    await rec_contract.methods.createreceiver().send({from: account}); // Create new Corporate Contract
    console.log("\nNew Receiver: " + recAddress);
    
  });


  })

  
};
