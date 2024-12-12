// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

interface ERC20Interface{
    function totalSupply() external view returns(uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint token) external returns (bool success);


    function allowance (address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract KamToken is ERC20Interface{
    string public name= "Kam Token";
    string public symbol= "KMT";
    uint public decimals=0; //18 is the usual decimal
    uint public override  totalSupply;

    address public founder;
    mapping (address=> uint) public balances;
    //eg balances[0x237638K78]=100;

    mapping(address=>mapping(address=> uint)) allowed;

  //eg  //0x111...(owner) allows 0x222...(spender) to withdraw 100 tokens from owner
    //allowed[0x111][0x222]=100;

    constructor(){
        totalSupply=1000000;
        founder=msg.sender;
        balances[founder]= totalSupply;
    }

    function balanceOf(address tokenOwner) public view override  returns (uint balance){
        return balances[tokenOwner];
    }

    function transfer (address to, uint tokens) public override returns(bool success){
        require(balances[msg.sender]>=tokens, "Insufficient funds");

        balances[to] +=tokens;
        balances[msg.sender] -=tokens;
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender) view public override returns(uint){
        return allowed[tokenOwner][spender];
    }

     modifier onlyOwner(){
        require(msg.sender==founder, "Only founder can call this function");
        _;
    }

        function approve(address spender, uint tokens) public onlyOwner override returns (bool success){
            require(balances[msg.sender]>=tokens, "insufficient funds");
            require(tokens>0, "token must be greater than 0");

            allowed[msg.sender][spender]=tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
       require(allowed[from][msg.sender]>=tokens, "You can't send more than you are allowed to"); //the tokens that the allowed sender is allowed to send (as defined by the owner) is greater or equals to what he is sending
    //technically, sender cannot transfer tokens from owners wallet that are more than the quantity he is allowed to send
    //from is the owner of the contract, address is the receiver, msg.sender is the sender and tokens is the amount sender is sending to recipient
        require(balances[from]>=tokens, "Owner has insufficient funds"); //owner has enough tokens

        balances[from]-=tokens;
        allowed[from][msg.sender]-=tokens; //amount sender is allowed to send reduces by the number of tokens he has sent
        balances[to]+=tokens;

        emit Transfer(from, to, tokens);
        return true;
    }


}