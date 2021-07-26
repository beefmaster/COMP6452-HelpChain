pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";
import "./CorporateFactory.sol";


// Contract that funds are received at
// needs to contain an idenitifier
contract Admin {

    ReceiverFactory public receiverFactory;
    FundsPool public fundsPool; 
    CorporateFactory public corporateFactory;
    


    constructor() {
       fundsPool = new FundsPool(this.address); 
       receiverFactory = new ReceiverFactory(this.address, fundsPool.address);
       corporateFactory = new CorporateFactory(this.address);

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

contract FundsPool{
    address public admin;
    uint public funds;

    constructor(address admin_){
        admin = admin_;
    }

    function distributeFunds(uint amount, address[] receivers) public onlyOwner{
        require(amount <= address(this).balance, "not enough funds");
        uint fundsToSend;
        fundsToSend = amount / receivers.length; 

        for (uint i = 1; i <= receivers.length; i++){
            sendFunds(fundsToSend, receivers[i]);
        }
        
    }

    function sendFunds(uint amount, address receiver) public onlyOwner{
        require(amount <= address(this).balance, "not enough funds");
        receiver.transfer(amount);   
    }


    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

}

