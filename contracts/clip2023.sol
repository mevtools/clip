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
    /// blockNumber: 看到的最新的区块号
    function tryBuyToken1WithCheck(address pairAddr, uint256 amountIn, uint256 blockNumber) external onlyTrader {
        require(block.number > blockNumber, "E001B");
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
    function tryBuyToken0WithCheck(address pairAddr, uint256 amountIn, uint256 blockNumber) external onlyTrader {
        require(block.number > blockNumber, "E001B");
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
    function trySellToken0(address pairAddr) external onlyTrader {
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
    function trySellToken1(address pairAddr) external onlyTrader {
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
