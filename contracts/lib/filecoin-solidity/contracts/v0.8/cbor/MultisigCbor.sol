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

import {MultisigTypes} from "../types/MultisigTypes.sol";
import "../utils/CborDecode.sol";
import "../utils/Misc.sol";
import "./BigIntCbor.sol";

library BytesCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serializeBytes(bytes memory data) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.writeBytes(data);

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library ProposeCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for BigInt;

    function serialize(MultisigTypes.ProposeParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(4);
        buf.writeBytes(params.to);
        buf.writeBytes(params.value.serializeBigNum());
        buf.writeUInt64(params.method);
        buf.writeBytes(params.params);

        return buf.data();
    }

    function deserialize(MultisigTypes.ProposeReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 4);

        (ret.txn_id, byteIdx) = rawResp.readInt64(byteIdx);
        (ret.applied, byteIdx) = rawResp.readBool(byteIdx);
        (ret.code, byteIdx) = rawResp.readUInt32(byteIdx);
        (ret.ret, byteIdx) = rawResp.readBytes(byteIdx);
    }
}

/// @title FIXME
/// @author Zondax AG
library TxnIDCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serialize(MultisigTypes.TxnIDParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeInt64(params.id);
        buf.writeBytes(params.proposal_hash);

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library ApproveCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function deserialize(MultisigTypes.ApproveReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 3);

        (ret.applied, byteIdx) = rawResp.readBool(byteIdx);
        (ret.code, byteIdx) = rawResp.readUInt32(byteIdx);
        (ret.ret, byteIdx) = rawResp.readBytes(byteIdx);
    }
}

/// @title FIXME
/// @author Zondax AG
library AddSignerCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serialize(MultisigTypes.AddSignerParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeBytes(params.signer);
        buf.writeBool(params.increase);

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library RemoveSignerCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serialize(MultisigTypes.RemoveSignerParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeBytes(params.signer);
        buf.writeBool(params.decrease);

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library SwapSignerCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serialize(MultisigTypes.SwapSignerParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeBytes(params.from);
        buf.writeBytes(params.to);

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library ChangeNumApprovalsThresholdCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serialize(MultisigTypes.ChangeNumApprovalsThresholdParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(1);
        buf.writeUInt64(params.new_threshold);

        return buf.data();
    }
}

/// @title FIXME
/// @author Zondax AG
library LockBalanceCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for BigInt;

    function serialize(MultisigTypes.LockBalanceParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(3);
        buf.writeInt64(params.start_epoch);
        buf.writeInt64(params.unlock_duration);
        buf.writeBytes(params.amount.serializeBigNum());

        return buf.data();
    }
}
