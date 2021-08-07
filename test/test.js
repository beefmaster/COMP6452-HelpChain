require("web3")
async () => {
    const accounts = await web3.eth.getAccounts(); 
    console.log(accounts[0]);
}
