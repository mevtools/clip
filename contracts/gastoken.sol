// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Rlp {
    mapping (uint256 => uint256) a;
    mapping (uint256=>uint256) b;

    function _addressFrom(address _origin, uint _nonce) private pure returns (address _address) {
        bytes memory data;
        // if(_nonce == 0x00)          data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80));
        // nonce > 0
        if(_nonce <= 0x7f)     data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, uint8(_nonce));
        else if(_nonce <= 0xff)     data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), _origin, bytes1(0x81), uint8(_nonce));
        else if(_nonce <= 0xffff)   data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), _origin, bytes1(0x82), uint16(_nonce));
        else if(_nonce <= 0xffffff) data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), _origin, bytes1(0x83), uint24(_nonce));
        else                        data = abi.encodePacked(bytes1(0xda), bytes1(0x94), _origin, bytes1(0x84), uint32(_nonce));
        bytes32 hash = keccak256(data);
        assembly {
            mstore(0, hash)
            _address := mload(0)
        }
    }

    function mkContractAddress(address origin, uint nonce) external pure returns (address _address) {
        return _addressFrom(origin, nonce);
    }

    // Creates a child contract that can only be destroyed by this contract.
    function makeChild() internal returns (address addr) {
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
            mstore(solidity_free_mem_ptr, 0x6f3360701c65525665DE8DdD18585733ff60005260106010f3)
            addr := create(1, add(solidity_free_mem_ptr, 7), 25)
        }
    }

    function destroyChildren(uint256 start, uint256 end) private {
        // tail points to slot behind the last contract in the queue
        for (; start < end; start++) {
            _addressFrom(address(this), start).call("");
        }
    }

    function test1(uint256 l0, uint256 r0, uint256 l1, uint256 r1) external {
        for(; l1 < r1; ++l1) {
            a[l1] = r1;
        }
        destroyChildren(l0, r0);
    }

    function test2(uint256 l1, uint256 r1) external {
        for(; l1 < r1; ++l1) {
            b[l1] = r1;
        }
    }

    function mint(uint256 n) external  {
        for(uint i = 0; i < n; ++i) {
            makeChild();
        }
        
    }
    
}


