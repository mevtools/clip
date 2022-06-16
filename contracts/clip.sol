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

    constructor() {
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
        pair.swap(0, amountOut, address(this), "");
        uint256 balanceBefore = tokenOut.balanceOf(address(pair));
        tokenOut.transfer(address(pair), amountOut);
        uint256 balanceAfter = tokenOut.balanceOf(address(pair));
        require(balanceBefore + amountOut == balanceAfter, "E004");
    }

    /// maxReserveIn 被夹交易可以承受的上限，FixOut交易满足：maxReserveIn^2 + (maxAmountIn*0.9975)*maxReserveIn = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    ///                                    FixIn交易满足：maxReserveIn^2 + (amountIn*0.9975)*maxReserveIn = (amountIn*0.9975) * reserve0 * reserve1 / minAmountOut
    /// minReserveIn 最小盈利的reserve，当reserve涨到这个点时就无法盈利了，计算盈利时要考虑交易手续费0.25%
    /// minReserveIn FixOut交易满足：amountOut*minReserveIn^2 + amountOut*0.9975*(maxAmountIn - c)*minReserveIn + k*0.9975*(c-maxAmountIn) = 0
    ///              FixIn交易满足：minAmountOut*minReserveIn^2 + minAmountOut*0.9975*(amountIn - c)*minReserveIn + k*0.9975*(c-amountIn) = 0
    /// c为成本（需将交易手续费及gas费计算在内，手续费为(maxReserveIn-reserve) * 0.005），k=reserveIn*reserveOut
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    function tryBuyToken1(IPancakePair pair, uint256 deadline, uint256 maxReserveIn, uint256 minReserveIn, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        TradeInfo storage info = tradeInfo[msg.sender];
        if (info.id != id || block.number <= height) {
            while(true) {}
        }
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveOut < minReserveIn && block.number <= deadline, "E001");
        IERC20 tokenIn = IERC20(pair.token0());
        // uint256 balanceIn = tokenIn.balanceOf(address(this));
        uint256 amountIn = maxReserveIn - reserveIn;
        // amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        uint256 amountInWithFee = amountIn * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        
        tokenIn.transfer(address(pair), amountIn);
        pair.swap(0, amountOut, address(this), "");
        info.amount1 = uint112(amountOut);
    }

    /// maxReserveIn 被夹交易可以承受的上限，FixOut交易满足：maxReserveIn^2 + (maxAmountIn*0.9975)*maxReserveIn = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    ///                                    FixIn交易满足：maxReserveIn^2 + (amountIn*0.9975)*maxReserveIn = (amountIn*0.9975) * reserve0 * reserve1 / minAmountOut
    /// minReserveIn 最小盈利的reserve，当reserve涨到这个点时就无法盈利了，计算盈利时要考虑交易手续费0.25%
    /// minReserveIn FixOut交易满足：amountOut*minReserveIn^2 + amountOut*0.9975*(maxAmountIn - c)*minReserveIn + k*0.9975*(c-maxAmountIn) = 0
    ///              FixIn交易满足：minAmountOut*minReserveIn^2 + minAmountOut*0.9975*(amountIn - c)*minReserveIn + k*0.9975*(c-amountIn) = 0
    /// c为成本（需将交易手续费及gas费计算在内，手续费为(maxReserveIn-reserve) * 0.005），k=reserveIn*reserveOut
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    function tryBuyToken0(IPancakePair pair, uint256 deadline, uint256 maxReserveIn, uint256 minReserveIn, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        TradeInfo storage info = tradeInfo[msg.sender];
        if (info.id != id || block.number <= height) {
            while(true) {}
        }
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveOut < minReserveIn && block.number <= deadline, "E001");
        
        IERC20 tokenIn = IERC20(pair.token1());
        // uint256 balanceIn = tokenIn.balanceOf(address(this));
        uint256 amountIn = maxReserveIn - reserveIn;
        // amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        uint256 amountInWithFee = amountIn * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        
        tokenIn.transfer(address(pair), amountIn);
        pair.swap(amountOut, 0, address(this), "");
        info.amount0 = uint112(amountOut);
    }

    /// 试着卖出Token
    /// minReserveIn为卖出时最小可接受的reserve值
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