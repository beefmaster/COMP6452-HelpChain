pragma solidity >=0.7.0 <0.9.0;
import "./CorporateFactory.sol";
// Contract that funds are received at
// needs to contain an idenitifier
contract Receiver {

    address public ownerReceiver;
    address public admin;
    uint public funds;
    event ValueReceived(address user, uint amount);



    constructor(address admin_) {
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
        address corp = address(toSend.parent_());
        //get the address of the corporate Factory 
        address corp_fac = address(admin.corporateFactory());
        //check if the corporate is valid through the corporate factory
        require(corp_fac.checkIfCorporateValid(toSend.parent_.corporate_id) == true, "Not valid corporate ID");
        //check if the subsidiary is valid for the corporate 
        require(corp_fac.getCorporate(toSend.parent_.corporate_id).checkIfSubsidiaryValid(address(toSend)) == true, "Not a valid subsidiary");

        // send the requested funds 
        payable(toSend).send(tx_amount);
    
    }

    modifier onlyOwner() {
        require(msg.sender == ownerReceiver || msg.sender == admin);
        _;
    }
}

contract ReceiverFactory {
    address public owner;
    address public admin;
    Receiver[] public receiver_array;
    mapping(address=> bool) public receivers;
    address public corporateFactory;

    constructor(address admin_) {
        admin = admin_;
        owner = msg.sender;
    }

    function createreceiver() public onlyOwner returns (address) {
        Receiver child = new Receiver(this.admin);
        receivers[address(child)] = true;
        receiver_array.push(child);
        return address(child);
    }

    function checkReceiver(address toCheck) external view returns (bool){
        if (receivers[toCheck] == true ){
            return true;
        }
            return false;
    }

    function updateCorporateFactory(address corp) public onlyOwner {
        corporateFactory = corp;
    }

    function getReceiver(uint index) public view returns(address){
        return address(receiver_array[index]);
    }

    function getNumOfReceivers() public view returns(uint){
        return receiver_array.length;
    }

    modifier onlyOwner() {
        require(msg.sender ==  owner || msg.sender == admin);
        _;
    }

}
