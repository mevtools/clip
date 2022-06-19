// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./iclip.sol";

contract C2022V1 is AccessControl {
    bytes32 public constant TRADE_ROLE = keccak256("TRADE_ROLE");
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");
    struct TradeInfo {
        uint32 id;
        uint112 amount0;
        uint112 amount1;
    }
    mapping(address => TradeInfo) private tradeInfo;

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRADE_ROLE, msg.sender);
        _grantRole(WITHDRAW_ROLE, msg.sender);
    }

    function withdraw(IERC20 token, address to, uint256 amount) public onlyRole(WITHDRAW_ROLE) {
        token.transfer(to, amount);
    }

    function withdrawETH(address payable to, uint256 amount) public onlyRole(WITHDRAW_ROLE) {
        to.transfer(amount);
    }

    function updateId(uint256 id) public onlyRole(TRADE_ROLE) {
        tradeInfo[msg.sender].id = uint32(id);
    }

    /// 检测是否是蜜罐合约
    /// outId 0/1 买入哪个token
    /// amountIn 买入量
    function testHoneypot(IPancakePair pair, uint256 outId, uint256 amountIn) public onlyRole(TRADE_ROLE) {
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
    function getTargetAmounts() external view returns (uint256 amount0, uint256 amount1) {
        TradeInfo memory info = tradeInfo[msg.sender];
        amount0 = info.amount0;
        amount1 = info.amount1;
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
    function tryBuyToken1(IPancakePair pair, uint256 deadline, uint256 maxReserveIn, uint256 minClipIn, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        TradeInfo storage info = tradeInfo[msg.sender];
        if (info.id != id || block.number <= height) {
            while(true) {}
        }
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveIn < maxReserveIn && block.number <= deadline, "E001");
        IERC20 tokenIn = IERC20(pair.token0());
        uint256 balanceIn = tokenIn.balanceOf(address(this));
        uint256 amountIn = maxReserveIn - reserveIn;
        amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        require(amountIn > minClipIn, "E002");
        
        tokenIn.transfer(address(pair), amountIn);
       
        amountIn *= 9975;
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        pair.swap(0, amountOut, address(this), "");
       
        info.amount1 = uint112(amountOut);
    }

    /// maxReserveIn 被夹交易可以承受的上限，FixOut交易满足：maxReserveIn^2 + (maxAmountIn*0.9975)*maxReserveIn = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    ///                                    FixIn交易满足：maxReserveIn^2 + (amountIn*0.9975)*maxReserveIn = (amountIn*0.9975) * reserve0 * reserve1 / minAmountOut
    /// minClipIn 考虑gasfee时最小可盈利买入量
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    function tryBuyToken0(IPancakePair pair, uint256 deadline, uint256 maxReserveIn, uint256 minClipIn, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        TradeInfo storage info = tradeInfo[msg.sender];
        if (info.id != id || block.number <= height) {
            while(true) {}
        }
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveIn < maxReserveIn && block.number <= deadline, "E001");
        
        IERC20 tokenIn = IERC20(pair.token1());
        uint256 balanceIn = tokenIn.balanceOf(address(this));
        uint256 amountIn = maxReserveIn - reserveIn;
        amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        require(amountIn > minClipIn, "E002");
        
        tokenIn.transfer(address(pair), amountIn);
        
        amountIn *= 9975;
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
        pair.swap(amountOut, 0, address(this), "");
        
        info.amount0 = uint112(amountOut);
    }

    /// 试着卖出Token
    /// minReserveIn为卖出时最小可接受的reserve值
    /// minReserveIn 可设置为maxReserveIn+amoutIn*0.9
    /// 不断发送交易，直到该交易成功
    /// 如果发现被夹交易已上链，则发送个minReserveIn小的交易（比如0）使能够顺利卖出
    function trySellToken0(IPancakePair pair, uint256 deadline, uint256 minReserveIn, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        TradeInfo storage info = tradeInfo[msg.sender];
        if (info.id != id || block.number <= height) {
            while(true) {}
        }
        require(info.amount0 > 0, "E002");
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveIn >= minReserveIn || block.number > deadline, "E003");
        uint256 amountInWithFee = info.amount0 * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        IERC20 tokenIn = IERC20(pair.token0());
        tokenIn.transfer(address(pair), info.amount0);
        pair.swap(0, amountOut, address(this), "");
        info.amount0 = 0;
    }

    /// 试着卖出Token
    /// minReserveIn为卖出时最小可接受的reserve值
    function trySellToken1(IPancakePair pair, uint256 deadline, uint256 minReserveIn, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        TradeInfo storage info = tradeInfo[msg.sender];
        if (info.id != id || block.number <= height) {
            while(true) {}
        }
        require(info.amount1 > 0, "E002");
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveIn >= minReserveIn || block.number > deadline, "E003");
        uint256 amountInWithFee = info.amount1 * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        IERC20 tokenIn = IERC20(pair.token1());
        tokenIn.transfer(address(pair), info.amount1);
        pair.swap(amountOut, 0, address(this), "");
        info.amount1 = 0;
    }
}