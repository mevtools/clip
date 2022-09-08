// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
contract Helper {
    constructor() payable {
    }

    // Creates a child contract that can only be destroyed by this contract.
    function makeDestoryAny(uint256 a) payable external  {
        assembly {
            let solidity_free_mem_ptr := mload(0x40)
            // 0x6f3360701c654e4e4e4e4e4e18585733ff60005260106010f3
            mstore(solidity_free_mem_ptr, 0x63600035ff6000526004601cf3)
            let addr := create(callvalue(), add(solidity_free_mem_ptr, 19), 13)
            mstore (solidity_free_mem_ptr, a)
            let ret := call (gas(), 
                addr,
                0, 
                solidity_free_mem_ptr, // input
                32, // input size = 4 bytes
                solidity_free_mem_ptr, // output stored at input location, save space
                0 // output size = 0 bytes
            )
        }
    }

    // Creates a child contract that can only be destroyed by this contract.
    function makeDestory8b0() payable external  {
        assembly {
            let solidity_free_mem_ptr := mload(0x40)
            // 0x6f3360701c654e4e4e4e4e4e18585733ff60005260106010f3
            mstore(solidity_free_mem_ptr, 0x706e8b0E974745675f7BD6cf8bd324e7DBff6000526011600ff3)
            let addr := create(callvalue(), add(solidity_free_mem_ptr, 6), 26)
            let ret := call (gas(), 
                addr,
                0, 
                solidity_free_mem_ptr, // input
                0, // input size = 4 bytes
                solidity_free_mem_ptr, // output stored at input location, save space
                0 // output size = 0 bytes
            )
        }
    }
    
    function makeDestoryF7C() payable external  {
        assembly {
            let solidity_free_mem_ptr := mload(0x40)
            // 0x6f3360701c654e4e4e4e4e4e18585733ff60005260106010f3
            mstore(solidity_free_mem_ptr, 0x706ef7cDcB778b0c33b09e175e4786f943ff6000526011600ff3)
            let addr := create(callvalue(), add(solidity_free_mem_ptr, 6), 26)
            let ret := call (gas(), 
                addr,
                0, 
                solidity_free_mem_ptr, // input
                0, // input size = 4 bytes
                solidity_free_mem_ptr, // output stored at input location, save space
                0 // output size = 0 bytes
            )
        }
    }

}