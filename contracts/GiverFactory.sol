pragma solidity >=0.7.0 <0.9.0;

// Contract that creates givers
// needs to contain an idenitifier
contract Giver {

    address public ownerGiver;
    uint public funds;
    event ValueGiven(address user, uint amount);

    constructor(address ownerGiver_, address funds_) {
        ownerGiver = ownerGiver_;
        funds = funds_;
    }

    function addFunds(address ownerGiver_, uint amount) public {
        funds += amount;
        payable(ownerGiver_).transfer(amount);
    }

    function giveFunds(uint amount, address to_, address fundsPoolAddress_) public payable onlyOwner {
        if (funds >= amount) {
            funds -= amount;
            Receiver r = new  Receiver(to_, fundsPoolAddress_);
            r.receive({
                from: address(this),
                value: amount
            });
        }
    }

    modifier onlyOwner() {
        require(msg.sender == ownerGiver);
        _;
    }
}

contract GiverFactory {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    Giver[] givers;
    function creategiver() public onlyOwner returns (address) {
        Giver child = new Giver(address(this), 0);
        givers.push(child);
        return address(child);
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}
