// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Context.sol";
import "./Roles.sol";
import "./Ownable.sol";


contract MinterRole is Context, Ownable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }
    //是否可以mint

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }
    //添加可mint用户
    function addMinter(address account) public virtual onlyOwner {
        _addMinter(account);
    }
    //删除mint用户|
    function renounceMinter() public virtual {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal virtual {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal virtual {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}