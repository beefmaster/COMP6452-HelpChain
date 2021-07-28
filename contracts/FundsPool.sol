contract FundsPool {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

}