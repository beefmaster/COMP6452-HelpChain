//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./Whitelist.sol";
import "./Admin.sol";
import "./ReceiverFactory.sol";

/*
    This class is a factory class used to produce instances of Corporates, Corporates will act as a parent class to Subsidiary 
*/
contract CorporateFactory { 
    address public owner; // owner address 
    Admin public admin; // admin contract
    mapping(uint => corporate) public corporates; //list of corporates 
    uint public numCorps; // number of corporates
    bool active = true; //whether this contract is active 

    // Struct used to store corporates in the mapping
    struct corporate {
        address corpAddress;
        uint id;
        bool valid;
    }

    // The constructor links an associated Admin contract 
    constructor(Admin admin_) {
        owner = msg.sender;
        admin = admin_;
    }

    //function to create a new Corporate with name <corpName> 
    function createCorp(string memory corpName, address owner_) public  permissioned activeContract returns(address corpAddr){
        Corporate newCorp = new Corporate(admin,corpName, owner_, numCorps); // passes parent's admin, address of owner and corp name
        corporates[numCorps] = corporate(address(newCorp), numCorps, true); // add the corporate to the last spot in the list 
        numCorps += 1;
        return address(newCorp);
    }

    // get corporate address given id 
    function getCorporate(uint id) public view activeContract returns(address)  {
        return corporates[id].corpAddress;
    }

    // This function is used by the Admin to activate/disable the Corporate Factory contracts 
    function toggleContractActivation() public adminOnly returns (bool){
        active = !active;
        return(active);
    }

    // This function is used to mark a corporate as invalid
    function disableCorporate(uint id) public permissioned activeContract{
        require(checkIfCorporateValid(id) == true); // check that it is still valid
        Corporate(corporates[id].corpAddress).disableCorporate(); // disable the Corporate
    }

    function checkIfCorporateValid(uint id) public view activeContract returns (bool){
        require(corporates[id].corpAddress != address(0), 'Not a listed corporate'); //check if corporate in factory list
        return Corporate(corporates[id].corpAddress).valid(); // return if the contract is valid 

    }
    
    modifier adminOnly {
        require(msg.sender == admin.owner(), "Only the admin can access this function");
        _;
    }
    modifier permissioned {
        require(msg.sender == owner || msg.sender == admin.owner(), "Only the owner/admin can access this function");
        _;
    }

    modifier activeContract{
        require(active == true, "Contract no longer active");
        _;
    }
}

contract Corporate {
    address public owner; // owner of the contract e.g. a Corporates own address
    Admin public admin; // admin of the system
    CorporateFactory parent; // Corporate Factory this was created from 
    
    uint public corporate_id; // Corporate ID assigned to 
    string public corporate_name_; // name of the Corporate
    mapping(address => sub) public subsidiaries; // a mapping of addresses to the sub struct.
    address[] public subs; // could make this into a struct so the id can be found easily.
    Whitelist public whitelist; //whitelist associated with the corporate
    bool public valid; //checks if the contract is valid 
    uint public numOfSubs; 
    
    struct sub {
        address subAddress;
        uint id;
        bool valid;
    }

    // allows for an owner i.e. corporate to be passed into the constructor 
    constructor(Admin admin_,string memory name, address owner_, uint corp_id_){
        admin = admin_;
        owner = owner_;
        corporate_name_ = name; 
        corporate_id = corp_id_;
        parent = CorporateFactory(msg.sender);
        valid = true;    
    }

    // This function is used to create a Subsidiary branch of the Corporate representing a store
    function createSub() public  permissioned validContract returns(address){
        Subsidiary newSub = new Subsidiary(admin, owner);
        subs.push(address(newSub)); // add new sub to subsidiary array 
        subsidiaries[address(newSub)] = sub(address(newSub), numOfSubs, true); // add new sub to mapping
        numOfSubs++;
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
    
    function disableContract() public permissioned validContract{
        valid = false;
    }

    // Updates the whiteList 
    function updateWhitelist(Whitelist whitelist_) public permissioned validContract {
        require(whitelist_.owner() == owner || whitelist.owner() == admin.owner(), "Whitelist not created by known party");
        whitelist = whitelist_;
    }

    // Disable the Corporate
    function disableCorporate() public permissioned validContract returns(bool){
        valid = false;
        return valid;
    }

    modifier adminOnly {
        require(msg.sender == admin.owner(), "Only the admin can access this function");
        _;
    }
    modifier permissioned {
        require(msg.sender == owner || msg.sender == admin.owner() || msg.sender == address(parent), "Only the owner/admin/parent can access this function");
        _;
    }
    

    modifier validContract {
        require(valid == true);
        _;
    }
}

// This contract represents a Subsidiary branch of a Corporate partner
contract Subsidiary {
    Corporate public parent_; // Corporate Contract
    Admin public admin; //Admin
    address public owner; //Corporate owner address
    
    uint public amount; //Balance
    mapping(address => bool) private permissionedAddress; //provides an array of addresses the Sub can withdraw funds to
    event ValueReceived(address user, uint amount);
    bool public valid;

    // Transaction struct to be sent to the off-chain oracle 
    struct Transaction {
        uint txId; 
        address receiverId;
        uint txAmount;
        string txLink;
    }

    // Event that logs the off-chain oracle call
    event TransactionRequest (
        uint txId,
        address receiverId,
        uint txAmount
    );

    // transaction id to person id
    mapping(uint => Transaction) public transactions; // List of transactions @DEV: need to provide rec address and amount (maybe through struct)
    uint public numOfTransactions;

    constructor(Admin admin_, address owner_) {
        parent_ = Corporate(msg.sender);
        admin = admin_;
        owner = owner_;
        permissionedAddress[owner_] = true;
        amount = address(this).balance;
        valid = true;
    }


    // need to make sure no possibility for double spend
    // Will reset to zero and prevent withdrawl whilst the send transaction is processed.
    function getTake() public payable accountsAccess accountValid returns(bool)  {
        uint prevAmount = amount;
        amount = 0;
        return payable(address(parent_)).send(prevAmount);   
    }

    // Oracle end point for inserting transaction details into blockchain and recording the mapping
    // function insertTransaction(uint txId, address receiverId, uint txAmount) restricted accountValid public returns(bool) {
    function insertTransaction(Receiver receiverId, uint txAmount, string memory link) public returns(bool) {
        transactions[numOfTransactions] = Transaction(numOfTransactions, address(receiverId), txAmount, link);
        numOfTransactions++;
        require(receiverId.admin().owner() == admin.owner(), "This receiver is not created by admin");
        receiverId.sendSubFunds(this, txAmount);
        return true;
    }

    // Provides functionality to receive funds for the subsidiary
    receive() external accountValid payable{
        amount = address(this).balance;
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
    
    
    modifier accountValid {
        require(valid == true, "This Subsidiary is no longer valid");
        _;
    }
}