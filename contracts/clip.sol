// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract C2022V1 {
    mapping(address => uint256) private tradeInfo;
    //
    mapping(address => uint256) private _admins;
    mapping(address => uint256) private _traders;
    mapping(address => uint256) private _withdrawals;

    constructor(address admin) {
        _admins[msg.sender] = 1;
        _admins[admin] = 1;
        _traders[msg.sender] = 1;
        _withdrawals[msg.sender] = 1;
    }

    modifier onlyAdmin {
        require(_admins[msg.sender] == 1);
        _;
    }

    modifier onlyTrader {
        require(_traders[msg.sender] == 1);
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

    function grantTaders(address user) external onlyAdmin {
        _traders[user] = 1;
    }

    function revokeTraders(address user) external onlyAdmin {
        _traders[user] = 0;
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

    // function updateId(uint256 id) public onlyRole(TRADE_ROLE) {
    //     tradeInfo[msg.sender].id = uint32(id);
    // }

    /// 检测是否是蜜罐合约
    /// outId 0/1 买入哪个token
    /// amountIn 买入量
    function testHoneypot(IPancakePair pair, uint256 outId, uint256 amountIn) external onlyTrader {
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
        uint256 amountInWithFee = amountIn * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        tokenIn.transfer(address(pair), amountIn);
        if (outId == 0) {
            pair.swap(amountOut, 0, address(this), "");
        } else {
            pair.swap(0, amountOut, address(this), "");
        }
        uint256 balanceBefore = tokenOut.balanceOf(address(pair));
        tokenOut.transfer(address(pair), amountOut);
        uint256 balanceAfter = tokenOut.balanceOf(address(pair));
        require(balanceBefore + amountOut == balanceAfter, "E004");
    }

    /// 检查是否成功买入
    /// 获取买入后的值
    function getTargetAmounts() external view returns (uint256 amount) {
        amount= tradeInfo[msg.sender];
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
    function tryBuyToken1(IPancakePair pair, uint256 maxReserveIn, uint256 minClipIn) external onlyTrader {
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveIn < maxReserveIn, "E001");
        IERC20 tokenIn = IERC20(pair.token0());
        uint256 balanceIn = tokenIn.balanceOf(address(this));
        uint256 amountIn = maxReserveIn - reserveIn;
        amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        require(amountIn > minClipIn, "E002");
        
        tokenIn.transfer(address(pair), amountIn);
       
        amountIn *= 9975;
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        pair.swap(0, amountOut, address(this), "");
        tradeInfo[msg.sender] = amountOut;
    }

    /// maxReserveIn 被夹交易可以承受的上限，FixOut交易满足：maxReserveIn^2 + (maxAmountIn*0.9975)*maxReserveIn = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    ///                                    FixIn交易满足：maxReserveIn^2 + (amountIn*0.9975)*maxReserveIn = (amountIn*0.9975) * reserve0 * reserve1 / minAmountOut
    /// minClipIn 考虑gasfee时最小可盈利买入量
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    function tryBuyToken0(IPancakePair pair, uint256 maxReserveIn, uint256 minClipIn) external onlyTrader {
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveIn < maxReserveIn, "E001");
        
        IERC20 tokenIn = IERC20(pair.token1());
        uint256 balanceIn = tokenIn.balanceOf(address(this));
        uint256 amountIn = maxReserveIn - reserveIn;
        amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        require(amountIn > minClipIn, "E002");
        
        tokenIn.transfer(address(pair), amountIn);
        
        amountIn *= 9975;
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        pair.swap(amountOut, 0, address(this), "");
        
        tradeInfo[msg.sender] = amountOut;
    }

    /// 试着卖出Token
    /// minReserveIn为卖出时最小可接受的reserve值
    /// minReserveIn 可设置为maxReserveIn+amoutIn*0.9
    /// 不断发送交易，直到该交易成功
    /// 如果发现被夹交易已上链，则发送个minReserveIn小的交易（比如0）使能够顺利卖出
    function trySellToken0(IPancakePair pair, uint256 minReserveIn) external onlyTrader {
        require(tradeInfo[msg.sender] > 0, "E002");

        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveIn >= minReserveIn, "E003");

        uint256 amountIn = tradeInfo[msg.sender];
        IERC20(pair.token0()).transfer(address(pair), amountIn);

        amountIn *= 9975;
        pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(this), "");

        tradeInfo[msg.sender] = 0;
    }

    /// 试着卖出Token
    /// minReserveIn为卖出时最小可接受的reserve值
    function trySellToken1(IPancakePair pair, uint256 minReserveIn) external onlyTrader {
        require(tradeInfo[msg.sender] > 0, "E002");

        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveIn >= minReserveIn, "E003");

        uint256 amountIn = tradeInfo[msg.sender];
        IERC20(pair.token1()).transfer(address(pair), amountIn);

        amountIn *= 9975;
        pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(this), "");

        tradeInfo[msg.sender] = 0;
    }
}