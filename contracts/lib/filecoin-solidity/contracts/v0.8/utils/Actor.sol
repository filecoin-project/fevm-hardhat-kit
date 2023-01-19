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

import "../../../../openzeppelin-contracts/contracts/utils/Strings.sol";

import "./Misc.sol";

library HyperActor {
    address constant CALL_ACTOR_ADDRESS = 0xfe00000000000000000000000000000000000003;
    address constant CALL_ACTOR_ID = 0xfe00000000000000000000000000000000000005;
    uint64 constant DEFAULT_FLAG = 0x00000000;

    function convert (uint256 _a) internal returns (uint64) 
    {
        return uint64(_a);
    }

    function call_actor_id(uint64 method, uint256 value, uint64 flags, uint64 codec, bytes memory params, uint64 id) internal returns (bool, int256, uint64, bytes memory) {
        (bool success, bytes memory data) = address(CALL_ACTOR_ID).delegatecall(abi.encode(method, value, flags, codec, params, id));
        (int256 exit, uint64 return_codec, bytes memory return_value) = abi.decode(data, (int256, uint64, bytes));
        return (success, exit, return_codec, return_value);
    }

    function call_actor_address(uint64 method, uint256 value, uint64 flags, uint64 codec, bytes memory params, bytes memory filAddress) internal returns (bool, int256, uint64, bytes memory) {
        (bool success, bytes memory data) = address(CALL_ACTOR_ADDRESS).delegatecall(abi.encode(method, value, flags, codec, params, filAddress));
        (int256 exit, uint64 return_codec, bytes memory return_value) = abi.decode(data, (int256, uint64, bytes));
        return (success, exit, return_codec, return_value);
    }

    function call(uint method, bytes memory filAddress, bytes memory params, uint64 codec) internal returns (bytes memory) {
        return call_inner(convert(method), filAddress, params, codec, msg.value);
    }

    function call_inner(uint method, bytes memory filAddress, bytes memory params, uint64 codec, uint amount) internal returns (bytes memory ) {
        (bool _success, int256 exit_code, uint64 _return_codec, bytes memory return_value) = call_actor_address(convert(method), amount, DEFAULT_FLAG, codec, params, filAddress);
        require(exit_code == 0, string.concat("actor error code ", Strings.toString(exit_code)));
        return return_value;
    }
}



library Actor {
    uint64 constant GAS_LIMIT = 100000000;
    uint64 constant CALL_ACTOR_PRECOMPILE_ADDR = 0x0e;
    uint64 constant MAX_RAW_RESPONSE_SIZE = 0x300;
    uint64 constant READ_ONLY_FLAG = 0x00000001; // https://github.com/filecoin-project/ref-fvm/blob/master/shared/src/sys/mod.rs#L60
    uint64 constant DEFAULT_FLAG = 0x00000000;

    function call(uint method_num, bytes memory actor_code, bytes memory raw_request, uint64 codec) internal returns (bytes memory) {
        call_inner(method_num, actor_code, raw_request, codec, msg.value);
    }

    function call_inner(uint method_num, bytes memory actor_code, bytes memory raw_request, uint64 codec, uint amount) internal returns (bytes memory) {
        bytes memory raw_response = new bytes(MAX_RAW_RESPONSE_SIZE);

        uint raw_request_len;
        uint actor_code_len;

        assembly {
            raw_request_len := mload(raw_request)
            actor_code_len := mload(actor_code)

            let input := mload(0x40)
            mstore(input, method_num)
            // value to send
            mstore(add(input, 0x20), amount)
            // readonly flag is mandatory for now
            mstore(add(input, 0x40), DEFAULT_FLAG)
            // cbor codec is mandatory for now
            mstore(add(input, 0x60), codec)
            // params size
            mstore(add(input, 0x80), raw_request_len)
            // address size
            mstore(add(input, 0xa0), actor_code_len)
            // actual params (copy by slice of 32 bytes)
            let start_index := 0xc0
            let offset := 0
            for {
                offset := 0x00
            } lt(offset, raw_request_len) {
                offset := add(offset, 0x20)
            } {
                mstore(add(input, add(start_index, offset)), mload(add(raw_request, add(0x20, offset))))
            }
            if mod(raw_request_len, 0x20) {
                offset := add(sub(offset, 0x20), mod(raw_request_len, 0x20))
            }

            // actual address (copy by slice of 32 bytes)
            start_index := add(start_index, offset)
            offset := 0
            for {
                offset := 0x00
            } lt(offset, actor_code_len) {
                offset := add(offset, 0x20)
            } {
                mstore(add(input, add(start_index, offset)), mload(add(actor_code, add(0x20, offset))))
            }
            if mod(actor_code_len, 0x20) {
                offset := add(sub(offset, 0x20), mod(actor_code_len, 0x20))
            }

            let len := add(start_index, offset)

            // FIXME set inputSize according to the input length
            // delegatecall(gasLimit, to, inputOffset, inputSize, outputOffset, outputSize)
            if iszero(delegatecall(GAS_LIMIT, CALL_ACTOR_PRECOMPILE_ADDR, input, len, raw_response, MAX_RAW_RESPONSE_SIZE)) {
                revert(0, 0)
            }
        }

        return raw_response;
    }

    function readRespData(bytes memory raw_response) internal pure returns (bytes memory) {
        uint256 exit_code = Misc.toUint256(raw_response, 0x00);
        uint256 size = Misc.toUint256(raw_response, 0x60);
        require(exit_code == 0, string.concat("actor error code ", Strings.toString(exit_code)));

        bytes memory result = new bytes(size);
        uint src;
        uint dst;
        assembly {
            src := add(raw_response, 0x80)
            dst := add(result, 0x20)
        }
        Misc.copy(src, dst, size);

        return result;
    }
}
