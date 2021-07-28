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
        uint fundsToSend;
        fundsToSend = amount / receivers.length; 

        for (uint i = 1; i <= receivers.length; i++){
            sendFunds(fundsToSend, receivers[i]);
        }
        
    }

    function sendFunds(uint amount, address receiver) public payable onlyOwner{
        require(amount <= address(this).balance, "not enough funds");
        payable(receiver).transfer(amount); 
        funds -= amount;  
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