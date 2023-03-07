// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract C2023V1 {
    mapping(address => uint256) private _admins;
    mapping(uint256 => address) private _coinbases;

    constructor() {
        _admins[msg.sender] = 1;
    }

    modifier onlyAdmin {
        require(_admins[msg.sender] == 1);
        _;
    }

    modifier onlyTrader {
        require(msg.sender == 0xbe93E335B694c6Fdcb39167E5c67335f7b80039e
                || msg.sender == 0xa79131662ADcCA5b09aB927eF690a2C4deE23dC5
                || msg.sender == 0x6c3B7F6F177fFb38c06685A393f5f9128ECC0e99
                || msg.sender == 0x3991993314484365851296601167350203279711);
        _;
    }

    function grantAdmin(address user) external onlyAdmin {
        _admins[user] = 1;
    }

    function revokeAdmin(address user) external onlyAdmin {
        _admins[user] = 0;
    }

    function withdraw(IERC20 token, address to, uint256 amount) external onlyAdmin {
        token.transfer(to, amount);
    }

    function withdrawETH(address payable to, uint256 amount) external onlyAdmin {
        to.transfer(amount);
    }

    function withdrawAll(address to) external onlyAdmin {
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
        token = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); //BUSD
        token.transfer(to, token.balanceOf(address(this)));
    }

    /// amountIn: 买入量
    /// timeStamp: 最新的timeStamp + 3
    /// _coinebase: 最新区块的coinbase
    function tryBuyToken1WithCheck_O9f(address pairAddr, uint256 amountIn, uint256 timeStamp, address _coinbase) external onlyTrader {
        require(block.timestamp == timeStamp || block.timestamp == timeStamp + 3 ||  block.timestamp == timeStamp + 6, "E001B");
        require(block.coinbase != _coinbase, "E002B");
        unchecked {
            IPancakePair pair = IPancakePair(pairAddr);
            (uint256 reserveIn, uint256 reserveOut, ) = pair.getReserves();

            IERC20 tokenIn = IERC20(pair.token0());
            uint256 balanceIn = tokenIn.balanceOf(address(this));
            amountIn = amountIn < balanceIn ? amountIn : balanceIn;
            
            tokenIn.transfer(address(pair), amountIn);
        
            amountIn *= 9975;
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            pair.swap(0, amountOut, address(this), "");
        }
    }

    /// amountIn: 买入量
    function tryBuyToken0WithCheck_JhS(address pairAddr, uint256 amountIn, uint256 timeStamp, address _coinbase) external onlyTrader {
        require(block.timestamp == timeStamp || block.timestamp == timeStamp + 3 ||  block.timestamp == timeStamp + 6, "E001B");
        require(block.coinbase != _coinbase, "E002B");
        unchecked {
            IPancakePair pair = IPancakePair(pairAddr);
            (uint256 reserveOut, uint256 reserveIn, ) = pair.getReserves();

            IERC20 tokenIn = IERC20(pair.token1());
            uint256 balanceIn = tokenIn.balanceOf(address(this));
            amountIn = amountIn < balanceIn ? amountIn : balanceIn;
            
            tokenIn.transfer(address(pair), amountIn);
        
            amountIn *= 9975;
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            pair.swap(amountOut, 0, address(this), "");
        }
    }

    // pair
    function trySellToken0_K8n(address pairAddr) external onlyTrader {
        unchecked {
            IPancakePair pair = IPancakePair(pairAddr);
            address tokenIn = pair.token0();
            uint256 amountIn = IERC20(tokenIn).balanceOf(address(this));

            require(amountIn != 0, "E001");

            (uint256 reserveIn, uint256 reserveOut, ) = pair.getReserves();

            IERC20(tokenIn).transfer(address(pair), amountIn);

            amountIn *= 9975;
            pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(this), "");
        }
    }

    // pair
    function trySellToken1_12m(address pairAddr) external onlyTrader {
        unchecked {
            IPancakePair pair = IPancakePair(pairAddr);
            address tokenIn = pair.token1();
            uint256 amountIn = IERC20(tokenIn).balanceOf(address(this));

            require(amountIn != 0, "E001");

            (uint256 reserveOut, uint256 reserveIn, ) = pair.getReserves();

            IERC20(tokenIn).transfer(address(pair), amountIn);

            amountIn *= 9975;
            pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(this), "");
        }
    }
}
