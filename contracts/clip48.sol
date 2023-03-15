// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./iclip.sol";

contract C2022V48 {
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

    function initialize(address sellerBank) external {
        require(msg.sender == 0x3991993314484365851296601167350203279711);
        _admins[msg.sender] = 1;
        _sellerBank = ITokenBank(sellerBank);
    }

    function receiveValue() external payable onlyTrader {
        return;
    }

    modifier onlyAdmin {
        require(_admins[msg.sender] == 1);
        _;
    }

    modifier onlyTrader {
        require(tx.origin == 0xcdCb34374661da619629BE3D8A7b942f022356a3
                || tx.origin == 0xeb1FF93aa8CB9cee408b8eacA1439465A84422E2
                || tx.origin == 0x3991993314484365851296601167350203279711);
        _;
    }

    function balanceOfToken(address targetToken) external view {
        IERC20(targetToken).balanceOf(address(this));
    }

    function transferToken(address targetToken, address userTo, uint256 amount) external onlyTrader {
        IERC20(targetToken).transfer(userTo, amount);
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
        IERC20 token = IERC20(0x55d398326f99059fF775485246999027B3197955); //USDT
        token.transfer(to, token.balanceOf(address(this)));
        token = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD
        token.transfer(to, token.balanceOf(address(this)));
        token = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); //WBNB
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
    /// z = ((b*c**2*x*(a+d+x)*(a+cd+x))/(a*b*(a+x)+b*c**2*x*(a+x+c*d))-x -(a*((c-1)*(c^2*d-a*c-a)*x^2-2*a*(c^2*d+a*c^2-a)*x-a*c^3*d^2-a^2*c^2*(c+1)*d-a^3*c^2+a^3))
    /// 开始阶段斜率基本不变

    /// pairAddr: [fee]168[swapType]160[pairAddr]
    /// maxReserveIn: [minClipIn]112[maxReserveIn]
    function tryBuyToken1WithCheck_paX(uint256 pairAddr, uint256 maxReserveIn) external onlyTrader {
        // decrypt
        unchecked {
            pairAddr ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            maxReserveIn ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            uint256 minClipIn = maxReserveIn >> 112;
            maxReserveIn &= 0xffffffffffffffffffffffffffff;
            IPancakePair pair = IPancakePair(address(uint160(pairAddr)));
            (uint256 reserveIn, uint256 reserveOut, ) = pair.getReserves();
            // gas price 大于 10 Gwei，使用自毁
            if(tx.gasprice > 10000000000) {
                _destroyChild(address(this).balance);
            }
            
            // 如果有未卖出币，则不买入
            require(IERC20(pair.token1()).balanceOf(address(_sellerBank)) == 0, "B101");

            IERC20 tokenIn = IERC20(pair.token0());

            // uint256 maxReserveIn = reserveInRange >> 112;
            uint256 balanceIn = tokenIn.balanceOf(address(this));
            uint256 amountIn = maxReserveIn - reserveIn;
            amountIn = amountIn < balanceIn ? amountIn : balanceIn;

            require(amountIn >= minClipIn, "B002");
            
            tokenIn.transfer(address(pair), amountIn);
        
            amountIn *= (pairAddr >> 168);
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            if (((pairAddr >> 160) & 0xf) == 0) {
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

    /// pairAddr: [fee]168[swapType]160[pairAddr]
    /// maxReserveIn: [minClipIn]112[maxReserveIn]
    function tryBuyToken0WithCheck_Ja6(uint256 pairAddr, uint256 maxReserveIn) external onlyTrader {
        // decrypt
        unchecked {
            pairAddr ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            maxReserveIn ^= 0x00Fd1ab0F336224104E9A66b2e07866241a87C96fc;
            uint256 minClipIn = maxReserveIn >> 112;
            maxReserveIn &= 0xffffffffffffffffffffffffffff;
            IPancakePair pair = IPancakePair(address(uint160(pairAddr)));
            (uint256 reserveOut, uint256 reserveIn, ) = pair.getReserves();
            // gas price 大于 10 Gwei，使用自毁
            if(tx.gasprice > 10000000000) {
                _destroyChild(address(this).balance);
            }

            // 如果有未卖出币，则不买入
            require(IERC20(pair.token0()).balanceOf(address(_sellerBank)) == 0, "B001");

            IERC20 tokenIn = IERC20(pair.token1());

            uint256 balanceIn = tokenIn.balanceOf(address(this));
            uint256 amountIn = maxReserveIn - reserveIn;
            amountIn = amountIn < balanceIn ? amountIn : balanceIn;

            require(amountIn >= minClipIn, "B002");
            
            tokenIn.transfer(address(pair), amountIn);
            
            amountIn *= (pairAddr >> 168);
            uint256 amountOut = (amountIn * reserveOut) / (reserveIn * 10000 + amountIn);
            if (((pairAddr >> 160) & 0xf) == 0) {
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
    function sellToken0_S61(uint256 requestId, uint256 minReserveOut) external onlyTrader {
        unchecked {
            requestId ^= 0x504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd;
            IPancakePair pair = IPancakePair(address(uint160(requestId)));
            address tokenIn = pair.token0();
            uint256 amountIn = IERC20(tokenIn).balanceOf(address(_sellerBank));
            
            require(amountIn != 0, "S001");

            (uint256 reserveIn, uint256 reserveOut, ) = pair.getReserves();
            require(reserveOut >= (minReserveOut & 0xffffffffffffffffffffffffffff), "S002");

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
    function sellToken1_523(uint256 requestId, uint256 minReserveOut) external onlyTrader {
        unchecked {
            requestId ^= 0x504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd;
            IPancakePair pair = IPancakePair(address(uint160(requestId)));
            address tokenIn = pair.token1();
            uint256 amountIn = IERC20(tokenIn).balanceOf(address(_sellerBank));

            require(amountIn != 0, "S101");

            (uint256 reserveOut, uint256 reserveIn, ) = pair.getReserves();
            require(reserveOut >= (minReserveOut & 0xffffffffffffffffffffffffffff), "S102");

            _sellerBank.transferToken(tokenIn, address(pair), amountIn);

            amountIn *= (minReserveOut >> 120);
            if (((minReserveOut >> 112) & 0xf) == 0) {
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
            mstore(solidity_free_mem_ptr, 0x6a33606c1c602518585733ff600052600b6015f3)
            let addr := create(1, add(solidity_free_mem_ptr, 12), 20)
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

    function destroyMain(address payable target) external onlyAdmin {
        selfdestruct(target);
    }
}
