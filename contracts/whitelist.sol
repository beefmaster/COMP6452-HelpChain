pragma solidity >=0.7.0 <0.9.0;


contract whitelist {

    address public owner;
    
    constructor() {
        owner = msg.sender;
    }

    


}