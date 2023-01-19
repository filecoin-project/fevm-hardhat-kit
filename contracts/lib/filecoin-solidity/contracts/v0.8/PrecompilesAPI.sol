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
//
// DRAFT!! THIS CODE HAS NOT BEEN AUDITED - USE ONLY FOR PROTOTYPING

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @title This library simplify the call of FEVM precompiles contracts.
/// @author Zondax AG
library PrecompilesAPI {
    uint64 constant GAS_LIMIT = 100000000;
    uint64 constant MAX_RAW_RESPONSE_SIZE = 0x300;

    function resolveAddress(bytes memory addr) internal view returns (bytes memory) {
        bytes memory raw_response = new bytes(MAX_RAW_RESPONSE_SIZE);
        uint len;

        assembly {
            len := mload(addr)
            let input := mload(0x40)
            mstore(input, len)
            let offset := 0
            for {
                offset := 0x00
            } lt(offset, len) {
                offset := add(offset, 0x20)
            } {
                mstore(add(input, add(0x20, offset)), mload(add(addr, add(0x20, offset))))
            }

            if iszero(staticcall(GAS_LIMIT, 0x0a, input, add(0x20, len), raw_response, MAX_RAW_RESPONSE_SIZE)) {
                revert(0, 0)
            }
        }
        return raw_response;
    }

    function lookupAddress(uint64 actor_id) internal view returns (bytes memory) {
        bytes memory raw_response = new bytes(MAX_RAW_RESPONSE_SIZE);
        uint len;

        assembly {
            len := mload(actor_id)
            let input := mload(0x40)
            mstore(input, actor_id)

            if iszero(staticcall(GAS_LIMIT, 0x0b, input, len, raw_response, MAX_RAW_RESPONSE_SIZE)) {
                revert(0, 0)
            }
        }
        return raw_response;
    }

    function getActorType(uint64 actor_id) internal view returns (bytes memory) {
        bytes memory raw_response = new bytes(MAX_RAW_RESPONSE_SIZE);
        uint len;

        assembly {
            len := mload(actor_id)
            let input := mload(0x40)
            mstore(input, actor_id)

            if iszero(staticcall(GAS_LIMIT, 0x0c, input, len, raw_response, MAX_RAW_RESPONSE_SIZE)) {
                revert(0, 0)
            }
        }
        return raw_response;
    }
}
