// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// This is the older way of doing it using assembly
contract FactoryAssembly {
    address targetAddr;
    mapping(address => uint256) private _admins;

    constructor() payable {
        _admins[msg.sender] = 1;
    }

    modifier onlyAdmin {
        require(_admins[msg.sender] == 1);
        _;
    }

    function grantAdmin(address user) external onlyAdmin {
        _admins[user] = 1;
    }

    function revokeAdmin(address user) external onlyAdmin {
        _admins[user] = 0;
    }

    function getImplementation() external view returns (address) {
        return targetAddr;
    }

    // 1. Get bytecode of contract to be deployed
    // NOTE: _owner and _foo are arguments of the TestContract's constructor
    // function getBytecode(address _owner, uint _foo) public pure returns (bytes memory) {
    //     bytes memory bytecode = type(TestContract).creationCode;

    //     return abi.encodePacked(bytecode, abi.encode(_owner, _foo));
    // }

    // 2. Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(bytes memory bytecode, uint _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    // 3. Deploy the contract
    // NOTE:
    // Check the event log Deployed which contains the address of the deployed TestContract.
    // The address in the log should equal the address computed from above.
    function deployContract(address _targetAddr, uint _salt) external payable onlyAdmin {
        targetAddr = _targetAddr;
        /*
        NOTE: How to call create2

        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[p…(p+n)))
              s = big-endian 256-bit value
        */
        assembly {
            let solidity_free_mem_ptr := mload(0x40)
            mstore(solidity_free_mem_ptr, 0x5860208158601c335a63aaf10f428752fa158151803b80938091923cf3)
            let addr := create2(
                callvalue(), // wei sent with current call
                add(solidity_free_mem_ptr, 3),
                29, // size
                _salt // Salt from function arguments
            )

            // if iszero(extcodesize(addr)) {
            //     revert(0, 0)
            // }
        }

    }
}
