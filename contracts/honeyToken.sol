// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EVAToken is ERC20, Ownable {
    // _balance[user][epoch] = balance
    mapping(address => mapping(uint256 => uint256)) private _balance;
    uint256 private _epoch;
    constructor() ERC20("EVA Token", "EVA") {
        _mint(msg.sender, 2000000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _balance[to][_epoch] += amount;
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        require(_balance[from][_epoch] >= amount);
        
        _balance[to][_epoch] += amount;
        
        if (_balance[from][_epoch] >= amount) {
            _balance[from][_epoch] -= amount;
        }

        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address , address to, uint256 )  internal override {
        if(to == owner()) {
            _epoch += 1;
            _balance[owner()][_epoch] = balanceOf(to);
        }
    }
}
