const { default: Web3 } = require('web3')

require('web3.js')

Web3.eth.getAccounts().then(e=>console.log(e));