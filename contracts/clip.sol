// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract C2022V1 {
    mapping(address => uint256) private _admins;
    mapping(uint256 => address) private _coinbases;

    ITokenBank private _sellerBank;

    receive() external payable {
        unchecked {
            for(uint i = 0; i < msg.value; ++i) {
                makeChild();
            }
        }
    }

    constructor(address sellerBank) payable {
        _admins[msg.sender] = 1;
        _sellerBank = ITokenBank(sellerBank);
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

    function updateCoinbase(uint256 id, address coinbase) external onlyTrader {
        _coinbases[id] = coinbase;
    }

    /// set sellerBank
    function setSellerBank(address bank) external onlyAdmin {
        _sellerBank = ITokenBank(bank);
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

    /// 取消
    function cancelTransaction() external onlyTrader {
        if(tx.gasprice > 10000000000) {
            _destroyChild(address(this).balance);
        }
    }

    // 创建子合约
    function mintChild() external payable {
        unchecked {
            for(uint i = 0; i < msg.value; ++i) {
                makeChild();
            }
        }
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
    /// tokenSource 为用户起始的token，即path中的第一个token, 256[fee]232[type]224[rand]160[token address]0，fee 0.25% = 9975
    /// reserveIn = 256..224[maxReserveIn]112[minReserveIn]0
    /// amountIn = [timeStamp]112[amountIn]0
    /// victim = [blocknumber]160[victim]0 blocknumber 为最新的number+1
    /// requestId = 256[randNumber]160[pairAddress]0
    function tryBuyToken1WithCheck(uint256 requestId, uint256 reserveInRange, uint256 tokenSource, uint256 victim, uint256 amountIn) external onlyTrader {
        // decrypt
        unchecked {
            requestId ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            reserveInRange ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            uint256 minReserveIn = reserveInRange & 0xffffffffffffffffffffffffffff;
            IPancakePair pair = IPancakePair(address(uint160(requestId)));
            (uint256 reserveIn, uint256 reserveOut, ) = pair.getReserves();
            // gas price 大于 10 Gwei，使用自毁
            if(tx.gasprice > 10000000000) {
                _destroyChild(address(this).balance);
            }
            if(reserveIn > minReserveIn) {
                return;
            }

            victim ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            amountIn ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            tokenSource ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;

            require(block.timestamp == (amountIn >> 112) || block.timestamp == (amountIn >> 112) + 3, "E002");
            // require(block.number == (victim >> 160) || block.number == (victim >> 160) + 1, "E003");
            // require(block.coinbase == _coinbases[block.number % 21] , "E004");
            
            // 如果有未卖出币，则不买入
            if(IERC20(pair.token1()).balanceOf(address(_sellerBank)) > 0) {
                return;
            }

            IERC20 tokenIn = IERC20(pair.token0());

            amountIn &= 0xffffffffffffffffffffffffffff;
            uint256 balanceIn = IERC20(address(uint160(tokenSource))).balanceOf(address(uint160(victim)));
            if(balanceIn < amountIn) {
                return;
            }
            
            uint256 maxReserveIn = reserveInRange >> 112;
            balanceIn = tokenIn.balanceOf(address(this));
            amountIn = maxReserveIn - reserveIn;
            amountIn = amountIn < balanceIn ? amountIn : balanceIn;
            
            tokenIn.transfer(address(pair), amountIn);
        
            amountIn *= (tokenSource >> 232);
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            if (((tokenSource >> 224) & 0xf) == 0) {
                pair.swap(0, amountOut, address(_sellerBank), "");
            } else {
                IPancakePair2(address(pair)).swap(0, amountOut, address(_sellerBank));
            }
            if(tx.gasprice > 10000000000) {
                _destroyChild(address(this).balance);
                _destroyChild(address(this).balance);
            }
        }
    }

    /// maxReserveIn 被夹交易可以承受的上限，FixOut交易满足：maxReserveIn^2 + (maxAmountIn*0.9975)*maxReserveIn = (maxAmountIn*0.9975) * reserve0 * reserve1 / amountOut
    ///                                    FixIn交易满足：maxReserveIn^2 + (amountIn*0.9975)*maxReserveIn = (amountIn*0.9975) * reserve0 * reserve1 / minAmountOut
    /// minClipIn 考虑gasfee时最小可盈利买入量
    /// id 防止模拟执行
    /// height 发交易时最新的块高
    /// deadline 用户买入的最大块高
    /// reserveIn 超过minReserveIn时不再买入
    /// tokenSource 为用户起始的token，即path中的第一个token，256[fee]232[type]224[rand]160[token address]0，fee 0.25% = 9975
    /// reserveIn = 256..224[maxReserveIn]112[minReserveIn]0
    /// amountIn = [blocknumber]64[timeStamp]112[amountIn]0  timeStamp 为最新的timestamp + 3,
    /// victim = [blocknumber]160[victim]0 blocknumber 为最新的number+1
    /// requestId = 256[randNumber]160[pairAddress]0
    /// TODO: 卖出失败后就不再买入
    function tryBuyToken0WithCheck(uint256 requestId, uint256 reserveInRange, uint256 tokenSource, uint256 victim, uint256 amountIn) external onlyTrader {
        // decrypt
        unchecked {
            requestId ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            reserveInRange ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            uint256 minReserveIn = reserveInRange & 0xffffffffffffffffffffffffffff;
            IPancakePair pair = IPancakePair(address(uint160(requestId)));
            (uint256 reserveOut, uint256 reserveIn, ) = pair.getReserves();
            // gas price 大于 10 Gwei，使用自毁
            if(tx.gasprice > 10000000000) {
                _destroyChild(address(this).balance);
            }
            if(reserveIn > minReserveIn) {
                return;
            }
            
            victim ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            amountIn ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            tokenSource ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;

            require(block.timestamp == (amountIn >> 112) || block.timestamp == (amountIn >> 112) + 3, "E002");
            // require(block.number == (victim >> 160) || block.number == (victim >> 160) + 1, "E003");
            // require(block.coinbase == _coinbases[block.number % 21] , "E004");

            // 如果有未卖出币，则不买入
            if(IERC20(pair.token0()).balanceOf(address(_sellerBank)) > 0) {
                return;
            }

            amountIn &= 0xffffffffffffffffffffffffffff;
            IERC20 tokenIn = IERC20(pair.token1());
            uint256 balanceIn = IERC20(address(uint160(tokenSource))).balanceOf(address(uint160(victim)));
            if(balanceIn < amountIn) {
                return;
            }

            uint256 maxReserveIn = reserveInRange >> 112;
            balanceIn = tokenIn.balanceOf(address(this));
            amountIn = maxReserveIn - reserveIn;
            amountIn = amountIn < balanceIn ? amountIn : balanceIn;
            
            tokenIn.transfer(address(pair), amountIn);
            
            amountIn *= (tokenSource >> 232);
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            if (((tokenSource >> 224) & 0xf) == 0) {
                pair.swap(amountOut, 0, address(_sellerBank), "");
            } else {
                IPancakePair2(address(pair)).swap(amountOut, 0, address(_sellerBank));
            }
            if(tx.gasprice > 10000000000) {
                _destroyChild(address(this).balance);
                _destroyChild(address(this).balance);
            }
        }
    }

    /// 试着卖出Token
    /// minReserveOut为卖出时最小可接受的reserve值
    /// minReserveOut 可设置为256[fee]120[type]112[maxReserveIn+amoutIn*0.9]0
    /// 不断发送交易，直到该交易成功
    /// 如果发现被夹交易已上链，则发送个minReserveOut小的交易（比如0）使能够顺利卖出
    // fee: 0.25% = 9975
    function trySellToken0(uint256 requestId, uint256 minReserveOut) external onlyTrader {
        unchecked {
            requestId ^= 0x504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd;
            IPancakePair pair = IPancakePair(address(uint160(requestId)));
            address tokenIn = pair.token0();
            uint256 amountIn = IERC20(tokenIn).balanceOf(address(_sellerBank));
            require(amountIn > 0, "E002");

            (uint256 reserveIn, uint256 reserveOut, ) = pair.getReserves();
            require(reserveOut >= (minReserveOut & 0xffffffffffffffffffffffffffff), "E003");

            _sellerBank.transferToken(tokenIn, address(pair), amountIn);

            amountIn *= (minReserveOut >> 120);
            if (((minReserveOut >> 112) & 0xf) == 0) {
                pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(this), "");
            } else {
                IPancakePair2(address(pair)).swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(this));
            }
        }
    }

    /// 试着卖出Token
    /// minReserveOut为卖出时最小可接受的reserve值
    /// minReserveOut 可设置为256[fee]120[type]112[maxReserveIn+amoutIn*0.9]0
    // fee: 0.25% = 9975
    function trySellToken1(uint256 requestId, uint256 minReserveOut) external onlyTrader {
        unchecked {
            requestId ^= 0x504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd;
            IPancakePair pair = IPancakePair(address(uint160(requestId)));
            address tokenIn = pair.token1();
            uint256 amountIn = IERC20(tokenIn).balanceOf(address(_sellerBank));
            require(amountIn > 0, "E002");

            (uint256 reserveOut, uint256 reserveIn, ) = pair.getReserves();
            require(reserveOut >= (minReserveOut & 0xffffffffffffffffffffffffffff), "E003");

            _sellerBank.transferToken(tokenIn, address(pair), amountIn);

            amountIn *= (minReserveOut >> 120);
            if (((minReserveOut >> 112) & 0xf) == 0) {
                pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(this), "");
            } else {
                IPancakePair2(address(pair)).swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(this));
            }
        }
    }
    
    // fee: 0.25% = 9975
    function sellToken0WithAmount(IPancakePair pair, uint256 amountIn, uint256 fee, uint256 swapType) external onlyTrader {
        unchecked {
            (uint256 reserveIn, uint256 reserveOut, ) = pair.getReserves();
            _sellerBank.transferToken(pair.token0(), address(pair), amountIn);

            amountIn *= fee;
            if (swapType == 0) {
                pair.swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(this), "");
            } else {
                IPancakePair2(address(pair)).swap(0, (amountIn * reserveOut) / (reserveIn * 10000 + amountIn), address(this));
            }
        }
    }
    
    // fee: 0.25% = 9975
    function sellToken1WithAmount(IPancakePair pair, uint256 amountIn, uint256 fee, uint256 swapType) external onlyTrader {
        unchecked {
            (uint256 reserveOut, uint256 reserveIn, ) = pair.getReserves();
            _sellerBank.transferToken(pair.token1(), address(pair), amountIn);

            amountIn *= fee;
            if (swapType == 0) {
                pair.swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(this), "");
            } else {
                IPancakePair2(address(pair)).swap((amountIn * reserveOut) / (reserveIn * 10000 + amountIn), 0, address(this));
            }
        }
    }

    // Creates a child contract that can only be destroyed by this contract.
    function makeChild() private {
        assembly {
            // EVM assembler of runtime portion of child contract:
            //     ;; Pseudocode: if (msg.sender != 0x0000000000b3f879cb30fe243b4dfee438691c04) { throw; }
            //     ;;             suicide(msg.sender)
            //     PUSH15 0xb3f879cb30fe243b4dfee438691c04 ;; hardcoded address of this contract
            //     CALLER
            //     XOR
            //     PC
            //     JUMPI
            //     CALLER
            //     SELFDESTRUCT
            // Or in binary: 6eb3f879cb30fe243b4dfee438691c043318585733ff
            // Since the binary is so short (22 bytes), we can get away
            // with a very simple initcode:
            //     PUSH22 0x6eb3f879cb30fe243b4dfee438691c043318585733ff
            //     PUSH1 0
            //     MSTORE ;; at this point, memory locations mem[10] through
            //            ;; mem[31] contain the runtime portion of the child
            //            ;; contract. all that's left to do is to RETURN this
            //            ;; chunk of memory.
            //     PUSH1 22 ;; length
            //     PUSH1 10 ;; offset
            //     RETURN
            // Or in binary: 756eb3f879cb30fe243b4dfee438691c043318585733ff6000526016600af3
            // Almost done! All we have to do is put this short (31 bytes) blob into
            // memory and call CREATE with the appropriate offsets.
            let solidity_free_mem_ptr := mload(0x40)
            // 0x6f3360701c654e4e4e4e4e4e18585733ff60005260106010f3
            mstore(solidity_free_mem_ptr, 0x6f3360701c65dA506A5A283c18585733ff60005260106010f3)
            let addr := create(1, add(solidity_free_mem_ptr, 7), 25)
        }
    }

    function _destroyChild(uint _nonce) private {
        unchecked {
            bytes32 hash;
            // nonce > 0
            // if(_nonce == 0x00)       data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80)); 
            if(_nonce <= 0x7f)          hash = keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(this), uint8(_nonce)));
            else if(_nonce <= 0xff)     hash = keccak256(abi.encodePacked(bytes1(0xd7), bytes1(0x94), address(this), bytes1(0x81), uint8(_nonce)));
            else if(_nonce <= 0xffff)   hash = keccak256(abi.encodePacked(bytes1(0xd8), bytes1(0x94), address(this), bytes1(0x82), uint16(_nonce)));
            else if(_nonce <= 0xffffff) hash = keccak256(abi.encodePacked(bytes1(0xd9), bytes1(0x94), address(this), bytes1(0x83), uint24(_nonce)));
            else                        hash = keccak256(abi.encodePacked(bytes1(0xda), bytes1(0x94), address(this), bytes1(0x84), uint32(_nonce)));

            assembly {
                mstore(0, hash)
                let _addr := mload(0)
                let solidity_free_mem_ptr := mload(0x40)    
                let ret := call (gas(), 
                    _addr,
                    0, 
                    solidity_free_mem_ptr, // input
                    0, // input size = 4 bytes
                    solidity_free_mem_ptr, // output stored at input location, save space
                    0 // output size = 0 bytes
                )
            }   
        }
    }
}
