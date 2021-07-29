pragma solidity >=0.7.0 <0.9.0;
import "./CorporateFactory.sol";
// Contract that funds are received at
// needs to contain an idenitifier
contract Receiver {

    address public ownerReceiver;
    address public owner;
    address public fundsPoolAddress;
    uint public funds;
    event ValueReceived(address user, uint amount);



    constructor(address owner_, address fundsPoolAddress_) {
        owner = owner_;
        ownerReceiver = msg.sender;
        fundsPoolAddress = fundsPoolAddress_;
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

        //check if the corporate is valid through the corporate factory

    }

    modifier onlyFundsPool() {
        require(msg.sender == fundsPoolAddress);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerReceiver || msg.sender == owner);
        _;
    }
}

contract ReceiverFactory {

    address public fundsPool;
    address public owner;
    Receiver[] public receiver_array;
    mapping(address=> bool) public receivers;
    address public corporateFactory;

    constructor(address fundsPool_) {
        fundsPool = fundsPool_;
        owner = msg.sender;
    }

    function createreceiver() public onlyOwner returns (address) {
        Receiver child = new Receiver(address(this), address(fundsPool));
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
        require(msg.sender ==  owner);
        _;
    }

}
