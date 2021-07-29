pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";
// Contract that creates givers
// needs to contain an idenitifier
contract Giver {

    GiverFactory public ownerGiver;
    address public admin;
    address public fundsPoolAddress;
    event ValueGiven(address user, uint amount);

    constructor(GiverFactory ownerGiver_, address fundsPoolAddress_, address admin_) {
        ownerGiver = ownerGiver_;
        fundsPoolAddress = fundsPoolAddress_;
        admin = admin_;
    }

    function addFunds(address ownerGiver_, uint amount) public {
        payable(ownerGiver_).transfer(amount);
    }

    function giveFunds(uint amount, address to_) public payable onlyOwner {

        if (address(this).balance >= amount) {
            payable(to_).transfer(amount);

        }
    }

    modifier onlyFundsPool() {
        require(address(this) == fundsPoolAddress);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == address(ownerGiver));
        _;
    }
}

contract GiverFactory {

    address public owner;
    address public admin;
    address public fundsPool;
    mapping(address => bool) givers;
    uint public numberOfGivers;

    constructor(address admin_) {
        owner = msg.sender;
        admin  = admin_;
    }

    function creategiver() public onlyOwner returns (address) {
        Giver child = new Giver(this, address(fundsPool));
        givers[address(child)]  = true;
        numberOfGivers += 1;
        return address(child);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}
