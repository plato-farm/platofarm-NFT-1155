// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EnumerableSet.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract MinterRole is Ownable {

    using SafeMath for uint256; 
    EnumerableSet.AddressSet private _minters;

    struct LimitMinter {
        bool isLimit;
        uint256 amount;
    }

    mapping(address => LimitMinter) private limitMinter;
    mapping(address => uint256) public minterTotalMint;

    event MinterAdded(address indexed account);
    event LimitMinterAdded(address indexed account, uint256 indexed amount);
    event MinterRemoved(address indexed account);
    event LimitMinterRemoved(address indexed account);
    event IncreaseMint(address indexed account, uint256 indexed amount);
    event DecreaseMint(address indexed account, uint256 indexed amount);

    constructor () {
        addMinter(_msgSender());
    }

    modifier onlyMinter {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function getMinterLength() public view returns (uint256) {
        return EnumerableSet.length(_minters);
    }

    function getMinter(uint256 _index) public view onlyOwner returns (address) {
        require(_index <= getMinterLength() - 1, "getMinter: index out of bounds");
        return EnumerableSet.at(_minters, _index);
    }

    function isMinter(address account) public view returns (bool) {
        return EnumerableSet.contains(_minters, account);
    }

    function addMinter(address account) public onlyOwner returns (bool) {
        require(account != address(0), "addMinter: account is the zero address");
        emit MinterAdded(account);
        return EnumerableSet.addSet(_minters, account);
    }

    function removeMinter(address account) public onlyOwner returns (bool) {
        require(isMinter(account), "removeMinter: account not be listed");
        emit MinterRemoved(account);
        return EnumerableSet.remove(_minters, account);
    }

    function isLimitMinter(address account) public view returns (bool) {
        return limitMinter[account].isLimit;
    }
    
    function getMinterTotalMint(address account) public view returns (uint256) {
        return minterTotalMint[account];
    }
    
    function getLimitMinter(address account) public view returns (bool, uint256) {
        require(isLimitMinter(account), "getLimitMinter: account not is limit inter");
        return (limitMinter[account].isLimit, limitMinter[account].amount);
    }

    function addLimitMinter(address account, uint256 amount) public onlyOwner returns (bool) {
        require(!isLimitMinter(account), "addLimitMinter: account is already a limitMinter");
        limitMinter[account].isLimit = true;
        limitMinter[account].amount = limitMinter[account].amount.add(amount);
        emit LimitMinterAdded(account, amount);
        return true;
    }

    function increaseMint(address account, uint256 amount) public onlyOwner returns (bool) {
        require(isLimitMinter(account), "increaseMint: account not a limitMinter");
        limitMinter[account].amount = limitMinter[account].amount.add(amount);
        emit IncreaseMint(account, amount);
        return true;
    }

    function decreaseMint(address account, uint256 amount) public onlyOwner returns (bool) {
        require(isLimitMinter(account), "decreaseMint: account not a limitMinter");
        require(amount <= limitMinter[account].amount, "decreaseMint: over total limit");
        limitMinter[account].amount = limitMinter[account].amount.sub(amount);
        emit DecreaseMint(account, amount);
        return true;
    }

    function removeLimitMinter(address account) public onlyOwner returns (bool) {
        require(isLimitMinter(account), "removeLimitMinter: account not a limitMinter");
        delete limitMinter[account];
        emit LimitMinterRemoved(account);
        return true;
    }
}

