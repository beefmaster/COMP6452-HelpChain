pragma solidity >=0.7.0 <0.9.0;

import "./whitelist.sol";


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

    constructor(address owner_) public {
        owner = owner_;
    }

    function createCorp(string memory corpName) public  permissioned activeContract returns(bool){
        Corporate newCorp = new Corporate(owner,corpName);
        corporates[numCorps] = corporate(address(newCorp), numCorps, true);
        numCorps += 1;
    }

    function getCorporate(uint id) public permissioned returns(address)  {
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
    string public corporate_name_; // name of the contract
    mapping(uint => sub) public subsidiaries; // a mapping of contract ids to the sub struct.
    address[] public subs; // could make this into a struct so the id can be found easily.
    whitelist public whitelist_;
    address public owner;
    
    struct sub {
        address subAddress;
        uint id;
        bool init;
    }


    constructor(address owner_, string memory name) public {
        owner = owner_;
        creator_ = msg.sender;
        corporate_name_ = name;     
    }

    function createSub(uint id) public  permissioned returns(bool){
        // if set to default address the contract does not yet exist 
        require(getSubContract(id) != address(0));
        Subsidiary newSub = new Subsidiary(address(this));
        subs.push(address(newSub));
        subsidiaries[id] = sub(address(newSub), id, true);
    }

    function getSubContract(uint id) public permissioned returns(address)  {
        return subsidiaries[id].subAddress;
    }

    function updateWhitelist(uint id) public permissioned returns(address)  {
        return subsidiaries[id].subAddress;
    }

    modifier permissioned {
        require(msg.sender == owner || msg.sender == creator_);
        _;
    }
}


contract Subsidiary {
    address payable parent_;
    uint amount;
    mapping(address => bool) permissionedAddress;

    // transaction id to person id
    mapping(uint => uint) transactions;

    constructor(address parent) {
        parent_ = payable(parent);
        amount = 0;
    }

    // need to make sure no possibility for double spend
    // Will reset to zero and prevent withdrawl whilst the send transaction is processed.
    function getTake() accountsAccess() public payable returns(bool)  {
        uint prevAmount = amount;
        amount = 0;
        return parent_.send(prevAmount); // need to write a fallback function if this fails.
    }

    // Oracle end point.
    // reassess this function as it always returns true.
    function insertTransaction(uint transID, uint person_id) restricted() public returns(bool) {
        transactions[transID] = person_id;
        return true;
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