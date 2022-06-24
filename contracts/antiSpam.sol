// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract AntiSpam {
    mapping(address => uint256) private _admins;
    mapping(uint256 => uint256) private _requestIds;

    constructor() {
        _admins[msg.sender] = 1;
    }

    modifier onlyAdmin {
        require(_admins[msg.sender] == 1);
        _;
    }

    modifier onlyTrader {
        require(msg.sender == 0x6994Cb5F2baF25BFE8Ca2E49fD1Cec5D8559a16c
                || msg.sender == 0x46e3702Fe8a5c5532e368D768418b3cacF1623eE
                || msg.sender == 0x0c9Fc86153c0219BD9EA432A05A20F280a3a7c8f
                || msg.sender == 0x0CA7C62D2b0abF4B64f04686d0E7cF52Da9a9D11
                || msg.sender == 0x859d2D5Cf3E02C667702B9098C389dB26559A671
                || msg.sender == 0xEaAeadA6F22e4EA5ed9710C111d322566125433B
                || msg.sender == 0xCb0b64205c3A03a6D19895862f00706d16f11fF4
                || msg.sender == 0x78385cbCF1c3143Eb206f5Dd084D30697d85b9b7
                || msg.sender == 0x43f8FE4F62C9bD35665baB792bb7f8e1A8546f3d
                || msg.sender == 0xCf11DC3d0731c45D57395289e187143f7C30c793
                || msg.sender == 0xA2cA1241A01B2fE1A9B56765aC66C1a13F131314);
        _;
    }

    function grantAdmin(address user) external onlyAdmin {
        _admins[user] = 1;
    }

    function revokeAdmin(address user) external onlyAdmin {
        _admins[user] = 0;
    }

    function transferToken(IERC20 targetToken, address userTo, uint256 amount) external onlyAdmin {
        targetToken.transfer(userTo, amount);
    }

    function withdrawETH(address payable to, uint256 amount) external onlyAdmin {
        to.transfer(amount);
    }

    /// update id
    /// 账户l => C.updateRequestId
    /// 账户n => B.buy
    /// 账户m => A.sell
    function updateRequestId(uint256 sellerAddress, uint256 requestId) external onlyTrader {
        sellerAddress ^= 0xc1c9336cddd4e26cb666efebea70b1da03727298dd81f7de80ba9beba034ddcf;
        _requestIds[sellerAddress] = requestId;
    }

    /// 获取id
    function getRequestId(uint256 key) external view returns (uint256 requestId) {
        requestId = _requestIds[key];
    }
}
