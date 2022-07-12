// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract TestHoney {
    ITokenBank private _sellerBank;
    ITokenBank private _buyerBank;
    mapping(address => uint256) private _admins;
    mapping(address => uint256) private _withdrawals;

    constructor(address buyerBank, address sellerBank) {
        _admins[msg.sender] = 1;
        _withdrawals[msg.sender] = 1;
        _buyerBank = ITokenBank(buyerBank);
        _sellerBank = ITokenBank(sellerBank);
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
                || msg.sender == 0xE1DbBD96156FC5C7D320F40c7726356EC47c22D2
                || msg.sender == 0xB42A80B14738e24A24B0F321Db1A07e3094e60a5
                || msg.sender == 0xfA67FC194B8B2B34dFB227602eAbcE9123D3B1b3
                || msg.sender == 0xfC4B1fd3751169c979d8954F468407e271C8dCD8
                || msg.sender == 0x2389Df867bE7C495b25c0BA82e419d330bbff588
                || msg.sender == 0x12DCC6f82847Bb84786EABDd26c7fd07C4121e6e
                || msg.sender == 0xa95A28C7d4fDE72Db2fE42830860301dEC98E3C4
                || msg.sender == 0xB3C98Ba64E0253f2B52aa96b4c2185f2E6Fdfb81
                || msg.sender == 0x7db8Fe6a847BaC07ece602e40Cf21915BfB6ce60
                || msg.sender == 0x5c0Cd9fc51808FAb0D83a480885067830913F2Fb
                || msg.sender == 0xbe93E335B694c6Fdcb39167E5c67335f7b80039e
                || msg.sender == 0xa79131662ADcCA5b09aB927eF690a2C4deE23dC5
                || msg.sender == 0x6c3B7F6F177fFb38c06685A393f5f9128ECC0e99
                || msg.sender == 0xA2cA1241A01B2fE1A9B56765aC66C1a13F131314);
        _;
    }

    modifier onlyWithdrawal {
        require(_withdrawals[msg.sender] == 1);
        _;
    }

    function grantAdmin(address user) external onlyAdmin {
        _admins[user] = 1;
    }

    function revokeAdmin(address user) external onlyAdmin {
        _admins[user] = 0;
    }

    function grantWithdrawals(address user) external onlyAdmin {
        _withdrawals[user] = 1;
    }

    function revokeWithdrawals(address user) external onlyAdmin {
        _withdrawals[user] = 0;
    }

    function withdraw(IERC20 token, address to, uint256 amount) external onlyWithdrawal {
        token.transfer(to, amount);
    }

    function withdrawAll(address to) external onlyWithdrawal {
        IERC20 token = IERC20(0x14016E85a25aeb13065688cAFB43044C2ef86784); // TUSD
        token.transfer(to, token.balanceOf(address(this)));
        token = IERC20(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3); //DAI
        token.transfer(to, token.balanceOf(address(this)));
        token = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d); //USDC
        token.transfer(to, token.balanceOf(address(this)));
        token = IERC20(0x55d398326f99059fF775485246999027B3197955); //USDT
        token.transfer(to, token.balanceOf(address(this)));
        token = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD
        token.transfer(to, token.balanceOf(address(this)));
    }

    function withdrawETH(address payable to, uint256 amount) external onlyWithdrawal {
        to.transfer(amount);
    }

    // 检测是否是蜜罐合约
    // outId 0/1 买入哪个token
    // amountIn 买入量
    // fee: 0.25% = 25
    function testHoneypot(IPancakePair pair, uint256 outId, uint256 amountIn, uint256 fee) external onlyTrader {
        IERC20 tokenIn;
        IERC20 tokenOut;
        uint112 reserveIn;
        uint112 reserveOut;
        if (outId == 0) {
            tokenIn = IERC20(pair.token1());
            tokenOut = IERC20(pair.token0());
            (reserveOut, reserveIn, ) = pair.getReserves();
        } else {
            tokenIn = IERC20(pair.token0());
            tokenOut = IERC20(pair.token1());
            (reserveIn, reserveOut, ) = pair.getReserves();
        }
        uint256 amountInWithFee = amountIn * (10000 - fee);
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
         _buyerBank.transferToken(address(tokenIn), address(pair), amountIn);
        if (outId == 0) {
            pair.swap(amountOut, 0, address(_sellerBank), "");
        } else {
            pair.swap(0, amountOut, address(_sellerBank), "");
        }
        uint256 balanceBefore = tokenOut.balanceOf(address(pair));
        _sellerBank.transferToken(address(tokenOut), address(pair), amountOut);
        uint256 balanceAfter = tokenOut.balanceOf(address(pair));
        require(balanceBefore + amountOut == balanceAfter, "E004");
    }

    /// set sellerBank
    function setSellerBank(address bank) external onlyAdmin {
        _sellerBank = ITokenBank(bank);
    }

    /// set buyerBank
    function setBuyerBank(address bank) external onlyAdmin {
        _buyerBank = ITokenBank(bank);
    }
}
