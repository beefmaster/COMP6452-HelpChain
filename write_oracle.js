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
web3.eth.defaultAccount = '0x68D4Ab4AB14765532c68612941F8Bb86e46300E5';
// request must contain link and subaddress in the request. 
app.post('/write', async (req, res) => {
    console.log("hit write url");

    var linkAddress = req.body.link;
    var personId = req.query.id;
    var subId = req.body.subId;
    getTransId().then(async (txId) => {
        console.log("Entered next sequential task");
        write(personId, linkAddress, txId);
        try {
            await contractTransactionInsert(personId, linkAddress, txId).then(() => {
                res.send(200);
            });
        } catch (e) {
            res.send(e);
            return;
        }
        
        
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
contractTransactionInsert = async (id, subAddress, transactionId) => {
    let data = JSON.stringify({"id" : int(id), "link" : string(linkAddress)});
    let subContract = new web3.eth.Contract(jsonInterface, subAddress);
    await subContract.methods.insertTransaction(id, transactionId).send({from: web3.eth.defaultAccount});
    console.log("successfully inserted transaction into contract");
    return true;
}

app.listen(port, () => {
  console.log(`app listening at http://localhost:${port}`)
})