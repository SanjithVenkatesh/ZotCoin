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
    string[] user_types = ["admin", "student", "club"];

    // basic events that can be invoked
    event transfer(address _from, address _to, uint transfer_value);
    event approval(address _owner, address _spender, uint transfer_value);
    event new_club_created(address _owner, string club_name, address club_address);
    event new_admin_added(address _new_admin, address _approval_admin);

    // necessary mappings to keep track of zot amounts and owed amounts
    mapping (address => uint) public balances;
    mapping (address => mapping(address => uint)) public owed_zots;
    mapping (string => string) public symbol_to_name;
    mapping (address => address[]) public club_members;
    mapping (address => address) public club_owners;
    mapping (address => string) public user_type;
    mapping (address => address) public club_wallet;

    // constructor deals with the creation of the smart contract
    // TODO: make it so only an user with type school can access it
    constructor(string memory _name, string memory _symbol, uint _initial_supply) public {
        zot_name = _name;
        zot_symbol = _symbol;
        total_supply = _initial_supply;
        balances[msg.sender] = _initial_supply;
        user_type[msg.sender] = "admin";
    }

    // returns the number of zots an address holds
    function balance_of(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    // returns the number of zots that a particular owner owes to another address
    function owes_zots(address _from, address _to) public view returns (uint balance) {
        return owed_zots[_from][_to];
    }

    // send a number of zots from one address to another
    function send_zots(address _from, address _to, uint num_zots) public payable  {
        require(balances[_from] >= num_zots, "Not enough Zots to activate transfer");
        balances[_from] -= num_zots;
        balances[_to] += num_zots;
        emit approval(_to, _from, num_zots);
    }

    //creates new club based on name, address, wallet, and owner
    function set_new_club(string memory _new_club_name, address _new_club, address _owner, address _club_account) public payable {
        require(keccak256(abi.encodePacked(user_type[_owner])) == keccak256("student"), "type of address not permited to create new club");
        club_owners[_new_club] = _owner;
        club_members[_new_club] = [_owner];
        club_wallet[_new_club] = _club_account;
        balances[_club_account] = 0;
        emit new_club_created(_owner, _new_club_name, _club_account);
    }

    // registers new member into a club and pushes into the club member list
    function register_new_member(address _new_member, address _club_to_join) public payable{
        require(keccak256(abi.encode(user_type[_new_member])) == keccak256("member"), "Invalid member to join");
        club_members[_club_to_join].push(_new_member);
    }

    // adds new admin onto the contract, requires another admin to give approval
    function add_new_admin(address _member_to_admin, address _approved_admin) public payable{
        require(keccak256(abi.encode(user_type[_approved_admin])) == keccak256("admin"), "approved_admin not allowed to approve new users");
        require(keccak256(abi.encode(user_type[_member_to_admin])) == keccak256("member"), "not possible based on types of users");
        user_type[_member_to_admin] = "admin";
        emit new_admin_added(_member_to_admin, _approved_admin);
    }
}