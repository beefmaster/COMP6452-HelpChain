pragma solidity >=0.7.0 <0.9.0;

import "./Whitelist.sol";
import "./Admin.sol";


contract CorporateFactory { 
    address public owner; // owner address 
    Admin public admin;
    mapping(uint => corporate) public corporates;
    uint numCorps; // a mapping of contract ids to the corporate struct.
    bool active = true;

    struct corporate {
        address corpAddress;
        uint id;
        bool valid;
    }

    constructor(Admin admin_) {
        owner = msg.sender;
        admin = admin_;
    }

    function createCorp(string memory corpName) public  permissioned activeContract returns(bool){
        Corporate newCorp = new Corporate(owner,admin,corpName);
        corporates[numCorps] = corporate(address(newCorp), numCorps, true);
        numCorps += 1;
        return true;
    }

    function getCorporate(uint id) public view activeContract returns(address)  {
        return corporates[id].corpAddress;
    }

    function toggleContractActivation() public permissioned returns (bool){
        active = !active;
        return(active);
    }

    function disableCorporate(uint id) public permissioned activeContract returns (bool){
        corporates[id].valid = false;
    }

    function checkIfCorporateValid(uint id) public view activeContract returns (bool){
        require(corporates[id].corpAddress != address(0), 'Not a valid corporate');
        return corporates[id].valid;

    }
    
    modifier permissioned {
        require(msg.sender == owner || msg.sender == address(admin), "Only the owner/admin can access this function");
        _;
    }

    modifier activeContract{
        require(active == true, "Contract no longer active");
        _;
    }
}

contract Corporate {
    address public creator_; // creator of the contract
    address public owner; // owner of the contract i.e the corporate
    Admin public admin;
    uint public corporate_id;
    string public corporate_name_; // name of the contract
    mapping(address => sub) public subsidiaries; // a mapping of addresses to the sub struct.
    address[] public subs; // could make this into a struct so the id can be found easily.
    Whitelist public whitelist; //whitelist associated with the corporate
    bool valid; //checks if the contract is valid 
    
    struct sub {
        address subAddress;
        uint id;
        bool valid;
    }


    // allows for an owner i.e. corporate to be passed into the constructor 
    constructor(address owner_, Admin admin_, string memory name){
        owner = owner_;
        admin = admin_;
        creator_ = msg.sender;
        corporate_name_ = name; 
        valid = true;    
    }

    // This function is used to create a Subsidiary branch of the Corporate representing a store
    function createSub(uint id) public  permissioned validContract returns(bool){
        // if set to default address the contract does not yet exist 
        require(getSubContract(id) != address(0));
        Subsidiary newSub = new Subsidiary(this);
        subs.push(address(newSub)); // add new sub to subsidiary array 
        subsidiaries[address(newSub)] = sub(address(newSub), id, true); // add new sub to mapping
        return true;
    }

    // returns the subsidiary struct
    function getSubContract(uint id) public view validContract returns(address)  {
        return subs[id];
    }

    function checkIfSubsidiaryValid(address toCheck) public view validContract returns(bool){
        require(subsidiaries[toCheck].subAddress != address(0), "Not a subsidiary address");
        return subsidiaries[toCheck].valid;
    }

    // updates the whiteList 
    function updateWhitelist(Whitelist whitelist_) public permissioned validContract {
        require(whitelist_.owner() == owner || whitelist.owner() == creator_, "Whitelist not created by known party");
        whitelist = whitelist_;
    }

    //disable the Corporate
    function disableCorporate() public permissioned validContract returns(bool){
        valid = false;
        return valid;
    }

    modifier permissioned {
        require(msg.sender == owner || msg.sender == creator_);
        _;
    }

    modifier validContract {
        require(valid == true);
        _;
    }
}



// This contract represent a Subsidiary branch of a corporate 
contract Subsidiary {
    Corporate public parent_; // Corporate Contract
    uint amount; //Balanace
    mapping(address => bool) private permissionedAddress; //provides an array of addresses the Sub can withdraw funds to
    event ValueReceived(address user, uint amount);


    struct transaction{
        uint id; 
        address receiver_id;
        uint amount;
    }

    // transaction id to person id
    mapping(uint => transaction) transactions; // List of transactions @DEV: need to provide rec address and amount (maybe through struct)
    uint numOfTransactions;

    constructor(Corporate corp) {
        parent_ = corp;
        amount = 0;
    }

    // need to make sure no possibility for double spend
    // Will reset to zero and prevent withdrawl whilst the send transaction is processed.
    function getTake() public payable accountsAccess returns(bool)  {
        uint prevAmount = amount;
        amount = 0;
        return payable(address(parent_)).send(prevAmount); // need to write a fallback function if this fails.
    }

    // Oracle end point.
    // reassess this function as it always returns true.
    function insertTransaction(uint transID, address person_id, uint tx_amount) restricted public returns(bool) {
        require(person_id.balance >= amount, "The Receiver contract does not have sufficient balance for this transaction"); 
        transactions[transID] = transaction(transID, person_id, tx_amount);
        return true;
    }

    // provides functionality to receive funds
    receive() external payable{
        emit ValueReceived(msg.sender, msg.value);
    }
    
    modifier restricted {
        require(msg.sender == address(parent_) || permissionedAddress[msg.sender] == true);
        _;
    }

    modifier accountsAccess {
        require(msg.sender == address(parent_));
        _;
    }
}