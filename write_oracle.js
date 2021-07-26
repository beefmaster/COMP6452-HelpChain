const express = require('express');
const app = express()
const port = 5000

const fs = require('fs');
// json db
// const db_ob = require('./db_json.json');


app.get('/write:id', (req, res) => {
    var linkAddress = req.param('link');
    var id = req.params.id;
    write(id, linkAddress);
    res.send(200);
})


write = (id, linkAddress) => {
    let data = JSON.stringify({"id" : id, "link" : linkAddress});
    fs.writeFileSync('./db_json.json', data, (err) => {
        if (err){
            console.error(err)
        }
    });
}


app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})