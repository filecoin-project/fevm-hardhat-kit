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
import {PowerTypes} from "../types/PowerTypes.sol";
import "../utils/CborDecode.sol";
import "../utils/Misc.sol";
import "./BigIntCbor.sol";

/// @title FIXME
/// @author Zondax AG
library CreateMinerCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function serialize(PowerTypes.CreateMinerParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        uint multiaddrsLen = params.multiaddrs.length;

        buf.startFixedArray(5);
        buf.writeBytes(params.owner);
        buf.writeBytes(params.worker);
        buf.writeInt64(int64(uint64(params.window_post_proof_type)));
        buf.writeBytes(params.peer);
        buf.startFixedArray(uint64(multiaddrsLen));
        for (uint i = 0; i < multiaddrsLen; i++) {
            buf.writeBytes(params.multiaddrs[i]);
        }

        return buf.data();
    }

    function deserialize(PowerTypes.CreateMinerReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (ret.id_address, byteIdx) = rawResp.readBytes(byteIdx);
        (ret.robust_address, byteIdx) = rawResp.readBytes(byteIdx);
    }
}

/// @title FIXME
/// @author Zondax AG
library MinerCountCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function deserialize(PowerTypes.MinerCountReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;

        // REVIEW: The ouput returned is '00' so it unsigned but the type described in buitin is i64.
        (ret.miner_count, byteIdx) = rawResp.readUInt64(byteIdx);
    }
}

/// @title FIXME
/// @author Zondax AG
library MinerConsensusCountCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    function deserialize(PowerTypes.MinerConsensusCountReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;

        (ret.miner_consensus_count, byteIdx) = rawResp.readInt64(byteIdx);
    }
}

/// @title FIXME
/// @author Zondax AG
library NetworkRawPowerCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for bytes;

    function deserialize(PowerTypes.NetworkRawPowerReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;

        bytes memory tmp;
        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        if (tmp.length > 0) {
            ret.raw_byte_power = tmp.deserializeBigNum();
        } else {
            ret.raw_byte_power = BigInt(new bytes(0), false);
        }
    }
}

/// @title FIXME
/// @author Zondax AG
library MinerRawPowerCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for bytes;

    function serialize(PowerTypes.MinerRawPowerParams memory params) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.writeUInt64(params.miner);

        return buf.data();
    }

    function deserialize(PowerTypes.MinerRawPowerReturn memory ret, bytes memory rawResp) internal pure {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        bytes memory tmp;
        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        if (tmp.length > 0) {
            ret.raw_byte_power = tmp.deserializeBigNum();
        } else {
            ret.raw_byte_power = BigInt(new bytes(0), false);
        }

        (ret.meets_consensus_minimum, byteIdx) = rawResp.readBool(byteIdx);
    }
}
