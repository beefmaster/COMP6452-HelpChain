pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";


contract FundsPool{
    address public admin;
    uint public funds;
    ReceiverFactory receiverFactory;
    event ValueReceived(address user, uint amount);

    constructor(){
        admin = msg.sender;
    }

    function distributeFunds(uint amount) public onlyOwner{
        require(amount <= address(this).balance, "not enough funds");
        uint numOfReceivers = receiverFactory.getNumOfReceivers();
        require(numOfReceivers > 0, "No receivers to receive funds");
        uint fundsToSend;
        fundsToSend = amount / numOfReceivers; 

        for (uint i = 1; i <= numOfReceivers; i++){
            sendFunds(fundsToSend, receiverFactory.getReceiver(i));
        }
        
    }

    function sendFunds(uint amount, address receiver) public payable onlyOwner{
        require(amount <= address(this).balance, "not enough funds");
        payable(receiver).transfer(amount); 
        funds -= amount;  
    }

    function updateReceiverFactory(ReceiverFactory rec) public onlyOwner{
        require(rec.owner() == admin, "Receiver Factory does not match Admin");
        receiverFactory = rec;  
    }

    receive() external payable{
        emit ValueReceived(msg.sender, msg.value);
        funds = address(this).balance;
    }


    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

}