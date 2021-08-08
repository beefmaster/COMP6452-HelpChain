//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";
import "./Admin.sol";
// Contract that creates givers
// needs to contain an idenitifier
contract Giver {

    GiverFactory public ownerGiver;
    Admin public admin;
    uint public funds;
    address public fundsPoolAddress;
    event ValueReceived(address user, uint amount);

    constructor(address fundsPoolAddress_, Admin admin_) payable {
        fundsPoolAddress = fundsPoolAddress_;
        funds = 0;
        admin = admin_;
    }

    // Gives the giver the funds
    receive() external payable {
        funds += msg.value;
        emit ValueReceived(msg.sender, msg.value);
    }

    function giveFunds(uint amount) public payable {
        if (funds >= amount){
            payable(fundsPoolAddress).transfer(amount);
            funds -= amount;
        }
    }
}

contract GiverFactory {

    address public owner;
    Admin public admin;
    address public fundsPool;
    mapping(address => bool) givers;
    uint public numberOfGivers;

    constructor(Admin admin_) payable {
        owner = msg.sender;
        admin  = admin_;
    }

    function creategiver() public onlyOwner returns (address) {
        Giver child = new Giver(address(fundsPool), admin);
        givers[address(child)]  = true;
        numberOfGivers += 1;
        return address(child);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}
