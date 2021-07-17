pragma solidity >=0.7.0 <0.9.0;



contract CorporateFactory {
    
    address public owner_; // owner address 
    address public creator_; // creator of the contract
    string public corporate_name_; // name of the contract
    mapping(uint => sub) public subsidiaries; // a mapping of contract ids to the sub struct.
    address[] public subs; // could make this into a struct so the id can be found easily.
    address public whitelist;

    struct sub {
        address subAddress;
        uint id;
        bool init;
    }


    constructor(address owner, string memory name, address whitelistPointer) public {
        creator_ = msg.sender;
        corporate_name_ = name;
        owner_ = owner;
        whitelist = whitelistPointer;
    }

    function createSub(uint id) public  permissioned returns(bool){
        // if set to default address the contract does not yet exist 
        require(getSubContract(id) == address(0));
        Subsidiary newSub = new Subsidiary(address(this));
        subs.push(address(newSub));
        subsidiaries[id] = sub(address(newSub), id, true);
    }

    function getSubContract(uint id) public permissioned returns(address)  {
        return subsidiaries[id].subAddress;
    }

    modifier permissioned {
        require(msg.sender == owner_ || msg.sender == creator_);
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