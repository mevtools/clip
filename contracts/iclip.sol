// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IPancakePair2 {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to) external;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IC2022V1 {
    /// update tradeInfo
    function updateTradeInfo(uint256 requestId, uint256 amount) external;
    /// 获取id
    function getRequestId(address key) external view returns (uint256 requestId);
}

interface ITokenBank {
    function balanceOfToken(address targetToken) external view;
    function transferToken(address targetToken, address userTo, uint256 amount) external;
}

interface IAntiSpam {
    function updateRequestId(uint256 requestId) external;
    function getRequestId(uint256 key) external view returns (uint256 requestId);
}