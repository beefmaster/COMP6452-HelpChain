pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";
import "./CorporateFactory.sol";


// Contract that funds are received at
// needs to contain an idenitifier
contract Admin {

    ReceiverFactory public receiverFactory;
    FundsPool public fundsPool; 
    CorporateFactory public corporateFactory;
    address public owner;


    constructor() {
        fundsPool = new FundsPool(address(this)); 
        receiverFactory = new ReceiverFactory(address(this), address(fundsPool));
        corporateFactory = new CorporateFactory(address(this));
        owner = msg.sender;
    }



    modifier onlyFundsPool() {
        require(msg.sender == address(fundsPool));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


}

contract FundsPool{
    address public admin;
    uint public funds;
    event ValueReceived(address user, uint amount);

    constructor(address admin_){
        admin = admin_;
    }

    function distributeFunds(uint amount, address[] memory receivers) public onlyOwner{
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

