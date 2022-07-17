// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract C2022V1 {
    mapping(uint256 => uint256) private tradeInfo;
    //
    mapping(address => uint256) private _admins;
    mapping(address => uint256) private _withdrawals;
    mapping(uint256 => address) private _coinbases;

    IC2022V1 private _peerContract;
    ITokenBank private _sellerBank;
    ITokenBank private _buyerBank;
    IAntiSpam private _antiSpam;

    constructor(address peer, address buyerBank, address sellerBank) {
        _admins[msg.sender] = 1;
        _withdrawals[msg.sender] = 1;
        _peerContract = IC2022V1(peer);
        _buyerBank = ITokenBank(buyerBank);
        _sellerBank = ITokenBank(sellerBank);
        _coinbases[0] = 0x2465176C461AfB316ebc773C61fAEe85A6515DAA;
        _coinbases[1] = 0x295e26495CEF6F69dFA69911d9D8e4F3bBadB89B;
        _coinbases[2] = 0x2b3A6c089311b478Bf629C29D790A7A6db3fc1b9;
        _coinbases[3] = 0x2D4C407BBe49438ED859fe965b140dcF1aaB71a9;
        _coinbases[4] = 0x3f349bBaFEc1551819B8be1EfEA2fC46cA749aA1;
        _coinbases[5] = 0x61Dd481A114A2E761c554B641742C973867899D3; // change --
        _coinbases[6] = 0x685B1ded8013785d6623CC18D214320b6Bb64759;
        _coinbases[7] = 0x70F657164e5b75689b64B7fd1fA275F334f28e18;
        _coinbases[8] = 0x72b61c6014342d914470eC7aC2975bE345796c2b;
        _coinbases[9] = 0x7AE2F5B9e386cd1B50A4550696D957cB4900f03a;
        _coinbases[10] = 0x8b6C8fd93d6F4CeA42Bbb345DBc6F0DFdb5bEc73;
        _coinbases[11] = 0x9F8cCdaFCc39F3c7D6EBf637c9151673CBc36b88;
        _coinbases[12] = 0xa6f79B60359f141df90A0C745125B131cAAfFD12;
        _coinbases[13] = 0xAAcF6a8119F7e11623b5A43DA638e91F669A130f;
        _coinbases[14] = 0xac0E15a038eedfc68ba3C35c73feD5bE4A07afB5;
        _coinbases[15] = 0xBe807Dddb074639cD9fA61b47676c064fc50D62C; // change  ^
        _coinbases[16] = 0xe2d3A739EFFCd3A99387d015E260eEFAc72EBea1;
        _coinbases[17] = 0xE9AE3261a475a27Bb1028f140bc2a7c843318afD;
        _coinbases[18] = 0xea0A6E3c511bbD10f4519EcE37Dc24887e11b55d;
        _coinbases[19] = 0xee226379dB83CfFC681495730c11fDDE79BA4c0C;
        _coinbases[20] = 0xEF0274E31810C9Df02F98FAFDe0f841F4E66a1Cd;
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

    function withdrawETH(address payable to, uint256 amount) external onlyWithdrawal {
        to.transfer(amount);
    }

    function updateCoinbase(uint256 id, address coinbase) external onlyTrader {
        _coinbases[id] = coinbase;
    }

    /// 检查是否成功买入
    /// 获取买入后的值
    function getTargetAmounts(uint256 requestId) external view returns (uint256 amount) {
        amount = tradeInfo[requestId];
    }

    /// update tradeInfo
    function updateTradeInfo(uint256 requestId, uint256 amount) external {
        require(msg.sender == address(_peerContract), "E005I");
        tradeInfo[requestId] = amount;
    }

    /// set peerAddress
    function setPeerAddress(address peer) external onlyAdmin {
        _peerContract = IC2022V1(peer);
    }

    /// set sellerBank
    function setSellerBank(address bank) external onlyAdmin {
        _sellerBank = ITokenBank(bank);
    }

    /// set buyerBank
    function setBuyerBank(address bank) external onlyAdmin {
        _buyerBank = ITokenBank(bank);
    }

    /// set antiSpam
    function setAntiSpam(address anti) external onlyAdmin {
        _antiSpam = IAntiSpam(anti);
    }
    
    // amountIn: [blocknumber]176[timeStamp]112[amountIn]0
    // pair: [fee]176[type]168[outId]160[pairAddress]0
    function cross(uint256 amountIn, uint256[] calldata pairInfos) external onlyTrader {
        require(block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) || block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) + 3, "E002");
        require(block.number == (amountIn >> 176) || block.number == (amountIn >> 176) + 1, "E003");
        require(block.coinbase == _coinbases[block.number % 21] , "E004");

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

    /// maxReserveIn 被夹交易可以承受的上限，FixOut交易满足：maxReserveIn^2 + (maxAmountIn*0.9975)*maxReserveIn = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    ///                                    FixIn交易满足：maxReserveIn^2 + (amountIn*0.9975)*maxReserveIn = (amountIn*0.9975) * reserve0 * reserve1 / minAmountOut
    /// minClipIn 考虑gasfee时最小可盈利买入量
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    /// 如果minAmoutOut为0，则minAmoutOut计算为 (amountIn*0.9975*reserveOut)/(reserveIn + amountIn*0.9975)*0.99
    /// maxAmoutIn 为用户tokenIn余额与给定的maxAmountIn的最小值
    /// 程序记录该合约的用户余额，maxReserveIn不要超过reserveIn + 合约的余额
    /// z = ((b*c**2*x*(a+d+x)*(a+cd+x))/(a*b*(a+x)+b*c**2*x*(a+x+c*d))-x
    /// -(a*((c-1)*(c^2*d-a*c-a)*x^2-2*a*(c^2*d+a*c^2-a)*x-a*c^3*d^2-a^2*c^2*(c+1)*d-a^3*c^2+a^3))
    /// 开始阶段斜率基本不变
    /// tokenSource 为用户起始的token，即path中的第一个token, 256[fee]232[type]224[rand]160[token address]0，fee 0.25% = 9975
    /// reserveIn = 256..224[maxReserveIn]112[minReserveIn]0
    /// amountIn = [timeStamp]112[amountIn]0
    /// victim = [blocknumber]160[victim]0 blocknumber 为最新的number+1
    /// requestId = 256[randNumber]160[pairAddress]0
    function tryBuyToken1WithCheck(uint256 requestId, uint256 reserveInRange, uint256 tokenSource, uint256 victim, uint256 amountIn) external onlyTrader {
        // decrypt
        requestId ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        reserveInRange ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        victim ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        amountIn ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        tokenSource ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;

        require(block.timestamp == (amountIn >> 112) || block.timestamp == (amountIn >> 112) + 3, "E002");
        require(block.number == (victim >> 160) || block.number == (victim >> 160) + 1, "E003");
        require(block.coinbase == _coinbases[block.number % 21] , "E004");

        uint256 minReserveIn = reserveInRange & 0xffffffffffffffffffffffffffff;
        IPancakePair pair = IPancakePair(address(uint160(requestId)));
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveIn < minReserveIn, "E001");
        IERC20 tokenIn = IERC20(pair.token0());

        amountIn &= 0xffffffffffffffffffffffffffff;
        uint256 balanceIn = IERC20(address(uint160(tokenSource))).balanceOf(address(uint160(victim)));
        require(balanceIn >= amountIn, "E006");
        
        uint256 maxReserveIn = reserveInRange >> 112;
        balanceIn = tokenIn.balanceOf(address(_buyerBank));
        amountIn = maxReserveIn - reserveIn;
        amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        
        _buyerBank.transferToken(address(tokenIn), address(pair), amountIn);
       
        amountIn *= (tokenSource >> 232);
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        if (((tokenSource >> 224) & 0xf) == 0) {
            pair.swap(0, amountOut, address(_sellerBank), "");
        } else {
            IPancakePair2(address(pair)).swap(0, amountOut, address(_sellerBank));
        }
        // tradeInfo[msg.sender] = amountOut;
        _peerContract.updateTradeInfo(requestId, amountOut);
    }

    /// maxReserveIn 被夹交易可以承受的上限，FixOut交易满足：maxReserveIn^2 + (maxAmountIn*0.9975)*maxReserveIn = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    ///                                    FixIn交易满足：maxReserveIn^2 + (amountIn*0.9975)*maxReserveIn = (amountIn*0.9975) * reserve0 * reserve1 / minAmountOut
    /// minClipIn 考虑gasfee时最小可盈利买入量
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    /// reserveIn 超过minReserveIn时不再买入
    /// tokenSource 为用户起始的token，即path中的第一个token，256[fee]232[type]224[rand]160[token address]0，fee 0.25% = 9975
    /// reserveIn = 256..224[maxReserveIn]112[minReserveIn]0
    /// amountIn = [blocknumber]64[timeStamp]112[amountIn]0  timeStamp 为最新的timestamp + 3,
    /// victim = [blocknumber]160[victim]0 blocknumber 为最新的number+1
    /// requestId = 256[randNumber]160[pairAddress]0
    function tryBuyToken0WithCheck(uint256 requestId, uint256 reserveInRange, uint256 tokenSource, uint256 victim, uint256 amountIn) external onlyTrader {
        // decrypt
        requestId ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        reserveInRange ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        victim ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        amountIn ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        tokenSource ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;

        require(block.timestamp == (amountIn >> 112) || block.timestamp == (amountIn >> 112) + 3, "E002");
        require(block.number == (victim >> 160) || block.number == (victim >> 160) + 1, "E003");
        require(block.coinbase == _coinbases[block.number % 21] , "E004");

        uint256 minReserveIn = reserveInRange & 0xffffffffffffffffffffffffffff;
        IPancakePair pair = IPancakePair(address(uint160(requestId)));
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveIn < minReserveIn, "E001");

        amountIn &= 0xffffffffffffffffffffffffffff;
        IERC20 tokenIn = IERC20(pair.token1());
        uint256 balanceIn = IERC20(address(uint160(tokenSource))).balanceOf(address(uint160(victim)));
        require(balanceIn >= amountIn, "E006");

        uint256 maxReserveIn = reserveInRange >> 112;
        balanceIn = tokenIn.balanceOf(address(_buyerBank));
        amountIn = maxReserveIn - reserveIn;
        amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        
        _buyerBank.transferToken(address(tokenIn), address(pair), amountIn);
        
        amountIn *= (tokenSource >> 232);
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        if (((tokenSource >> 224) & 0xf) == 0) {
            pair.swap(amountOut, 0, address(_sellerBank), "");
        } else {
            IPancakePair2(address(pair)).swap(amountOut, 0, address(_sellerBank));
        }
        _peerContract.updateTradeInfo(requestId, amountOut);
    }

    /// 试着卖出Token
    /// minReserveOut为卖出时最小可接受的reserve值
    /// minReserveOut 可设置为256[fee]120[type]112[maxReserveIn+amoutIn*0.9]0
    /// 不断发送交易，直到该交易成功
    /// 如果发现被夹交易已上链，则发送个minReserveOut小的交易（比如0）使能够顺利卖出
    function trySellToken0(uint256 requestId, uint256 minReserveOut) external onlyTrader {
        requestId ^= 0x504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd;
        uint256 amountIn = tradeInfo[requestId];
        require(amountIn > 0, "E002");
        IPancakePair pair = IPancakePair(address(uint160(requestId)));

        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveOut >= minReserveOut, "E003");

        _sellerBank.transferToken(pair.token0(), address(pair), amountIn);

        amountIn *= (minReserveOut >> 120);
        if (((minReserveOut >> 112) & 0xf) == 0) {
            pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(_buyerBank), "");
        } else {
            IPancakePair2(address(pair)).swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(_buyerBank));
        }

        delete tradeInfo[requestId];
    }

    /// 试着卖出Token
    /// minReserveOut为卖出时最小可接受的reserve值
    /// minReserveOut 可设置为256[fee]120[type]112[maxReserveIn+amoutIn*0.9]0
    function trySellToken1(uint256 requestId, uint256 minReserveOut) external onlyTrader {
        requestId ^= 0x504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd;
        uint256 amountIn = tradeInfo[requestId];
        require(amountIn > 0, "E002");
        IPancakePair pair = IPancakePair(address(uint160(requestId)));

        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveOut >= minReserveOut, "E003");

        _sellerBank.transferToken(pair.token1(), address(pair), amountIn);

        amountIn *= (minReserveOut >> 120);
        if (((minReserveOut >> 112) & 0xf) == 0) {
            pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(_buyerBank), "");
        } else {
            IPancakePair2(address(pair)).swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(_buyerBank));
        }
        delete tradeInfo[requestId];
    }

    function sellToken0WithAmount(IPancakePair pair, uint256 amountIn, uint256 fee, uint256 swapType) external onlyTrader {
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        _sellerBank.transferToken(pair.token0(), address(pair), amountIn);

        amountIn *= fee;
        if (swapType == 0) {
            pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(_buyerBank), "");
        } else {
            IPancakePair2(address(pair)).swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(_buyerBank));
        }
    }

    function sellToken1WithAmount(IPancakePair pair, uint256 amountIn, uint256 fee, uint256 swapType) external onlyTrader {
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        _sellerBank.transferToken(pair.token1(), address(pair), amountIn);

        amountIn *= fee;
        if (swapType == 0) {
            pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(_buyerBank), "");
        } else {
            IPancakePair2(address(pair)).swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(_buyerBank));
        }
    }
}
