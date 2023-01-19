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

import "../cbor/BigIntCbor.sol";
import "./CommonTypes.sol";

/// @title Filecoin power actor types for Solidity.
/// @author Zondax AG
library PowerTypes {
    bytes constant ActorCode = hex"0004";
    uint constant CreateMinerMethodNum = 1173380165;
    uint constant MinerCountMethodNum = 1987646258;
    uint constant MinerConsensusCountMethodNum = 196739875;
    uint constant NetworkRawPowerMethodNum = 931722534;
    uint constant MinerRawPowerMethodNum = 3753401894;

    struct CreateMinerParams {
        bytes owner;
        bytes worker;
        CommonTypes.RegisteredPoStProof window_post_proof_type;
        bytes peer;
        bytes[] multiaddrs;
    }
    struct CreateMinerReturn {
        /// Canonical ID-based address for the actor.
        bytes id_address;
        /// Re-org safe address for created actor.
        bytes robust_address;
    }
    struct MinerCountReturn {
        uint64 miner_count;
    }
    struct MinerConsensusCountReturn {
        int64 miner_consensus_count;
    }
    struct NetworkRawPowerReturn {
        BigInt raw_byte_power;
    }
    struct MinerRawPowerParams {
        uint64 miner;
    }
    struct MinerRawPowerReturn {
        BigInt raw_byte_power;
        bool meets_consensus_minimum;
    }
}
