const express = require('express');
const app = express()
const bodyParser = require('body-parser');

// routes

const port = 5000
let Web3 = require('web3')
const testNetWS = "ws://127.0.0.1:7545"
const web3 = new Web3(new Web3.providers.WebsocketProvider(testNetWS))
let fs = require('fs')
let request = require('request')

app.use(express.urlencoded({extended: true}));
app.use(express.json());

// Need these ?
const account = ""
let address = ""


app.get('/', (req, res) => { 
    res.send('hello world hey')
})

app.get('/insertTX', async (req, res) => {
    console.log("inserting TX");
    console.log("entered block chain insert contract")
    // let data = JSON.stringify({"pid" : id, "link" : linkAddress});
    const account = await web3.eth.getAccounts()[0];
    const contractJSON = fs.readFileSync('./build/CorporateFactory.abi');
    const abiParse = JSON.parse(contractJSON);

    let CorporateFactoryContarct = new web3.eth.Contract(abiParse, "0x92cbdbc434c41AA2EdCeE12644A6c8f2f1029209");
    await CorporateFactoryContarct.methods.createCorp("hey").send({from: "0x0f5529d1372737DA7C28996Bba6C2AAbAf19847A"});

    
    console.log("successfully inserted transaction into contract");

})

function startListener(address){
    console.log("Starting event monitoring on contract: " + address);
    

}



module.exports = app;