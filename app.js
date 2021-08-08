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

// Load in the Subsidiary contract ABI 
const abi = require('./build/contracts/Subsidiary.json');
const contract = new web3.eth.Contract(abi.abi, "0x68a808ABa2E82B4E65DAC5986A82156065616523", {gas: '3000000'});

// contract.methods.getCorporate(0).call({from: account})
//     .then ((result) => {
//         console.log(result);
// });

// Retrieve Admin Account Address
web3.eth.getAccounts((err, accounts) => {
    console.log(accounts[0]);
    const account = accounts[0];
    app.post('/write',  async (req, res) => {
        console.log("hit write url")
        // Receive query parameters
        var txId = req.query.txId;
        var recAddr = req.query.recAddr;
        var txAmount = req.query.txAmount;
        // var link = require('sample_reciept.png');
        
        // Open JSON Database store
        let cur = fs.readFileSync('db_json.json');
        let curObj = JSON.parse(cur);
        console.log("DB is: " + curObj);
    
        // Write transaction information to JSON DB
        curObj.push({"id" : txId, "receiverAddress" : recAddr, "txAmount" : txAmount});
        let txData = JSON.stringify(curObj);
        fs.writeFileSync('./db_json.json', txData, (err) => {
            if (err){
                console.error(err);
            }
        });
        // Write transaction information to Subsidiary contract
        contract.methods.insertTransaction(txId, recAddr, txAmount).send({from: account});
        // .then ((result) => {
        //     console.log(result);
        // });
    
        console.log("DB is: " + curObj);
        console.log("Information: " + txId + " " + recAddr + " " + txAmount);
    
        res.sendStatus(200);
    })
})
.catch((err) => {
    console.log(err);
})



// To DO:
// 1. Need to automate selection of susidiary contract address - avoid hardcoding
// 2. Need to manage conflicting transaction ids, currently user input/ maybe switch?
// 3. Send the transfer funds to the recipient contract
// 4. Handle errors
// 5. Add the restriction modifiers back into corporatefactory.sol for insertTX



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