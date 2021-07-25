pragma solidity >=0.7.0 <0.9.0;

// Contract that funds are received at
// needs to contain an idenitifier
contract Receiver {

    address public ownerReceiver;
    address public fundsPoolAddress;
    uint public funds;


    constructor(address ownerReceiver_, address fundsPoolAddress_) {
        ownerReceiver = ownerReceiver_;
        fundsPoolAddress = fundsPoolAddress_;
    }


    // Gives the receiver the funds
    function addFunds(uint amount) public payable onlyFundsPool {
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

contract ReceiverFactory {

    address public fundsPool;
    address public owner;

    constructor(address owner_, address fundsPool_) {
        fundsPool = fundsPool_;
        owner = owner_;
    }

    Receiver[] receivers;
    function createreceiver() public onlyOwner returns (address) {
        receiver child = new Receiver(address(this), address(fundsPool));
        receivers.push(child);
        return address(child);
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}


}