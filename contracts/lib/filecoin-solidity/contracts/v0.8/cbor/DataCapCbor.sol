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

import "solidity-cborutils/contracts/CBOR.sol";

import {CommonTypes} from "../types/CommonTypes.sol";
import {DataCapTypes} from "../types/DataCapTypes.sol";
import "../utils/CborDecode.sol";
import "../utils/Misc.sol";
import "./BigIntCbor.sol";

library BytesCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for bytes;

    function serializeAddress(bytes memory addr) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.writeBytes(addr);

        return buf.data();
    }

    function serializeNull() internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.writeNull();

        return buf.data();
    }

    function deserializeAddress(bytes memory ret) internal pure returns (bytes memory) {
        bytes memory addr;
        uint byteIdx = 0;

        (addr, byteIdx) = ret.readBytes(byteIdx);

        return addr;
    }

    function deserializeString(bytes memory ret) internal pure returns (string memory) {
        string memory response;
        uint byteIdx = 0;

        (response, byteIdx) = ret.readString(byteIdx);

        return response;
    }

    function deserializeBigNum(bytes memory ret) internal pure returns (BigInt memory) {
        bytes memory tmp;
        uint byteIdx = 0;

        if (ret.length > 0) {
            (tmp, byteIdx) = ret.readBytes(byteIdx);
            if (tmp.length > 0) {
                return tmp.deserializeBigNum();
            }
        }

        return BigInt(new bytes(0), false);
    }
}

/// @title FIXME
/// @author Zondax AG
library GetAllowanceCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serialize(DataCapTypes.GetAllowanceParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeBytes(params.owner);
        buf.writeBytes(params.operator);

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library TransferCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for BigInt;
    using BigIntCBOR for bytes;

    function serialize(DataCapTypes.TransferParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(3);
        buf.writeBytes(params.to);
        buf.writeBytes(params.amount.serializeBigNum());
        buf.writeBytes(params.operator_data);

        return buf.data();
    }

    function deserialize(DataCapTypes.TransferReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;
        uint len;
        bytes memory tmp;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 3);

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.from_balance = tmp.deserializeBigNum();

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.to_balance = tmp.deserializeBigNum();

        (ret.recipient_data, byteIdx) = rawResp.readBytes(byteIdx);
    }
}

/// @title FIXME
/// @author Zondax AG
library TransferFromCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for BigInt;
    using BigIntCBOR for bytes;

    function serialize(DataCapTypes.TransferFromParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(4);
        buf.writeBytes(params.from);
        buf.writeBytes(params.to);
        buf.writeBytes(params.amount.serializeBigNum());
        buf.writeBytes(params.operator_data);

        return buf.data();
    }

    function deserialize(DataCapTypes.TransferFromReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;
        uint len;
        bytes memory tmp;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 4);

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.from_balance = tmp.deserializeBigNum();

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.to_balance = tmp.deserializeBigNum();

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.allowance = tmp.deserializeBigNum();

        (ret.recipient_data, byteIdx) = rawResp.readBytes(byteIdx);
    }
}

/// @title FIXME
/// @author Zondax AG
library IncreaseAllowanceCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for BigInt;

    function serialize(DataCapTypes.IncreaseAllowanceParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeBytes(params.operator);
        buf.writeBytes(params.increase.serializeBigNum());

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library DecreaseAllowanceCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for BigInt;

    function serialize(DataCapTypes.DecreaseAllowanceParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeBytes(params.operator);
        buf.writeBytes(params.decrease.serializeBigNum());

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library RevokeAllowanceCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serialize(DataCapTypes.RevokeAllowanceParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(1);
        buf.writeBytes(params.operator);

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library BurnCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for BigInt;
    using BigIntCBOR for bytes;

    function serialize(DataCapTypes.BurnParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(1);
        buf.writeBytes(params.amount.serializeBigNum());

        return buf.data();
    }

    function deserialize(DataCapTypes.BurnReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;
        uint len;
        bytes memory tmp;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 1);

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.balance = tmp.deserializeBigNum();
    }
}

/// @title FIXME
/// @author Zondax AG
library BurnFromCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for BigInt;
    using BigIntCBOR for bytes;

    function serialize(DataCapTypes.BurnFromParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeBytes(params.owner);
        buf.writeBytes(params.amount.serializeBigNum());

        return buf.data();
    }

    function deserialize(DataCapTypes.BurnFromReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;
        uint len;
        bytes memory tmp;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.balance = tmp.deserializeBigNum();

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.allowance = tmp.deserializeBigNum();
    }
}
