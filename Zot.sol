pragma solidity ^0.5.11;

/**
Zot is a basic account that can be built upon by more specialied types of accounts.
This contracts will describe the basic functionality and will include necessary legalalities to prevent illegal activity.

It will deal with the transfer of money as well as checking on balances of all address that have used Zots before

*/

contract Zot {
    // class variables that can be accessed anywhere in the contract, basic characteristics of each Zot
    string public zot_name;
    string public zot_symbol;
    uint total_supply;

    // basic events that can be invoked
    event transfer(address _from, address _to, uint transfer_value);
    event approval(address _owner, address _spender, uint transfer_value);

    // necessary mappings to keep track of zot amounts and owed amounts
    mapping (address => uint) public balances;
    mapping (address => mapping(address => uint)) public owed_zots;

    constructor(string memory _name, string memory _symbol, uint _initial_supply) public {
        zot_name = _name;
        zot_symbol = _symbol;
        total_supply = _initial_supply;
        balances[msg.sender] = _initial_supply;
    }

    function balance_of(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function owes_zots(address _from, address _to) public view returns (uint balance) {
        return owed_zots[_from][_to];
    }

    function send_zots(address _from, address _to, uint num_zots) public payable  {
        require(balances[_from] >= num_zots, "Not enough Zots to activate transfer");
        balances[_from] -= num_zots;
        balances[_to] += num_zots;
        emit approval(_to, _from, num_zots);
    }
}