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
pragma solidity >=0.4.25 <=0.8.17;

struct BigInt {
    bytes val;
    bool neg;
}

library BigIntCBOR {
    function serializeBigNum(BigInt memory num) internal pure returns (bytes memory) {
        // TODO improve gas efficiency by using assembly code
        bytes memory raw = new bytes(num.val.length + 1);

        if (num.neg) {
            raw[0] = 0x01;
        }

        uint index = 1;
        for (uint i = 0; i < num.val.length; i++) {
            raw[index] = num.val[i];
            index++;
        }

        return raw;
    }

    function deserializeBigNum(bytes memory raw) internal pure returns (BigInt memory) {
        // TODO improve gas efficiency by using assembly code

        // Is an empty byte a valid BigInt ? We should have the sign byte at least
        if (raw.length == 0) {
            return BigInt(hex"00", false);
        }

        bytes memory val = new bytes(raw.length - 1);
        bool neg = false;

        if (raw[0] == 0x01) {
            neg = true;
        }

        for (uint i = 1; i < raw.length; i++) {
            val[i - 1] = raw[i];
        }

        return BigInt(val, neg);
    }
}
