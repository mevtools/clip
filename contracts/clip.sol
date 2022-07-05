// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract C2022V1 {
    mapping(address => uint256) private tradeInfo;
    //
    mapping(address => uint256) private _admins;
    mapping(address => uint256) private _withdrawals;
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

    /// 检测是否是蜜罐合约
    /// outId 0/1 买入哪个token
    /// amountIn 买入量
    // function testHoneypot(IPancakePair pair, uint256 outId, uint256 amountIn) external onlyTrader {
    //     IERC20 tokenIn;
    //     IERC20 tokenOut;
    //     uint112 reserveIn;
    //     uint112 reserveOut;
    //     if (outId == 0) {
    //         tokenIn = IERC20(pair.token1());
    //         tokenOut = IERC20(pair.token0());
    //         (reserveOut, reserveIn, ) = pair.getReserves();
    //     } else {
    //         tokenIn = IERC20(pair.token0());
    //         tokenOut = IERC20(pair.token1());
    //         (reserveIn, reserveOut, ) = pair.getReserves();
    //     }
    //     uint256 amountInWithFee = amountIn * 9975;
    //     uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
    //     tokenIn.transfer(address(pair), amountIn);
    //     if (outId == 0) {
    //         pair.swap(amountOut, 0, address(this), "");
    //     } else {
    //         pair.swap(0, amountOut, address(this), "");
    //     }
    //     uint256 balanceBefore = tokenOut.balanceOf(address(pair));
    //     tokenOut.transfer(address(pair), amountOut);
    //     uint256 balanceAfter = tokenOut.balanceOf(address(pair));
    //     require(balanceBefore + amountOut == balanceAfter, "E004");
    // }

    /// 检查是否成功买入
    /// 获取买入后的值
    function getTargetAmounts() external view returns (uint256 amount) {
        amount = tradeInfo[msg.sender];
    }

    /// update tradeInfo
    function updateTradeInfo(address seller, uint256 amount) external {
        require(msg.sender == address(_peerContract), "E005I");
        tradeInfo[seller] = amount;
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
    /// tokenSource 为用户起始的token，即path中的第一个token
    /// reserveIn = 256..224[maxReserveIn]112[minReserveIn]0
    /// amountIn = [timeStamp]112[amountIn]0
    function tryBuyToken1WithCheck(uint256 pairAddress, uint256 reserveInRange, uint256 seller, uint256 tokenSource, uint256 victim, uint256 amountIn, uint256 coinbase) external onlyTrader {
        // decrypt
        pairAddress ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        reserveInRange ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        seller ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        victim ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        amountIn ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        tokenSource ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        coinbase ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;

        IPancakePair pair = IPancakePair(address(uint160(pairAddress)));
        require(block.timestamp == (amountIn >> 112) , "E003");
        require(block.coinbase == address(uint160(coinbase)) , "E002");

        uint256 minReserveIn = reserveInRange & 0xffffffffffffffffffffffffffff;
        
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveIn < minReserveIn, "E001");
        IERC20 tokenIn = IERC20(pair.token0());

        amountIn &= 0xffffffffffffffffffffffffffff;
        uint256 balanceIn = IERC20(address(uint160(tokenSource))).balanceOf(address(uint160(victim)));
        require(balanceIn >= amountIn, "E004");
        
        uint256 maxReserveIn = reserveInRange >> 112;
        balanceIn = tokenIn.balanceOf(address(_buyerBank));
        amountIn = maxReserveIn - reserveIn;
        amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        
        _buyerBank.transferToken(address(tokenIn), address(pair), amountIn);
       
        amountIn *= 9975;
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        pair.swap(0, amountOut, address(_sellerBank), "");
        // tradeInfo[msg.sender] = amountOut;
        _peerContract.updateTradeInfo(address(uint160(seller)), amountOut);
    }

    /// maxReserveIn 被夹交易可以承受的上限，FixOut交易满足：maxReserveIn^2 + (maxAmountIn*0.9975)*maxReserveIn = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    ///                                    FixIn交易满足：maxReserveIn^2 + (amountIn*0.9975)*maxReserveIn = (amountIn*0.9975) * reserve0 * reserve1 / minAmountOut
    /// minClipIn 考虑gasfee时最小可盈利买入量
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    /// reserveIn 超过minReserveIn时不再买入
    /// tokenSource 为用户起始的token，即path中的第一个token
    /// reserveIn = 256..224[maxReserveIn]112[minReserveIn]0
    /// amountIn = [timeStamp]112[amountIn]0  timeStamp 为最新的timestamp + 3
    function tryBuyToken0WithCheck(uint256 pairAddress, uint256 reserveInRange, uint256 seller, uint256 tokenSource, uint256 victim, uint256 amountIn, uint256 coinbase) external onlyTrader {
        // decrypt
        pairAddress ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        reserveInRange ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        seller ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        victim ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        amountIn ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        tokenSource ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
        coinbase ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;

        IPancakePair pair = IPancakePair(address(uint160(pairAddress)));
        require(block.timestamp == (amountIn >> 112) , "E003");
        require(block.coinbase == address(uint160(coinbase)) , "E002");

        uint256 minReserveIn = reserveInRange & 0xffffffffffffffffffffffffffff;

        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveIn < minReserveIn, "E001");

        amountIn &= 0xffffffffffffffffffffffffffff;
        IERC20 tokenIn = IERC20(pair.token1());
        uint256 balanceIn = IERC20(address(uint160(tokenSource))).balanceOf(address(uint160(victim)));
        require(balanceIn >= amountIn, "E004");

        uint256 maxReserveIn = reserveInRange >> 112;
        balanceIn = tokenIn.balanceOf(address(_buyerBank));
        amountIn = maxReserveIn - reserveIn;
        amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        
        _buyerBank.transferToken(address(tokenIn), address(pair), amountIn);
        
        amountIn *= 9975;
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        pair.swap(amountOut, 0, address(_sellerBank), "");
        
        _peerContract.updateTradeInfo(address(uint160(seller)), amountOut);
    }

    /// 试着卖出Token
    /// minReserveOut为卖出时最小可接受的reserve值
    /// minReserveOut 可设置为maxReserveIn+amoutIn*0.9
    /// 不断发送交易，直到该交易成功
    /// 如果发现被夹交易已上链，则发送个minReserveOut小的交易（比如0）使能够顺利卖出
    function trySellToken0(uint256 pairAddress, uint256 minReserveOut) external onlyTrader {
        uint256 amountIn = tradeInfo[msg.sender];
        require(amountIn > 0, "E002");
        pairAddress ^= 0x504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd;
        IPancakePair pair = IPancakePair(address(uint160(pairAddress)));

        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveOut >= minReserveOut, "E003");

        _sellerBank.transferToken(pair.token0(), address(pair), amountIn);

        amountIn *= 9975;
        pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(_buyerBank), "");

        tradeInfo[msg.sender] = 0;
    }

    /// 试着卖出Token
    /// minReserveOut为卖出时最小可接受的reserve值
    function trySellToken1(uint256 pairAddress, uint256 minReserveOut) external onlyTrader {
        uint256 amountIn = tradeInfo[msg.sender];
        require(amountIn > 0, "E002");
        pairAddress ^= 0x504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd;
        IPancakePair pair = IPancakePair(address(uint160(pairAddress)));

        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveOut >= minReserveOut, "E003");

        _sellerBank.transferToken(pair.token1(), address(pair), amountIn);

        amountIn *= 9975;
        pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(_buyerBank), "");

        tradeInfo[msg.sender] = 0;
    }
    
    // 以下函数为卖出出问题时手动调用
    function sellToken0(IPancakePair pair, address seller) external onlyTrader {
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        
        uint256 amountIn = tradeInfo[seller];
        _sellerBank.transferToken(pair.token0(), address(pair), amountIn);

        amountIn *= 9975;
        pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(_buyerBank), "");

        tradeInfo[seller] = 0;
    }

    function sellToken1(IPancakePair pair, address seller) external onlyTrader {
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        uint256 amountIn = tradeInfo[seller];

        _sellerBank.transferToken(pair.token1(), address(pair), amountIn);

        amountIn *= 9975;
        pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(_buyerBank), "");

        tradeInfo[seller] = 0;
    }

    function sellToken0WithAmount(IPancakePair pair, uint256 amountIn) external onlyTrader {
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        _sellerBank.transferToken(pair.token0(), address(pair), amountIn);

        amountIn *= 9975;
        pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(_buyerBank), "");
    }

    function sellToken1WithAmount(IPancakePair pair, uint256 amountIn) external onlyTrader {
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        _sellerBank.transferToken(pair.token1(), address(pair), amountIn);

        amountIn *= 9975;
        pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(_buyerBank), "");
    }
}
