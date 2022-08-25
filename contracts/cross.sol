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
        _coinbases[0] = 0x2465176C461AfB316ebc773C61fAEe85A6515DAA;
        _coinbases[1] = 0x295e26495CEF6F69dFA69911d9D8e4F3bBadB89B;
        _coinbases[2] = 0x2b3A6c089311b478Bf629C29D790A7A6db3fc1b9;
        _coinbases[3] = 0x2D4C407BBe49438ED859fe965b140dcF1aaB71a9;
        _coinbases[4] = 0x3f349bBaFEc1551819B8be1EfEA2fC46cA749aA1;
        _coinbases[5] = 0x61Dd481A114A2E761c554B641742C973867899D3; // change --
        _coinbases[6] = 0x685B1ded8013785d6623CC18D214320b6Bb64759;
        _coinbases[7] = 0x70F657164e5b75689b64B7fd1fA275F334f28e18;
        _coinbases[8] = 0x72b61c6014342d914470eC7aC2975bE345796c2b;
        _coinbases[9] = 0x7AE2F5B9e386cd1B50A4550696D957cB4900f03a;
        _coinbases[10] = 0x8b6C8fd93d6F4CeA42Bbb345DBc6F0DFdb5bEc73;
        _coinbases[11] = 0x9F8cCdaFCc39F3c7D6EBf637c9151673CBc36b88;
        _coinbases[12] = 0xa6f79B60359f141df90A0C745125B131cAAfFD12;
        _coinbases[13] = 0xAAcF6a8119F7e11623b5A43DA638e91F669A130f;
        _coinbases[14] = 0xac0E15a038eedfc68ba3C35c73feD5bE4A07afB5;
        _coinbases[15] = 0xBe807Dddb074639cD9fA61b47676c064fc50D62C; // change  ^
        _coinbases[16] = 0xe2d3A739EFFCd3A99387d015E260eEFAc72EBea1;
        _coinbases[17] = 0xE9AE3261a475a27Bb1028f140bc2a7c843318afD;
        _coinbases[18] = 0xea0A6E3c511bbD10f4519EcE37Dc24887e11b55d;
        _coinbases[19] = 0xee226379dB83CfFC681495730c11fDDE79BA4c0C;
        _coinbases[20] = 0xEF0274E31810C9Df02F98FAFDe0f841F4E66a1Cd;
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
    // pair: [fee]176[type]168[outId]160[pairAddress]0
    // pairInfos: 0x[pair0][pair1][pair2]
    function plainCross_814(uint256 amountIn, bytes calldata pairInfos) external {
        unchecked {
            require(block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) || block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) + 3, "E002");
            require(block.number == (amountIn >> 176) || block.number == (amountIn >> 176) + 1, "E003");
            require(block.coinbase == _coinbases[block.number % 21] , "E004");

            uint256 pairInfo;
            assembly {
                pairInfo := calldataload(pairInfos.offset)
            }
            
            pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
            address pair = address(uint160(pairInfo));
            IERC20 tokenIn;
            uint256 reserveIn;
            uint256 reserveOut;
            uint256 outId = (pairInfo >> 160) & 0xf;
            address recipient = address(this);
            if (outId == 0) {
                tokenIn = IERC20(IPancakePair(pair).token1());
                (reserveOut, reserveIn, ) = IPancakePair(pair).getReserves();
            } else {
                tokenIn = IERC20(IPancakePair(pair).token0());
                (reserveIn, reserveOut, ) = IPancakePair(pair).getReserves();
            }
            uint256 balance0 = tokenIn.balanceOf(address(_buyerBank));
            amountIn &= 0xffffffffffffffffffffffffffff;
            if (amountIn > balance0) {
                amountIn = balance0;
            }
            balance0 = amountIn;
            _buyerBank.transferToken(address(tokenIn), address(pair), amountIn);
            amountIn *= (pairInfo >> 176);
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            if (outId == 0) {
                if (((pairInfo >> 168) & 0xf) == 0) {
                    IPancakePair(pair).swap(amountOut, 0, recipient, "");
                } else {
                    IPancakePair2(address(pair)).swap(amountOut, 0, recipient);
                }
            } else {
                if (((pairInfo >> 168) & 0xf) == 0) {
                    IPancakePair(pair).swap(0, amountOut, recipient, "");
                } else {
                    IPancakePair2(pair).swap(0, amountOut, recipient);
                }
            }

            for(uint i = 32; i < pairInfos.length; i += 32) {
                assembly {
                    pairInfo := calldataload(add(pairInfos.offset, i))
                }
                pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
                pair = address(uint160(pairInfo));
                outId = (pairInfo >> 160) & 0xf;
                if (outId == 0) {
                    tokenIn = IERC20(IPancakePair(pair).token1());
                    (reserveOut, reserveIn, ) = IPancakePair(pair).getReserves();
                } else {
                    tokenIn = IERC20(IPancakePair(pair).token0());
                    (reserveIn, reserveOut, ) = IPancakePair(pair).getReserves();
                }
                amountIn = amountOut;
                tokenIn.transfer(address(pair), amountIn);
                amountIn *= (pairInfo >> 176);
                amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
                if (i == pairInfos.length - 1) {
                    recipient = address(_buyerBank);
                }
                if (outId == 0) {
                    if (((pairInfo >> 168) & 0xf) == 0) {
                        IPancakePair(pair).swap(amountOut, 0, recipient, "");
                    } else {
                        IPancakePair2(address(pair)).swap(amountOut, 0, recipient);
                    }
                } else {
                    if (((pairInfo >> 168) & 0xf) == 0) {
                        IPancakePair(pair).swap(0, amountOut, recipient, "");
                    } else {
                        IPancakePair2(pair).swap(0, amountOut, recipient);
                    }
                }
            }
            require(amountOut > balance0, "E001");            
        }
    }

    // // 零成本套利
    // // amountIn: [blocknumber]176[timeStamp]112[amountIn]0
    // // pair: [fee]176[type]168[outId]160[pairAddress]0
    // // pairInfos: 0x[pair0][pair1][pair2]
    // // 第一个pair不能是berkeleySwap
    // function zeroCross_X9t(uint256 amountIn, bytes calldata pairInfos) external {
    //     unchecked {
    //         require(block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) || block.timestamp == ((amountIn >> 112) & 0xffffffffffffffff) + 3, "E002");
    //         require(block.number == (amountIn >> 176) || block.number == (amountIn >> 176) + 1, "E003");
    //         require(block.coinbase == _coinbases[block.number % 21] , "E004");

    //         uint256 pairInfo;
    //         assembly {
    //             pairInfo := calldataload(pairInfos.offset)
    //         }
            
    //         pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
    //         address pair = address(uint160(pairInfo));
    //         IERC20 tokenIn;
    //         uint256 reserveIn;
    //         uint256 reserveOut;
    //         uint256 outId = (pairInfo >> 160) & 0xf;
    //         if (outId == 0) {
    //             tokenIn = IERC20(IPancakePair(pair).token1());
    //             (reserveOut, reserveIn, ) = IPancakePair(pair).getReserves();
    //         } else {
    //             tokenIn = IERC20(IPancakePair(pair).token0());
    //             (reserveIn, reserveOut, ) = IPancakePair(pair).getReserves();
    //         }
    //         uint256 balance0 = tokenIn.balanceOf(address(this));
    //         amountIn &= 0xffffffffffffffffffffffffffff;
    //         amountIn *= (pairInfo >> 176);
    //         uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
    //         if (outId == 0) {
    //             IPancakePair(pair).swap(amountOut, 0, address(this), "");
    //         } else {
    //             IPancakePair(pair).swap(0, amountOut, address(this), "");
    //         }

    //         require(amountOut > balance0, "E001");            
    //     }
    // }

    // function pancakeCall(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata pairInfos) external {
    //     // uint256[] pairInfos = abi.decode(data, uint256[]);
    //     uint256 amountOut;
    //     uint256 amountIn;
    //     uint256 amountBack;
    //     uint256 pairInfo;
    //     address pair;
    //     IERC20 tokenIn;
    //     uint256 reserveIn;
    //     uint256 reserveOut;
    //     uint256 outId;
    //     unchecked {
    //         if(amount0Out == 0) {
    //             amountOut = amount0Out;
    //         } else {
    //             amountOut = amount1Out;
    //         }
    //         assembly {
    //             amountBack := calldataload(pairInfos.offset)
    //         }

    //         for(uint i = 32; i < pairInfos.length; i += 32) {
    //             assembly {
    //                 pairInfo := calldataload(add(pairInfos.offset, i))
    //             }
    //             pairInfo ^= 0x00c5f517009Aff811dc190f6D7f85AD040dC7F5E89;
    //             pair = address(uint160(pairInfo));
    //             outId = (pairInfo >> 160) & 0xf;
    //             if (outId == 0) {
    //                 tokenIn = IERC20(IPancakePair(pair).token1());
    //                 (reserveOut, reserveIn, ) = IPancakePair(pair).getReserves();
    //             } else {
    //                 tokenIn = IERC20(IPancakePair(pair).token0());
    //                 (reserveIn, reserveOut, ) = IPancakePair(pair).getReserves();
    //             }
    //             amountIn = amountOut;
    //             tokenIn.transfer(address(pair), amountIn);
    //             amountIn *= (pairInfo >> 176);
    //             amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
    //             if (outId == 0) {
    //                 if (((pairInfo >> 168) & 0xf) == 0) {
    //                     IPancakePair(pair).swap(amountOut, 0, address(this), "");
    //                 } else {
    //                     IPancakePair2(address(pair)).swap(amountOut, 0, address(this));
    //                 }
    //             } else {
    //                 if (((pairInfo >> 168) & 0xf) == 0) {
    //                     IPancakePair(pair).swap(0, amountOut, address(this), "");
    //                 } else {
    //                     IPancakePair2(pair).swap(0, amountOut, address(this));
    //                 }
    //             }
    //         }

    //         if (outId == 0) {
    //             IERC20(IPancakePair(pair).token0()).transfer(sender, amountBack);
    //         } else {
    //             IERC20(IPancakePair(pair).token1()).transfer(sender, amountBack);
    //         }
    //     }

    // }


}
