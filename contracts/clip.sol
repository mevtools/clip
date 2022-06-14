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
    mapping(address => TradeInfo) tradeInfo;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRADE_ROLE, msg.sender);
        _grantRole(WITHDRAW_ROLE, msg.sender);
    }

    function withdraw(IERC20 token, address to, uint256 amount) public onlyRole(WITHDRAW_ROLE) {
        token.transfer(to, amount);
    }

    function withdrawETH(address to, uint256 amount) public onlyRole(WITHDRAW_ROLE) {
        to.transfer(amount);
    }

    /// maxReserve 被夹交易可以承受的上限，FixOut交易满足：maxReserve^2 + (maxAmountIn*0.9975)*maxReserve = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    /// FixIn交易满足：maxReserve^2 + (amountIn*0.9975)*maxReserve = (amountIn*0.9975) * reserve0 * reserve1 / maxAmountOut
    /// minReserve 最小盈利的reserve，当reserve涨到这个点时就无法盈利了，计算盈利时要考虑交易手续费0.25%
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    function tryBuyToken1(IPancakePair pair, uint256 deadline, uint256 maxReserve, uint256 minReserve, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        if (info.id != id || block.number <= height) {
            while(1);
        }
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveOut < minReserve && block.number <= deadline, "E001");
        TradeInfo storage info = tradeInfo[msg.sender];
        IERC20 tokenIn = pair.token0();
        // uint256 balanceIn = tokenIn.balanceOf(address(this));
        uint256 amountIn = maxReserve - reserveIn;
        // amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        uint256 amountInWithFee = amountIn * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        
        tokenIn.transfer(pair, amountIn);
        pair.swap(0, amountOut, address(this), bytes(0));
        info.amount1 = amountOut;
    }

    /// maxReserve 被夹交易可以承受的上限，满足：maxReserve^2 + (maxAmountIn*0.9975)*maxReserve = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    /// minReserve 最小盈利的reserve，当reserve涨到这个点时就无法盈利了，计算盈利时要考虑交易手续费0.25%
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    function tryBuyToken0(IPancakePair pair, uint256 deadline, uint256 maxReserve, uint256 minReserve, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        if (info.id != id || block.number <= height) {
            while(1);
        }
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveOut < minReserve && block.number <= deadline, "E001");
        TradeInfo storage info = tradeInfo[msg.sender];
        IERC20 tokenIn = pair.token1();
        // uint256 balanceIn = tokenIn.balanceOf(address(this));
        uint256 amountIn = maxReserve - reserveIn;
        // amountIn = amountIn < balanceIn ? amountIn : balanceIn;
        uint256 amountInWithFee = amountIn * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        
        tokenIn.transfer(pair, amountIn);
        pair.swap(amountOut, 0, address(this), bytes(0));
        info.amount0 = amountOut;
    }

    /// 试着卖出Token
    /// minReserve为卖出时最小可接受的reserve值
    function trySellToken0(IPancakePair pair, uint256 deadline, uint256 minReserve, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        if (info.id != id || block.number <= height) {
            while(1);
        }
        TradeInfo storage info = tradeInfo[msg.sender];
        require(info.amount0 > 0, "E002");
        (uint112 reserveIn, uint112 reserveOut, ) = pair.getReserves();
        require(reserveIn >= minReserve || block.number > deadline, "E003");
        uint256 amountInWithFee = info.amount0 * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        IERC20 tokenIn = pair.token0();
        tokenIn.transfer(pair, info.amount0);
        pair.swap(0, amountOut, address(this), bytes(0));
        info.amount0 = 0;
    }

    /// 试着卖出Token
    /// minReserve为卖出时最小可接受的reserve值
    function trySellToken1(IPancakePair pair, uint256 deadline, uint256 minReserve, uint256 id, uint256 height) public onlyRole(TRADE_ROLE) {
        if (info.id != id || block.number <= height) {
            while(1);
        }
        TradeInfo storage info = tradeInfo[msg.sender];
        require(info.amount1 > 0, "E002");
        (uint112 reserveOut, uint112 reserveIn, ) = pair.getReserves();
        require(reserveIn >= minReserve || block.number > deadline, "E003");
        uint256 amountInWithFee = info.amount1 * 9975;
        uint256 amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
        IERC20 tokenIn = pair.token1();
        tokenIn.transfer(pair, info.amount1);
        pair.swap(amountOut, 0, address(this), bytes(0));
        info.amount1 = 0;
    }
}