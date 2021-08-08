//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "./ReceiverFactory.sol";
import "./Admin.sol";
// Contract that creates givers
// needs to contain an idenitifier
contract Giver {

    GiverFactory public ownerGiver;
    Admin public admin;
    address public fundsPoolAddress;
    uint public amount;
    event ValueReceived(address user, uint amount);

    constructor(GiverFactory ownerGiver_, address fundsPoolAddress_, Admin admin_) payable {
        ownerGiver = ownerGiver_;
        fundsPoolAddress = fundsPoolAddress_;
        admin = admin_;
    }

    // Gives the giver the funds
    receive() external payable {
        amount = address(this).balance;
    }

    function giveFunds(uint amount) public payable {
        payable(fundsPoolAddress).call{value:amount}("");
    }

}

contract GiverFactory {

    address public owner;
    Admin public admin;
    address public fundsPool;
    mapping(address => bool) givers;
    Giver[] public giver_array; // Array of receivers
    uint public numberOfGivers;

    constructor(Admin admin_, address fundsPool_) payable {
        owner = msg.sender;
        admin  = admin_;
        fundsPool = fundsPool_;
    }

    function creategiver() public onlyOwner returns (address) {
        Giver child = new Giver(this, address(fundsPool), admin);
        givers[address(child)]  = true;
        numberOfGivers += 1;
        giver_array.push(child);
        return address(child);
    }

    // gets a Giver at index
    function getGiver(uint index) public view returns(address){
        return address(giver_array[index]);
    }
    
    // Returns total number of givers
    function getNumOfGivers() public view returns(uint){
        return giver_array.length;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}
