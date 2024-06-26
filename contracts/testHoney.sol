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
    // 如果buyerbank没有tokenIn币，测试时需要将币转给buyerbank
    // 一个pair调用一次即可，任一token作为tokenIN即可
    function testHoneypot(IPancakePair pair, uint256 swapType, uint256 outId, uint256 amountIn, uint256 fee) external onlyTrader {
        // 测试tokenIn转给交易所是否收费
        uint256 amountOut = _swap(pair, swapType, outId, amountIn, fee);
        IERC20 tokenIn;
        IERC20 tokenOut;
        if (outId == 0) {
            tokenIn = IERC20(pair.token1());
            tokenOut = IERC20(pair.token0());
        } else {
            tokenIn = IERC20(pair.token0());
            tokenOut = IERC20(pair.token1());
        }
        // 测试交易所转tokenOut是否收费
        _sellerBank.transferToken(address(tokenOut), address(_buyerBank), amountOut);
        // 测试tokenOut转给交易所是否收费
        amountOut = _swap(pair, swapType, outId ^ 1, amountOut, fee);
        // 测试交易所转tokenIn是否收费
        require(tokenIn.balanceOf(address(_sellerBank)) >= amountOut, "E004");
    }

    function _swap(IPancakePair pair, uint256 swapType, uint256 outId, uint256 amountIn, uint256 fee) private returns (uint256) {
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
            if (swapType == 0) {
                pair.swap(amountOut, 0, address(_sellerBank), "");
            } else {
                IPancakePair2(address(pair)).swap(amountOut, 0, address(_sellerBank));
            }
        } else {
            if (swapType == 0) {
                pair.swap(0, amountOut, address(_sellerBank), "");
            } else {
                IPancakePair2(address(pair)).swap(0, amountOut, address(_sellerBank));
            }
        }
        return amountOut;
    }

    /// set sellerBank
    function setSellerBank(address bank) external onlyAdmin {
        _sellerBank = ITokenBank(bank);
    }

    /// set buyerBank
    function setBuyerBank(address bank) external onlyAdmin {
        _buyerBank = ITokenBank(bank);
    }

    // amountIn: [blocknumber]176[timeStamp]112[amountIn]0
    // pair: [fee]176[type]168[outId]160[pairAddress]0
    function cross(uint256 amountIn, uint256[] calldata pairInfos) external onlyTrader {
        uint256 pairInfo = pairInfos[0] ^ 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
        address pair = address(uint160(pairInfo));
        IERC20 tokenIn;
        uint256 reserveIn;
        uint256 reserveOut;
        uint256 outId = (pairInfo >> 160) & 0xf;
        address recipient = address(this);
        if (outId == 0) {
            tokenIn = IERC20(IPancakePair(pair).token1());
            (reserveOut, reserveIn, ) = IPancakePair(pair).getReserves();
        } else {
            tokenIn = IERC20(IPancakePair(pair).token0());
            (reserveIn, reserveOut, ) = IPancakePair(pair).getReserves();
        }
        uint256 balance0 = tokenIn.balanceOf(address(_buyerBank));
        amountIn &= 0xffffffffffffffffffffffffffff;
        if (amountIn > balance0) {
            amountIn = balance0;
        }
        balance0 = amountIn;
        _buyerBank.transferToken(address(tokenIn), address(pair), amountIn);
        amountIn *= (pairInfo >> 176);
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        if (outId == 0) {
            if (((pairInfo >> 168) & 0xf) == 0) {
                IPancakePair(pair).swap(amountOut, 0, recipient, "");
            } else {
                IPancakePair2(address(pair)).swap(amountOut, 0, recipient);
            }
        } else {
            if (((pairInfo >> 168) & 0xf) == 0) {
                IPancakePair(pair).swap(0, amountOut, recipient, "");
            } else {
                IPancakePair2(pair).swap(0, amountOut, recipient);
            }
        }

        for(uint i = 1; i < pairInfos.length; ++i) {
            pairInfo = pairInfos[i] ^ 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
            pair = address(uint160(pairInfo));
            outId = (pairInfo >> 160) & 0xf;
            if (outId == 0) {
                tokenIn = IERC20(IPancakePair(pair).token1());
                (reserveOut, reserveIn, ) = IPancakePair(pair).getReserves();
            } else {
                tokenIn = IERC20(IPancakePair(pair).token0());
                (reserveIn, reserveOut, ) = IPancakePair(pair).getReserves();
            }
            amountIn = amountOut;
            tokenIn.transfer(address(pair), amountIn);
            amountIn *= (pairInfo >> 176);
            amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            if (i == pairInfos.length - 1) {
                recipient = address(_buyerBank);
            }
            if (outId == 0) {
                if (((pairInfo >> 168) & 0xf) == 0) {
                    IPancakePair(pair).swap(amountOut, 0, recipient, "");
                } else {
                    IPancakePair2(address(pair)).swap(amountOut, 0, recipient);
                }
            } else {
                if (((pairInfo >> 168) & 0xf) == 0) {
                    IPancakePair(pair).swap(0, amountOut, recipient, "");
                } else {
                    IPancakePair2(pair).swap(0, amountOut, recipient);
                }
            }
        }
        require(amountOut > balance0, "E001");
    }

    function testToken(IERC20 token, address pair, uint256 amount) external {
        require(token.balanceOf(msg.sender) >= amount, "E001");
        token.transfer(address(_sellerBank), amount);
        uint256 balanceBefore = token.balanceOf(address(pair));
        _sellerBank.transferToken(address(token), address(pair), amount);
        uint256 balanceAfter = token.balanceOf(address(pair));
        require(balanceBefore + amount == balanceAfter, "E004");
    }
    
    // 测试token transaction fee
    // pair转amount的币给该地址（可以转1/4 balance）
    // 返回pair转给用户的费率及用户转给pair的费率
    function getTokenFee(IERC20 token, address pair, uint256 amount) external returns (uint256 fromPair, uint256 toPair) {
        uint256 amountIn = token.balanceOf(address(this));
        fromPair = (amount - amountIn) * 1000000 / amount;
        uint256 balanceBefore = token.balanceOf(address(pair));
        token.transfer(address(pair), amountIn);
        uint256 balanceAfter = token.balanceOf(address(pair));
        uint256 amountOut = balanceAfter - balanceBefore;
        toPair = (amountIn - amountOut) * 1000000 / amountIn;
    }
}
