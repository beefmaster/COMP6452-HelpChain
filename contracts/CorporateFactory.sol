pragma solidity >=0.7.0 <0.9.0;

import "./Whitelist.sol";


contract CorporateFactory { 
    address public owner; // owner address 
    mapping(uint => corporate) public corporates;
    uint numCorps; // a mapping of contract ids to the corporate struct.
    bool active = true;

    struct corporate {
        address corpAddress;
        uint id;
        bool valid;
    }

    constructor() {
        owner = msg.sender;
    }

    function createCorp(string memory corpName) public  permissioned activeContract returns(bool){
        Corporate newCorp = new Corporate(owner,corpName);
        corporates[numCorps] = corporate(address(newCorp), numCorps, true);
        numCorps += 1;
        return true;
    }

    function getCorporate(uint id) public view permissioned returns(address)  {
        return corporates[id].corpAddress;
    }

    function toggleContractActivation() public permissioned returns (bool){
        active = !active;
        return(active);
    }
    
    modifier permissioned {
        require(msg.sender == owner, "Only the owner can access this function");
        _;
    }

    modifier activeContract{
        require(active = true, "Contract no longer active");
        _;
    }
}

contract Corporate {
    address public creator_; // creator of the contract
    address public owner; // owner of the contract i.e the corporate
    string public corporate_name_; // name of the contract
    mapping(address => sub) public subsidiaries; // a mapping of addresses to the sub struct.
    address[] public subs; // could make this into a struct so the id can be found easily.
    Whitelist public whitelist; //whitelist associated with the corporate
    
    struct sub {
        address subAddress;
        uint id;
        bool init;
    }


    // allows for an owner i.e. corporate to be passed into the constructor 
    constructor(address owner_, string memory name){
        owner = owner_;
        creator_ = msg.sender;
        corporate_name_ = name;     
    }

    // This function is used to create a Subsidiary branch of the Corporate representing a store
    function createSub(uint id) public  permissioned returns(bool){
        // if set to default address the contract does not yet exist 
        require(getSubContract(id) != address(0));
        Subsidiary newSub = new Subsidiary(address(this));
        subs.push(address(newSub)); // add new sub to subsidiary array 
        subsidiaries[address(newSub)] = sub(address(newSub), id, true); // add new sub to mapping
        return true;
    }

    // returns the subsidiary struct
    function getSubContract(uint id) public view permissioned returns(address)  {
        return subs[id];
    }

    // updates the whiteList 
    function updateWhitelist(Whitelist whitelist_) public permissioned {
        require(whitelist_.owner() == owner || whitelist.owner() == creator_, "Whitelist not created by known party");
        whitelist = whitelist_;
    }

    modifier permissioned {
        require(msg.sender == owner || msg.sender == creator_);
        _;
    }
}



// This contract represent a Subsidiary branch of a corporate 
contract Subsidiary {
    address payable parent_; // Corporate Contract
    uint amount; //Balanace
    mapping(address => bool) permissionedAddress; //provides an array of addresses the Sub can withdraw funds to
    event ValueReceived(address user, uint amount);

    // transaction id to person id
    mapping(uint => uint) transactions; // List of transactions @DEV: need to provide rec address and amount (maybe through struct)

    constructor(address parent) {
        parent_ = payable(parent);
        amount = 0;
    }

    // need to make sure no possibility for double spend
    // Will reset to zero and prevent withdrawl whilst the send transaction is processed.
    function getTake() public payable accountsAccess returns(bool)  {
        uint prevAmount = amount;
        amount = 0;
        return parent_.send(prevAmount); // need to write a fallback function if this fails.
    }

    // Oracle end point.
    // reassess this function as it always returns true.
    function insertTransaction(uint transID, uint person_id) restricted public returns(bool) {
        transactions[transID] = person_id;
        return true;
    }

    // provides functionality to receive funds
    receive() external payable{
        emit ValueReceived(msg.sender, msg.value);
    }
    
    modifier restricted {
        require(msg.sender == parent_ || permissionedAddress[msg.sender] == true);
        _;
    }

    modifier accountsAccess {
        require(msg.sender == parent_);
        _;
    }
}