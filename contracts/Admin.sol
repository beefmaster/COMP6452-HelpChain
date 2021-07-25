pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";


// Contract that funds are received at
// needs to contain an idenitifier
contract Admin {

    address public receiverFactory;
    address public corporateFactory;
    address public fundsPool; 


    constructor(address ownerReceiver_, address fundsPoolAddress_) {
        ownerReceiver = ownerReceiver_;
    }


    // Gives the receiver the funds
    function createRece(uint amount) public payable onlyFundsPool {
        require(msg.value == amount);
        funds += amount;
    }

    function spendFunds(uint cost, address to_) public onlyOwner {
        funds -= cost;
        payable(to_).transfer(cost);
    }

    modifier onlyFundsPool() {
        require(msg.sender == fundsPoolAddress);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerReceiver);
        _;
    }

}