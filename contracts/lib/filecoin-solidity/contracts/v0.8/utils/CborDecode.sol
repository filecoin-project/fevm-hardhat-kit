/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// DRAFT!! THIS CODE HAS NOT BEEN AUDITED - USE ONLY FOR PROTOTYPING

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.4.25 <=0.8.17;

// 	MajUnsignedInt = 0
// 	MajSignedInt   = 1
// 	MajByteString  = 2
// 	MajTextString  = 3
// 	MajArray       = 4
// 	MajMap         = 5
// 	MajTag         = 6
// 	MajOther       = 7

uint8 constant MajUnsignedInt = 0;
uint8 constant MajSignedInt = 1;
uint8 constant MajByteString = 2;
uint8 constant MajTextString = 3;
uint8 constant MajArray = 4;
uint8 constant MajMap = 5;
uint8 constant MajTag = 6;
uint8 constant MajOther = 7;

uint8 constant TagTypeBigNum = 2;
uint8 constant TagTypeNegativeBigNum = 3;

uint8 constant True_Type = 21;
uint8 constant False_Type = 20;

library CBORDecoder {
    function isNullNext(bytes memory cborParams, uint byteIdx) internal pure returns (bool) {
        return cborParams[byteIdx] == hex"f6";
    }

    function readBool(bytes memory cborParams, uint byteIdx) internal pure returns (bool, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajOther);
        assert(value == True_Type || value == False_Type);

        return (value != False_Type, byteIdx);
    }

    function readFixedArray(bytes memory cborParams, uint byteIdx) internal pure returns (uint, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajArray);

        return (len, byteIdx);
    }

    function readString(bytes memory cborParams, uint byteIdx) internal pure returns (string memory, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajTextString);

        uint max_len = byteIdx + len;
        bytes memory slice = new bytes(len);
        uint slice_index = 0;
        for (uint256 i = byteIdx; i < max_len; i++) {
            slice[slice_index] = cborParams[i];
            slice_index++;
        }

        return (string(slice), byteIdx + len);
    }

    function readBytes(bytes memory cborParams, uint byteIdx) internal pure returns (bytes memory, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajTag || maj == MajByteString);

        if (maj == MajTag) {
            (maj, len, byteIdx) = parseCborHeader(cborParams, byteIdx);
            assert(maj == MajByteString);
        }

        uint max_len = byteIdx + len;
        bytes memory slice = new bytes(len);
        uint slice_index = 0;
        for (uint256 i = byteIdx; i < max_len; i++) {
            slice[slice_index] = cborParams[i];
            slice_index++;
        }

        return (slice, byteIdx + len);
    }

    function readBytes32(bytes memory cborParams, uint byteIdx) internal pure returns (bytes32, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajByteString);

        uint max_len = byteIdx + len;
        bytes memory slice = new bytes(32);
        uint slice_index = 32 - len;
        for (uint256 i = byteIdx; i < max_len; i++) {
            slice[slice_index] = cborParams[i];
            slice_index++;
        }

        return (bytes32(slice), byteIdx + len);
    }

    function readUInt256(bytes memory cborParams, uint byteIdx) internal pure returns (uint256, uint) {
        uint8 maj;
        uint256 value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajTag || maj == MajUnsignedInt);

        if (maj == MajTag) {
            assert(value == TagTypeBigNum);

            uint len;
            (maj, len, byteIdx) = parseCborHeader(cborParams, byteIdx);
            assert(maj == MajByteString);

            require(cborParams.length >= byteIdx + len, "slicing out of range");
            assembly {
                value := mload(add(cborParams, add(len, byteIdx)))
            }

            return (value, byteIdx + len);
        }

        return (value, byteIdx);
    }

    function readInt256(bytes memory cborParams, uint byteIdx) internal pure returns (int256, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajTag || maj == MajSignedInt);

        if (maj == MajTag) {
            assert(value == TagTypeNegativeBigNum);

            uint len;
            (maj, len, byteIdx) = parseCborHeader(cborParams, byteIdx);
            assert(maj == MajByteString);

            require(cborParams.length >= byteIdx + len, "slicing out of range");
            assembly {
                value := mload(add(cborParams, add(len, byteIdx)))
            }

            return (int256(value), byteIdx + len);
        }

        return (int256(value), byteIdx);
    }

    function readUInt64(bytes memory cborParams, uint byteIdx) internal pure returns (uint64, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajUnsignedInt);

        return (uint64(value), byteIdx);
    }

    function readUInt32(bytes memory cborParams, uint byteIdx) internal pure returns (uint32, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajUnsignedInt);

        return (uint32(value), byteIdx);
    }

    function readUInt16(bytes memory cborParams, uint byteIdx) internal pure returns (uint16, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajUnsignedInt);

        return (uint16(value), byteIdx);
    }

    function readUInt8(bytes memory cborParams, uint byteIdx) internal pure returns (uint8, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajUnsignedInt);

        return (uint8(value), byteIdx);
    }

    function readInt64(bytes memory cborParams, uint byteIdx) internal pure returns (int64, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajSignedInt || maj == MajUnsignedInt);

        return (int64(uint64(value)), byteIdx);
    }

    function readInt32(bytes memory cborParams, uint byteIdx) internal pure returns (int32, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajSignedInt || maj == MajUnsignedInt);

        return (int32(uint32(value)), byteIdx);
    }

    function readInt16(bytes memory cborParams, uint byteIdx) internal pure returns (int16, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajSignedInt || maj == MajUnsignedInt);

        return (int16(uint16(value)), byteIdx);
    }

    function readInt8(bytes memory cborParams, uint byteIdx) internal pure returns (int8, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborParams, byteIdx);
        assert(maj == MajSignedInt || maj == MajUnsignedInt);

        return (int8(uint8(value)), byteIdx);
    }

    function sliceUInt8(bytes memory bs, uint start) internal pure returns (uint8) {
        require(bs.length >= start + 1, "slicing out of range");
        uint8 x;
        assembly {
            x := mload(add(bs, add(0x01, start)))
        }
        return x;
    }

    function sliceUInt16(bytes memory bs, uint start) internal pure returns (uint16) {
        require(bs.length >= start + 2, "slicing out of range");
        uint16 x;
        assembly {
            x := mload(add(bs, add(0x02, start)))
        }
        return x;
    }

    function sliceUInt32(bytes memory bs, uint start) internal pure returns (uint32) {
        require(bs.length >= start + 4, "slicing out of range");
        uint32 x;
        assembly {
            x := mload(add(bs, add(0x04, start)))
        }
        return x;
    }

    function sliceUInt64(bytes memory bs, uint start) internal pure returns (uint64) {
        require(bs.length >= start + 8, "slicing out of range");
        uint64 x;
        assembly {
            x := mload(add(bs, add(0x08, start)))
        }
        return x;
    }

    // Parse cbor header for major type and extra info.
    // Also return the byte index after moving past header bytes, and the number of bytes consumed
    function parseCborHeader(bytes memory cbor, uint byteIndex) internal pure returns (uint8, uint64, uint) {
        uint8 first = sliceUInt8(cbor, byteIndex);
        byteIndex += 1;
        uint8 maj = (first & 0xe0) >> 5;
        uint8 low = first & 0x1f;
        // We don't handle CBOR headers with extra > 27, i.e. no indefinite lengths
        assert(low < 28);

        // extra is lower bits
        if (low < 24) {
            return (maj, low, byteIndex);
        }

        // extra in next byte
        if (low == 24) {
            uint8 next = sliceUInt8(cbor, byteIndex);
            byteIndex += 1;
            assert(next >= 24); // otherwise this is invalid cbor
            return (maj, next, byteIndex);
        }

        // extra in next 2 bytes
        if (low == 25) {
            uint16 extra16 = sliceUInt16(cbor, byteIndex);
            byteIndex += 2;
            return (maj, extra16, byteIndex);
        }

        // extra in next 4 bytes
        if (low == 26) {
            uint32 extra32 = sliceUInt32(cbor, byteIndex);
            byteIndex += 4;
            return (maj, extra32, byteIndex);
        }

        // extra in next 8 bytes
        assert(low == 27);
        uint64 extra64 = sliceUInt64(cbor, byteIndex);
        byteIndex += 8;
        return (maj, extra64, byteIndex);
    }
}
