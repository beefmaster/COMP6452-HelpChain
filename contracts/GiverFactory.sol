pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";
// Contract that creates givers
// needs to contain an idenitifier
contract Giver {

    GiverFactory public ownerGiver;
    uint public funds;
    event ValueGiven(address user, uint amount);

    constructor(GiverFactory ownerGiver_, address funds_) {
        ownerGiver = ownerGiver_;
        funds = funds_;
    }

    function addFunds(address ownerGiver_, uint amount) public {
        funds += amount;
        payable(ownerGiver_).transfer(amount);
    }

    function giveFunds(uint amount, address to_) public payable onlyOwner {

        if (this.balance >= amount) {
            funds -= amount;
            payable(to_).transfer(amount);

        }
    }

    modifier onlyOwner() {
        require(msg.sender == ownerGiver);
        _;
    }
}

contract GiverFactory {

    address public owner;
    mapping(address => bool) givers;
    uint public numberOfGivers;

    constructor() {
        owner = msg.sender;
    }

    function creategiver() public onlyOwner returns (address) {
        Giver child = new Giver(address(this), 0);
        givers[address(child)]  = true;
        numberOfGivers += 1;
        return address(child);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}
