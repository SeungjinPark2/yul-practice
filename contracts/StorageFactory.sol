// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract StorageTwo {

    uint32 value1;
    uint32 value2;
    uint64 value3;
    uint128 value4;
    uint128 value5 = 1;
    uint128 value6 = 2;
    uint256[] value7;

    struct Var10 {
        uint256 subVar1;
        uint256 subVar2;
    }


    function store() public {
        value1 = 1;
        value2 = 22;
        value3 = 333;
        value4 = 4444;
        value7.push(111111111111111);
        value7.push(222222222222222);
        value7.push(333333333333333);
    }

    function addOneAnTwoYul() external pure returns(uint256) {
        // We can access variables from solidity inside our Yul code
        uint256 ans;

        assembly {
            // assigns variables in Yul
            let one := 1
            let two := 2
            // adds the two variables together
            ans := add(one, two)
        }
        return ans;
    }

    function readAndWriteToStorage() external returns (uint256, uint256, uint256) {
        uint256 x;
        uint256 y;
        uint256 z;
      
        assembly  {
        
            // gets slot of var5
            let slot := value6.slot
            
            // gets offset of var5
            let offset := value6.offset
            
            // assigns x and y from solidity to slot and offset
            x := slot
            y := offset
            // stores value 1 in slot 0
            sstore(0,1)
            
            // assigns z to the value from slot 0
            z := sload(0)
        }

        return (x, y, z);
    }

    function getValInHex(uint256 y) external view returns (bytes32) {
        // since Yul works with hex we want to return in bytes
        bytes32 x;
        
        assembly  {
            // assign value of slot y to x
            x := sload(y)
        }
        
        return x;
    }

    function getValFromDynamicArray(uint256 targetIndex) external view returns (uint256) {
        // get the slot of the dynamic array
        uint256 slot;
    
        assembly {
            slot := value7.slot
        }
    
        // get hash of slot for start index
        bytes32 startIndex = keccak256(abi.encode(slot));
    
        uint256 ans;
    
        assembly {
            // adds start index and target index to get storage location. Then loads corresponding storage slot
            ans := sload( add(startIndex, targetIndex) )
        }
    
        return ans;
    }

    function getStructValues() external pure returns(uint256, uint256) {
        // initialize struct
        Var10 memory s;
        s.subVar1 = 32;
        s.subVar2 = 64;
    
        assembly {
            return( 0x80, 0x40 )
        }
    }

    function getDynamicArray(uint256[] memory arr) external pure returns (uint256[] memory) {
        assembly {
    
            // where array is stored in memory (0x80)
            let location := arr

            // length of array is stored at arr (4)
            let length := mload(arr)

            // gets next available memory location
            let nextMemoryLocation := add( add( location, 0x20 ), mul( length, 0x20 ) )

            // stores new value to memory
            mstore(nextMemoryLocation, 5)

            // increment length by 1
            length := add( length, 1 )
 
            // store new length value
            mstore(location, length)

            // update free memory pointer
            mstore(0x40, 0x140)

            //return ( add( location, 0x20 ) , mul( length, 0x20 ) )
        }
        return arr;
    }

}