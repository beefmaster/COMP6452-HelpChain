pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";
import "./CorporateFactory.sol";
import "./FundsPool.sol";


// Contract that funds are received at
// needs to contain an idenitifier
contract Admin {

    ReceiverFactory public receiverFactory;
    FundsPool public fundsPool; 
    CorporateFactory public corporateFactory;
    address public owner;


    constructor() {
        owner = msg.sender;
    }

    function updateFundsPool(FundsPool pool) public {
        // make sure that this pool was created by the admin contract 
        require(owner == pool.admin(), "Pool was not created by the admin");
        fundsPool = pool;
    }

    function updateCorporateFactory(CorporateFactory fac) public {
        // make sure that this pool was created by the admin contract 
        require(owner == fac.owner(), "Factory was not created by the admin");
        corporateFactory = fac;
    }

    function updateReceiverFactory(ReceiverFactory fac) public {
        // make sure that this pool was created by the admin contract 
        require(owner == fac.owner(), "Factory was not created by the admin");
        receiverFactory = fac;
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


