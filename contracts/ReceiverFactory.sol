pragma solidity >=0.7.0 <0.9.0;

// Contract that funds are received at
// needs to contain an idenitifier
contract Receiver {

    address public ownerReceiver;
    address public fundsPoolAddress;
    uint public funds;
    event ValueReceived(address user, uint amount);



    constructor(address ownerReceiver_, address fundsPoolAddress_) {
        ownerReceiver = ownerReceiver_;
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

    modifier onlyFundsPool() {
        require(msg.sender == fundsPoolAddress);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerReceiver);
        _;
    }
}

contract ReceiverFactory {

    address public fundsPool;
    address public owner;
    Receiver[] public receiver_array;
    mapping(address=> bool) public receivers;

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
