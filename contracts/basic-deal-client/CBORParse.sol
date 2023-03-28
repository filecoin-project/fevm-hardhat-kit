// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Note that these are quick and dirty and this approach is a poor long term substitute for parsing arbitrary cbor


// 	MajUnsignedInt = 0
// 	MajNegativeInt = 1
// 	MajByteString  = 2
// 	MajTextString  = 3
// 	MajArray       = 4
// 	MajMap         = 5
// 	MajTag         = 6
// 	MajOther       = 7
// )


uint8 constant MajUnsignedInt = 0;
uint8 constant MajNegativeInt = 1;
uint8 constant MajByteString = 2;
uint8 constant MajTextString = 3;
uint8 constant MajArray = 4;
uint8 constant MajMap = 5;
uint8 constant MajTag = 6;
uint8 constant MajOther = 7;


function specific_authenticate_message_params_parse(bytes calldata cbor_params ) pure returns (bytes calldata slice) {
    uint byteIdx = 0;
    // Expect a struct with two fields
    assert(cbor_params[0] == hex"82"); 
    byteIdx += 1;

    // Read header of signature to skip past it
    uint8 maj;
    uint len;
    (maj, len, byteIdx) = parse_cbor_header(cbor_params, byteIdx);
    assert(maj == MajByteString);
    byteIdx += len;

    // Read header of message bytes, expect bytestring, strip header return
    (maj, len, byteIdx) = parse_cbor_header(cbor_params, byteIdx);
    assert(maj == MajByteString);
    return cbor_params[byteIdx:cbor_params.length];

}

function specific_deal_proposal_cbor_parse(bytes calldata cbor_deal_proposal) pure returns (bytes calldata rawcid, bytes calldata provider, uint size){
    // Shortcut: expect a struct with 11 fields and for the first field to start with a cid tag
    // 11 field struct
    uint byteIdx = 0;
    assert(cbor_deal_proposal[byteIdx] == hex"8b");
    byteIdx += 1;
    // cid tag
    assert(cbor_deal_proposal[byteIdx] == hex"D8");
    byteIdx += 1;
    assert(cbor_deal_proposal[byteIdx] == hex"2A");
    byteIdx += 1;
    // Read header of cid, expect bytestring, strip header, record index to slice rawcid
    uint8 maj;
    uint len;
    (maj, len, byteIdx) = parse_cbor_header(cbor_deal_proposal, byteIdx);

    assert(maj == MajByteString);
    rawcid = cbor_deal_proposal[byteIdx:byteIdx+len];
    byteIdx += len;

    // Read header of data size, expect positive integer, strip header, parse and record as size
    (maj, size, byteIdx) = parse_cbor_header(cbor_deal_proposal, byteIdx);
    assert(maj == MajUnsignedInt);

    // Shortcut expect bool either false or true
    assert(cbor_deal_proposal[byteIdx] == hex"F4" || cbor_deal_proposal[byteIdx] == hex"F5");
    byteIdx += 1;

    // Read header of client, skip
    (maj, len, byteIdx) = parse_cbor_header(cbor_deal_proposal, byteIdx);

    assert(maj == MajByteString);

    byteIdx += len;

    // Read header of provider, expect bytes, strip header, record as provider 
    (maj, len, byteIdx) = parse_cbor_header(cbor_deal_proposal, byteIdx);

    assert(maj == MajByteString);
    provider = cbor_deal_proposal[byteIdx:byteIdx+len];
}

function slice_uint8(bytes memory bs, uint start) pure returns (uint8) {

    require(bs.length >= start + 1, "slicing out of range");
    uint8 x;
    assembly {
        x := mload(add(bs, add(0x01, start)))
    }
    return x;
}

function slice_uint16(bytes memory bs, uint start) pure returns (uint16) {
    require(bs.length >= start + 2, "slicing out of range");
    uint16 x;
    assembly {
        x := mload(add(bs, add(0x02, start)))
    }
    return x;
}

function slice_uint32(bytes memory bs, uint start) pure returns (uint32) {
    require(bs.length >= start + 4, "slicing out of range");
    uint32 x;
    assembly {
        x := mload(add(bs, add(0x04, start)))
    }
    return x;
}

function slice_uint64(bytes memory bs, uint start) pure returns (uint64) {
    require(bs.length >= start + 8, "slicing out of range");
    uint64 x;
    assembly {
        x := mload(add(bs, add(0x08, start)))
    }
    return x;
}

// Parse cbor header for major type and extra info. 
// Also return the byte index after moving past header bytes, and the number of bytes consumed
function parse_cbor_header(bytes memory cbor, uint byteIndex) pure returns (uint8, uint64, uint) {
    uint8 first = slice_uint8(cbor, byteIndex);
    byteIndex += 1;
    uint8 maj = (first & 0xe0) >> 5;
    uint8 low = first & 0x1f;
    // We don't handle CBOR headers with extra > 27, i.e. no indefinite lengths 
    assert(low < 28);
    // extra is lower bits
    if (low < 24) {
        return(maj, low, byteIndex);
    } 
    // extra in next byte
    if (low == 24) {
        uint8 next = slice_uint8(cbor, byteIndex);
        byteIndex += 1;
        assert(next >= 24); // otherwise this is invalid cbor
        return(maj, next, byteIndex);
    }
    // extra in next 2 bytes
    if (low == 25) {
        uint16 extra16 = slice_uint16(cbor, byteIndex);
        byteIndex += 2;
        return(maj, extra16, byteIndex);
    }
    // extra in next 4 bytes
    if (low == 26) {
        uint32 extra32 = slice_uint32(cbor, byteIndex);
        byteIndex += 4;
        return(maj, extra32, byteIndex);
    }
    // extra in next 8 bytes
    assert(low == 27);
    uint64 extra64 = slice_uint64(cbor, byteIndex);
    byteIndex += 8;
    return(maj, extra64, byteIndex);
}

