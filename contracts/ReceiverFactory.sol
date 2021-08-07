pragma solidity >=0.7.0 <0.9.0;
import "./CorporateFactory.sol";
import "./Admin.sol";

// Contract that funds are received at
// needs to contain an idenitifier
contract Receiver {

    address public ownerReceiver;
    Admin public admin;
    uint public funds;
    event ValueReceived(address user, uint amount);



    constructor(Admin admin_) {
        admin = admin_;
        ownerReceiver = msg.sender;
    }

    // Gives the receiver the funds
    receive() external payable {
        funds += msg.value;
        emit ValueReceived(msg.sender, msg.value);
    }

    function spendFunds(uint cost, address to_) public payable onlyOwner {
        funds -= cost;
        payable(to_).transfer(cost);
    }


    // this function is used to send Subsidiaries funds when a transaction is made
    function sendSubFunds(Subsidiary toSend, uint tx_amount) public payable returns(bool){
        require(address(this).balance >= tx_amount, "Receiver contract does not have enough funds");

        //get the Corporate parent of the subsidiary 
        Corporate corp = toSend.parent_();
        //get the address of the corporate Factory 
        CorporateFactory corp_fac = admin.corporateFactory();
        //check if the corporate is valid through the corporate factory
        require(corp_fac.checkIfCorporateValid(corp.corporate_id()) == true, "Not valid corporate ID");
        //check if the subsidiary is valid for the corporate 
        require(Corporate(corp_fac.getCorporate(corp.corporate_id())).checkIfSubsidiaryValid(address(toSend)) == true, "Not a valid subsidiary");

        // send the requested funds 
        payable(toSend).transfer(tx_amount);
        return true;
    
    }

    modifier onlyOwner() {
        require(msg.sender == ownerReceiver || msg.sender == address(admin));
        _;
    }
}

contract ReceiverFactory {
    address public owner; // Owner of the contract
    Admin public admin; // Associated Admin
    Receiver[] public receiver_array; // Array of receivers
    mapping(address=> bool) public receivers; 
    address public corporateFactory;

    constructor(Admin admin_) {
        admin = admin_;
        owner = msg.sender;
    }

    // This function creates a recevier contract
    function createreceiver() public onlyOwner returns (address) {
        // passes the admin to the receiver
        Receiver child = new Receiver(admin);
        // marks the receiver as valid 
        receivers[address(child)] = true;
        // adds it to the array of receivers
        receiver_array.push(child);
        return address(child);
    }

    // checks if receiver exists
    function checkReceiver(address toCheck) external view returns (bool){
        if (receivers[toCheck] == true ){
            return true;
        }
            return false;
    }

    // updates associated Corporate Factory
    function updateCorporateFactory(address corp) public onlyOwner {
        corporateFactory = corp;
    }

    // gets a Receiver at index
    function getReceiver(uint index) public view returns(address){
        return address(receiver_array[index]);
    }

    // Returns total number of receivers
    function getNumOfReceivers() public view returns(uint){
        return receiver_array.length;
    }

    // checks if valid sender
    modifier onlyOwner() {
        require(msg.sender ==  owner || msg.sender == address(admin));
        _;
    }

}
