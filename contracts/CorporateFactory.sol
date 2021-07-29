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

    function createCorp(string memory corpName) public  permissioned activeContract returns(address){
        Corporate newCorp = new Corporate(owner,admin,corpName);
        corporates[numCorps] = corporate(address(newCorp), numCorps, true);
        numCorps += 1;
        return address(newCorp);
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
        return true;
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
    function createSub(uint id) public  permissioned validContract returns(address){
        // if set to default address the contract does not yet exist 
        // require(subs[id] == address(0));
        Subsidiary newSub = new Subsidiary(this);
        subs.push(address(newSub)); // add new sub to subsidiary array 
        subsidiaries[address(newSub)] = sub(address(newSub), id, true); // add new sub to mapping
        return address(newSub);
    }

    // Returns the subsidiary struct
    function getSubContract(uint id) public view validContract returns(address)  {
        return subs[id];
    }

    function checkIfSubsidiaryValid(address toCheck) public view validContract returns(bool){
        require(subsidiaries[toCheck].subAddress != address(0), "Not a subsidiary address");
        return subsidiaries[toCheck].valid;
    }

    // Updates the whiteList 
    function updateWhitelist(Whitelist whitelist_) public permissioned validContract {
        require(whitelist_.owner() == owner || whitelist.owner() == creator_, "Whitelist not created by known party");
        whitelist = whitelist_;
    }

    // Disable the Corporate
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



// This contract represents a Subsidiary branch of a Corporate partner
contract Subsidiary {
    Corporate public parent_;   // Corporate Contract
    uint amount;                // Subsidiary balance 
    mapping(address => bool) private permissionedAddress; //provides an array of addresses the Sub can withdraw funds to
    event ValueReceived(address user, uint amount);

    // Transaction struct to be sent to the off-chain oracle 
    struct Transaction {
        uint txId; 
        address receiverId;
        uint txAmount;
        string txLink;
    }

    // Event that triggers the off-chain oracle
    event TransactionRequest (
        uint txId,
        address receiverId,
        uint txAmount
    );

    // transaction id to person id
    mapping(uint => Transaction) transactions; // List of transactions @DEV: need to provide rec address and amount (maybe through struct)
    uint numOfTransactions;

    constructor(Corporate corp) {
        parent_ = corp;
        amount = 0;
    }

    // Ensure there is no double spending
    // Will reset to zero and prevent withdrawal whilst the send transaction is being processed.
    function getTake() public payable accountsAccess returns(bool)  {
        uint prevAmount = amount;
        amount = 0;
        return payable(address(parent_)).send(prevAmount);   
    }

    // Oracle end point for inserting transaction details into blockchain and recording the mapping
    function insertTransaction(uint txId, address receiverId, uint txAmount) restricted public returns(bool) {
        require(receiverId.balance >= amount, "The Receiver contract does not have sufficient balance for this transaction"); 
        emit TransactionRequest(txId, receiverId, txAmount);
        transactions[txId] = Transaction(txId, receiverId, txAmount, "http://mumboJumbo.jpg");
        return true;
    }

    // Provides functionality to receive funds for the subsidiary
    receive() external payable{
        emit ValueReceived(msg.sender, msg.value);
    }
    

    modifier restricted {
        require(msg.sender == address(parent_) || permissionedAddress[msg.sender] == true);
        _;
    }

    // Restrict account access
    modifier accountsAccess {
        require(msg.sender == address(parent_));
        _;
    }
}