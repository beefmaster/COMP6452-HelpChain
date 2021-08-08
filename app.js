const express = require('express');
const app = express()
const bodyParser = require('body-parser');
const fetch = require('fetch');
let Web3 = require('web3');
const testNetWS = "ws://127.0.0.1:7545"
const web3 = new Web3(new Web3.providers.WebsocketProvider(testNetWS))

const port = 5000

let fs = require('fs')
let request = require('request')

app.use(express.urlencoded({extended: true}));
app.use(express.json());

let subs = JSON.parse(fs.readFileSync('subAddresses.json'));

// Load in the Subsidiary contract ABI 
const abi = require('./build/contracts/Subsidiary.json');
const contract = new web3.eth.Contract(abi.abi, subs[0], {gas: '3000000'});


// Retrieve Admin Account Address
web3.eth.getAccounts((err, accounts) => {
    console.log(accounts[0]);
    const account = accounts[0];
    app.post('/write',  async (req, res) => {
        console.log("hit write url")
        // Receive query parameters
        var recAddr = req.query.recAddr;
        var txAmount = req.query.txAmount;
        var link = req.query.link;
        let txId = 1; 

        // Open JSON Database store
        let cur = fs.readFileSync('db_json.json');
        let curObj = JSON.parse(cur);
        console.log("DB is: " + curObj);
    
        // Write transaction information to JSON DB
        curObj.push({"id" : txId + 1, "receiverAddress" : recAddr, "txAmount" : txAmount});
        let txData = JSON.stringify(curObj);
        fs.writeFileSync('./db_json.json', txData, (err) => {
            if (err){
                console.error(err);
            }
        });

        // Write transaction information to Subsidiary contract
        contract.methods.insertTransaction(recAddr, txAmount, link).send({from: account});

        res.sendStatus(200);
    })
})
.catch((err) => {
    console.log(err);
})


module.exports = app;