// SETUP //
let Web3 = require('web3')
let fs = require('fs')
let request = require('request')

// using Websockets URL.  Ganache works w/ Web3 1.0 and Websockets
const testNetWS = "ws://127.0.0.1:7545"

// create a WebsocketProvider
const web3 = new Web3(new Web3.providers.WebsocketProvider(testNetWS))