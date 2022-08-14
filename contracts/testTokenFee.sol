// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract TestTokenFee {
    constructor() {}
    
    // 测试token transaction fee
    // pair转amount的币给该地址（可以转1/4 balance）
    // 返回pair转给用户的费率及用户转给pair的费率
    // 精度为10^8
    function getTokenFee(IERC20 token, address pair, uint256 amount) external returns (uint256 fromPair, uint256 toPair) {
        uint256 amountIn = token.balanceOf(address(this));
        fromPair = (amount - amountIn) * 100000000 / amount;
        uint256 balanceBefore = token.balanceOf(address(pair));
        token.transfer(address(pair), amountIn);
        uint256 balanceAfter = token.balanceOf(address(pair));
        uint256 amountOut = balanceAfter - balanceBefore;
        toPair = (amountIn - amountOut) * 100000000 / amountIn;
    }
}