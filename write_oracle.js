const express = require('express');
const app = express()
var bodyParser = require('body-parser');
const port = 5000
let Web3 = require('web3')
const testNetWS = "ws://127.0.0.1:7545"
const web3 = new Web3(new Web3.providers.WebsocketProvider(testNetWS))

const fs = require('fs');
// create application/json parser
var jsonParser = bodyParser.json()

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// json db
// const db_ob = require('./db_json.json');

// request must contain link and subaddress in the request. 
app.post('/write', async (req, res) => {
    console.log("hit write url");

    var linkAddress = req.body.link;
    var personId = req.query.id;
    var subId = req.body.subId;
    getTransId().then(async (txId) => {
        console.log("Entered next sequential task");
        write(personId, linkAddress, txId);
    
        console.log("did this run properly??");
        await contractTransactionInsert(personId, linkAddress, txId).then((r) => {
            console.log("apparently insert ran");
            console.log(r);
            res.send(200);
        });
        
    });
    
})

getTransId = async () => {
    console.log("about to read file");
    var contents = fs.readFileSync('./db_json.json');
    console.log("contents: ");
    console.log(contents);
    return contents.length;
}

write = (id, linkAddress, transactionId) => {
    let cur = fs.readFileSync('db_json.json');
    let curObj = JSON.parse(cur);
    console.log(curObj);
    curObj.push({"id" : id, "link" : linkAddress, "transId" : transactionId});
    
    let writeData = JSON.stringify(curObj);
    fs.writeFileSync('./db_json.json', writeData, (err) => {
        if (err){
            console.error(err)
        }
    });
}

// Inserts into appropriate subsidiary contract.
// This is not being called correctly and is not running
// need to get this oracle going. Before tommorrow.
contractTransactionInsert = async (id, subAddress, transactionId) => {
    console.log("entered block chain insert contract")
    // let data = JSON.stringify({"pid" : id, "link" : linkAddress});
    const account = await web3.eth.getAccounts()[0];
    const contractJSON = fs.readFileSync('./bin/contracts/CorporateFactory.abi');
    const abiParse = JSON.parse(contractJSON);

    let CorporateFactoryContarct = new web3.eth.Contract(abiParse, "0x92cbdbc434c41AA2EdCeE12644A6c8f2f1029209");
    await CorporateFactoryContarct.methods.createCorp("hey").send({from: "0x0f5529d1372737DA7C28996Bba6C2AAbAf19847A"});

    
    console.log("successfully inserted transaction into contract");
}

app.listen(port, () => {
  console.log(`app listening at http://localhost:${port}`)
})