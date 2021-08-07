const express = require('express');
const app = express()
const bodyParser = require('body-parser');
const fetch = require('fetch');
let Web3 = require('web3');
const testNetWS = "ws://127.0.0.1:7545"
const web3 = new Web3(new Web3.providers.WebsocketProvider(testNetWS))

// var SubsidiaryContract = require('./build/contracts/Subsidiary.json');
// var contract = require('truffle-contract');
// var subsidiaryContract = contract(SubsidiaryContract);
// subsidiaryContract.setProvider(web3.currentProvider);

const port = 5000

let fs = require('fs')
let request = require('request')

app.use(express.urlencoded({extended: true}));
app.use(express.json());

// Admin account (taken from ganache - can remove hardcoding later)
const account = "0x174FB51467D9E6A37e4048841672173F399b6C05";
let address = ""


// const abi = require('./build/contracts/Subsidiary.json');
// const contract = new web3.eth.Contract(abi.abi, "0x58cbE4340B1A54b400F9E9505F052A3dFCEc28CF");
// var dummy =  contract.methods.setInsertTX(69);
// console.log(dummy);

const abi = require('./build/contracts/CorporateFactory.json');
const contract = new web3.eth.Contract(abi.abi, "0xf85FA8f98b38110b48816F698D2D7532A77334c2");
// console.log(contract.methods);
console.log(contract.methods.getCorporate(0));

contract.methods.getCorporate(0).call({from: account})
    .then ((result) => {
        console.log(result);
    });

// console.log(contract.methods);

// web3.eth.getAccounts((err, accounts) => {
//     subsidiaryContract.deployed()
//     .then((subsidiaryInstance) => {
//         // Watch event and respond to event with a callback function
//         subsidiaryInstance.CallbackInsertTX()
//         .watch((err, event) => {
//             //Fetch data and update it into the contract
//             console.log("INSERTING TX");
//             //JSON PARSING

//             //Send data back to contract on-chain
//             subsidiaryInstance.setInsertTX("hello");
//         })
//     })
// })
// .catch((err) => {
//     console.log(err);
// })





// app.get('/', (req, res) => { 
//     res.send('hello world hey')
// })

// app.post('/work', async (req, res) => {
//     console.log('Time to work');
//     console.log(req.body);
// })

// app.listen(7545, function(err){
//     if (err) console.log(err);
//     console.log("Server listening on PORT", 7545);
// });

// app.get('/insert', async (req, res) => {
//     console.log("inserting TX");
//     console.log("entered block chain insert contract")

//     const account = await web3.eth.getAccounts();
//     console.log("account is: " + account[0]);


//     // let data = JSON.stringify({"pid" : id, "link" : linkAddress});
//     // const account = await web3.eth.getAccounts()[0];
//     // const contractJSON = fs.readFileSync('./build/CorporateFactory.abi');
//     // const abiParse = JSON.parse(contractJSON);

//     // let CorporateFactoryContarct = new web3.eth.Contract(abiParse, "0x92cbdbc434c41AA2EdCeE12644A6c8f2f1029209");
//     // await CorporateFactoryContarct.methods.createCorp("hey").send({from: "0x0f5529d1372737DA7C28996Bba6C2AAbAf19847A"});

    
//     // console.log("successfully inserted transaction into contract");

// })
// let abi = null;

// startListener(address);
// function startListener(address){
//     console.log("Starting event monitoring on contract: " + address);
//     let myContract = new web3.eth.Contract(abi,address);
// }



module.exports = app;