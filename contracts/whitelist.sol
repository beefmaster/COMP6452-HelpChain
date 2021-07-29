pragma solidity >=0.7.0 <0.9.0;


contract Whitelist {

    address public owner;
    bytes32 public whiteListHash;
    
    constructor(bytes32 whiteListHash_) {
        owner = msg.sender;
        whiteListHash = whiteListHash_;
    }
   

}