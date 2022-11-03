// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract CROSS2022V1 {
    mapping(address => uint256) private _admins;
    mapping(address => uint256) private _withdrawals;
    mapping(uint256 => address) private _coinbases;

    ITokenBank private _buyerBank;

    constructor(address buyerBank) {
        _admins[msg.sender] = 1;
        _withdrawals[msg.sender] = 1;
        _buyerBank = ITokenBank(buyerBank);
    }

    modifier onlyTrader {
        require(tx.origin == 0x6c3B7F6F177fFb38c06685A393f5f9128ECC0e99
                || tx.origin == 0x46e3702Fe8a5c5532e368D768418b3cacF1623eE
                || tx.origin == 0x0c9Fc86153c0219BD9EA432A05A20F280a3a7c8f
                || tx.origin == 0x0CA7C62D2b0abF4B64f04686d0E7cF52Da9a9D11
                || tx.origin == 0x859d2D5Cf3E02C667702B9098C389dB26559A671
                || tx.origin == 0xEaAeadA6F22e4EA5ed9710C111d322566125433B
                || tx.origin == 0xCb0b64205c3A03a6D19895862f00706d16f11fF4
                || tx.origin == 0x78385cbCF1c3143Eb206f5Dd084D30697d85b9b7
                || tx.origin == 0x43f8FE4F62C9bD35665baB792bb7f8e1A8546f3d
                || tx.origin == 0xCf11DC3d0731c45D57395289e187143f7C30c793
                || tx.origin == 0xE1DbBD96156FC5C7D320F40c7726356EC47c22D2
                || tx.origin == 0xB42A80B14738e24A24B0F321Db1A07e3094e60a5
                || tx.origin == 0xfA67FC194B8B2B34dFB227602eAbcE9123D3B1b3
                || tx.origin == 0xfC4B1fd3751169c979d8954F468407e271C8dCD8
                || tx.origin == 0x2389Df867bE7C495b25c0BA82e419d330bbff588
                || tx.origin == 0x12DCC6f82847Bb84786EABDd26c7fd07C4121e6e
                || tx.origin == 0xa95A28C7d4fDE72Db2fE42830860301dEC98E3C4
                || tx.origin == 0xB3C98Ba64E0253f2B52aa96b4c2185f2E6Fdfb81
                || tx.origin == 0x7db8Fe6a847BaC07ece602e40Cf21915BfB6ce60
                || tx.origin == 0x5c0Cd9fc51808FAb0D83a480885067830913F2Fb
                || tx.origin == 0xbe93E335B694c6Fdcb39167E5c67335f7b80039e
                || tx.origin == 0xa79131662ADcCA5b09aB927eF690a2C4deE23dC5
                || tx.origin == 0x6994Cb5F2baF25BFE8Ca2E49fD1Cec5D8559a16c
                || tx.origin == 0x3991993314484365851296601167350203279711);
        _;
    }

    modifier onlyAdmin {
        require(_admins[msg.sender] == 1);
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

    function updateCoinbase(uint256 id, address coinbase) external onlyAdmin {
        _coinbases[id] = coinbase;
    }

    /// set buyerBank
    function setBuyerBank(address bank) external onlyAdmin {
        _buyerBank = ITokenBank(bank);
    }
    
    // amountIn: [blocknumber]176[timeStamp]112[amountIn]0
    // minReserveOut: [index]112[reserveIn + amountIn]0, index为用户买入pair的下标，reserveIn+amountIn为买入后的reserveIn 
    // pair: [fee]176[type]168[outId]160[pairAddress]0
    // pairInfos: 0x[pair0][pair1][pair2]
    function plainCross_ejJ(uint256 amountIn, uint256 minReserveOut, bytes calldata pairInfos) external onlyTrader {
        unchecked {
            // 检查是否已经被抢
            uint256 pairInfo;          
            uint256 reserveIn;
            uint256 reserveOut;
            
            assembly {
                pairInfo := calldataload(add(pairInfos.offset, shl(5, shr(112, minReserveOut))))
            }
            pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
            // address pair = address(uint160(pairInfo));
            uint256 outId = (pairInfo >> 160) & 0xf;
            if (outId == 0) {
                (reserveOut, , ) = IPancakePair(address(uint160(pairInfo))).getReserves();
            } else {
                (, reserveOut, ) = IPancakePair(address(uint160(pairInfo))).getReserves();
            }
            require(reserveOut >= (minReserveOut & 0xffffffffffffffffffffffffffff), "E005");

            require(block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) || block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) + 3, "E002");
            // require(block.number == (amountIn >> 176) || block.number == (amountIn >> 176) + 1, "E003");
            // require(block.coinbase == _coinbases[block.number % 21], "E004");

            IERC20 tokenIn;
            uint256 nextPairInfo;

            assembly {
                pairInfo := calldataload(pairInfos.offset)
                nextPairInfo := calldataload(add(pairInfos.offset, 32))
            }
            
            pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
            nextPairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
            // pair = address(uint160(pairInfo));
            outId = (pairInfo >> 160) & 0xf;
            address recipient = address(uint160(nextPairInfo));

            if (outId == 0) {
                tokenIn = IERC20(IPancakePair(address(uint160(pairInfo))).token1());
                (reserveOut, reserveIn, ) = IPancakePair(address(uint160(pairInfo))).getReserves();
            } else {
                tokenIn = IERC20(IPancakePair(address(uint160(pairInfo))).token0());
                (reserveIn, reserveOut, ) = IPancakePair(address(uint160(pairInfo))).getReserves();
            }

            uint256 balance0 = tokenIn.balanceOf(address(_buyerBank));
            amountIn &= 0xffffffffffffffffffffffffffff;
            if (amountIn > balance0) {
                amountIn = balance0;
            }
            balance0 = amountIn;
            _buyerBank.transferToken(address(tokenIn), address(uint160(pairInfo)), amountIn);
            amountIn *= (pairInfo >> 176);
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            if (outId == 0) {
                if (((pairInfo >> 168) & 0xf) == 0) {
                    IPancakePair(address(uint160(pairInfo))).swap(amountOut, 0, recipient, "");
                } else {
                    IPancakePair2(address(uint160(pairInfo))).swap(amountOut, 0, recipient);
                }
            } else {
                if (((pairInfo >> 168) & 0xf) == 0) {
                    IPancakePair(address(uint160(pairInfo))).swap(0, amountOut, recipient, "");
                } else {
                    IPancakePair2(address(uint160(pairInfo))).swap(0, amountOut, recipient);
                }
            }

            for(uint i = 32; i < pairInfos.length; i += 32) {
                pairInfo = nextPairInfo;
                outId = (pairInfo >> 160) & 0xf;
 
                if ((outId == 0)) {
                    (reserveOut, reserveIn, ) = IPancakePair(address(uint160(pairInfo))).getReserves();
                } else {
                    (reserveIn, reserveOut, ) = IPancakePair(address(uint160(pairInfo))).getReserves();
                }
                
                amountIn = amountOut * (pairInfo >> 176);
                amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);

                if (i + 32 == pairInfos.length) {
                    recipient = address(_buyerBank);
                    require(amountOut > balance0, "E001");
                } else {
                    assembly {
                        nextPairInfo := calldataload(add(pairInfos.offset, add(i, 32)))
                    }
                    nextPairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
                    recipient = address(uint160(nextPairInfo));
                }

                if (outId == 0) {
                    if (((pairInfo >> 168) & 0xf) == 0) {
                        IPancakePair(address(uint160(pairInfo))).swap(amountOut, 0, recipient, "");
                    } else {
                        IPancakePair2(address(uint160(pairInfo))).swap(amountOut, 0, recipient);
                    }
                } else {
                    if (((pairInfo >> 168) & 0xf) == 0) {
                        IPancakePair(address(uint160(pairInfo))).swap(0, amountOut, recipient, "");
                    } else {
                        IPancakePair2(address(uint160(pairInfo))).swap(0, amountOut, recipient);
                    }
                }
            }    
        }
    }

    // 零成本套利
    // amountIn: [blocknumber]176[timeStamp]112[amountIn]0
    // minReserveOut: [index]112[reserveIn + amountIn]0, index为用户买入pair的下标，reserveIn+amountIn为买入后的reserveIn
    // pair: [fee]176[type]168[outId]160[pairAddress]0
    // pairInfos: 0x[pair0][pair1][pair2]
    // 第一个pair不能是berkeleySwap marsSwap
    function zeroCross_XrY(uint256 amountIn, uint256 minReserveOut, bytes memory pairInfos) external {
        unchecked {
            // 检查是否已经被抢
            uint256 pairInfo;
            uint256 reserveIn;
            uint256 reserveOut;
            
            assembly {
                pairInfo := mload(add(pairInfos, add(32, shl(5, shr(112, minReserveOut)))))
            }
            pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
            address pair = address(uint160(pairInfo));
            uint256 outId = (pairInfo >> 160) & 0xf;
            if (outId == 0) {
                (reserveOut, , ) = IPancakePair(pair).getReserves();
            } else {
                (, reserveOut, ) = IPancakePair(pair).getReserves();
            }
            require(reserveOut >= (minReserveOut & 0xffffffffffffffffffffffffffff), "E005");

            require(block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) || block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) + 3, "E002");
            // require(block.number == (amountIn >> 176) || block.number == (amountIn >> 176) + 1, "E003");
            // require(block.coinbase == _coinbases[block.number % 21] , "E004");

            assembly {
                pairInfo := mload(add(pairInfos, 32))
            }
            
            pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
            pair = address(uint160(pairInfo));
            outId = (pairInfo >> 160) & 0xf;
            if (outId == 0) {
                (reserveOut, reserveIn, ) = IPancakePair(pair).getReserves();
            } else {
                (reserveIn, reserveOut, ) = IPancakePair(pair).getReserves();
            }

            amountIn &= 0xffffffffffffffffffffffffffff;
            assembly {
                mstore(add(pairInfos, 32), amountIn)
            }
            
            amountIn *= (pairInfo >> 176);
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            if (outId == 0) {
                IPancakePair(pair).swap(amountOut, 0, address(this), pairInfos);
            } else {
                IPancakePair(pair).swap(0, amountOut, address(this), pairInfos);
            }
        }
    }

    function swapCall_C9f(address sender, uint256 amountOut, bytes calldata pairInfos) private onlyTrader {
        // uint256[] pairInfos = abi.decode(data, uint256[]);
        uint256 amountIn;
        uint256 amountBack;
        uint256 pairInfo;
        uint256 nextPairInfo;
        address pair;
        uint256 reserveIn;
        uint256 reserveOut;
        uint256 outId;
        address recipient;
        unchecked {
            assembly {
                amountBack := calldataload(pairInfos.offset)
            }

            // 转给pair
            assembly {
                pairInfo := calldataload(add(pairInfos.offset, 32))
            }
            pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
            pair = address(uint160(pairInfo));
            outId = (pairInfo >> 160) & 0xf;
            
            if (outId == 0) {
                IERC20(IPancakePair(pair).token1()).transfer(address(pair), amountOut);
            } else {
                IERC20(IPancakePair(pair).token0()).transfer(address(pair), amountOut);
            }

            for(uint i = 32; i < pairInfos.length; i += 32) {
                pair = address(uint160(pairInfo));
                outId = (pairInfo >> 160) & 0xf;
                
                if (outId == 0) {
                    (reserveOut, reserveIn, ) = IPancakePair(pair).getReserves();
                } else {
                    (reserveIn, reserveOut, ) = IPancakePair(pair).getReserves();
                }

                amountIn = amountOut * (pairInfo >> 176);
                amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);

                if (i + 32 < pairInfos.length) {
                    assembly {
                        nextPairInfo := calldataload(add(pairInfos.offset, add(i, 32)))
                    }
                    nextPairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
                    recipient = address(uint160(nextPairInfo));
                } else {
                    recipient = address(this);
                    require(amountOut > amountBack, "E002");
                }

                if (outId == 0) {
                    if (((pairInfo >> 168) & 0xf) == 0) {
                        IPancakePair(pair).swap(amountOut, 0, recipient, "");
                    } else {
                        IPancakePair2(pair).swap(amountOut, 0, recipient);
                    }
                } else {
                    if (((pairInfo >> 168) & 0xf) == 0) {
                        IPancakePair(pair).swap(0, amountOut, recipient, "");
                    } else {
                        IPancakePair2(pair).swap(0, amountOut, recipient);
                    }
                }

                pairInfo = nextPairInfo;
            }
            
            if (outId == 0) {
                IERC20(IPancakePair(pair).token0()).transfer(sender, amountBack);
            } else {
                IERC20(IPancakePair(pair).token1()).transfer(sender, amountBack);
            }
        }
    }

    // packeSwap v1 v2 apeSwap knightSwap
    function pancakeCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    // MDEX ZooSwap swapV2Call
    function swapV2Call(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    // JETSWAP jetswapCall
    function jetswapCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }
    
    //panda sushi defiSwap uniswapV2 uniswapV2Call
    function uniswapV2Call(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    //babySwap babyCall
    function babyCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    //FSTSwap fstswapCall
    function fstswapCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    //BiSwap BiswapCall
    function BiswapCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    // Julswap BSCSwap BSCswapCall
    function BSCswapCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    // DonkSwap donkCall
    function donkCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    // YouSwap YouSwapV2Call
    function YouSwapV2Call(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    // decaSwap decaCall
    function decaCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    //USDFI uniswapCall
    function uniswapCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }


    //NomiSwap nomiswapCall
    function nomiswapCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    //SwychSwap SwychCall
    function SwychCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

    //TeddySwap pangolinCall
    function pangolinCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
        uint256 amountOut;
        unchecked {
            if(amount0Out == 0) {
                amountOut = amount1Out;
            } else {
                amountOut = amount0Out;
            }
            swapCall_C9f(sender, amountOut, pairInfos);
        }
    }

}
