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

import "./types/PowerTypes.sol";
import "./cbor/PowerCbor.sol";

import "./utils/Actor.sol";

/// @title FIXME
/// @author Zondax AG
library PowerAPI {
    using CreateMinerCBOR for PowerTypes.CreateMinerParams;
    using CreateMinerCBOR for PowerTypes.CreateMinerReturn;
    using MinerCountCBOR for PowerTypes.MinerCountReturn;
    using MinerConsensusCountCBOR for PowerTypes.MinerConsensusCountReturn;
    using NetworkRawPowerCBOR for PowerTypes.NetworkRawPowerReturn;
    using MinerRawPowerCBOR for PowerTypes.MinerRawPowerParams;
    using MinerRawPowerCBOR for PowerTypes.MinerRawPowerReturn;

    function createMiner(PowerTypes.CreateMinerParams memory params) internal returns (PowerTypes.CreateMinerReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(PowerTypes.CreateMinerMethodNum, PowerTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        PowerTypes.CreateMinerReturn memory response;
        response.deserialize(result);

        return response;
    }

    function minerCount() internal returns (PowerTypes.MinerCountReturn memory) {
        bytes memory raw_request = new bytes(0);

        bytes memory raw_response = Actor.call(PowerTypes.MinerCountMethodNum, PowerTypes.ActorCode, raw_request, Misc.NONE_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        PowerTypes.MinerCountReturn memory response;
        response.deserialize(result);

        return response;
    }

    function minerConsensusCount() internal returns (PowerTypes.MinerConsensusCountReturn memory) {
        bytes memory raw_request = new bytes(0);

        bytes memory raw_response = Actor.call(PowerTypes.MinerConsensusCountMethodNum, PowerTypes.ActorCode, raw_request, Misc.NONE_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        PowerTypes.MinerConsensusCountReturn memory response;
        response.deserialize(result);

        return response;
    }

    function networkRawPower() internal returns (PowerTypes.NetworkRawPowerReturn memory) {
        bytes memory raw_request = new bytes(0);

        bytes memory raw_response = Actor.call(PowerTypes.NetworkRawPowerMethodNum, PowerTypes.ActorCode, raw_request, Misc.NONE_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        PowerTypes.NetworkRawPowerReturn memory response;
        response.deserialize(result);

        return response;
    }

    function minerRawPower(PowerTypes.MinerRawPowerParams memory params) internal returns (PowerTypes.MinerRawPowerReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(PowerTypes.MinerRawPowerMethodNum, PowerTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        PowerTypes.MinerRawPowerReturn memory response;
        response.deserialize(result);

        return response;
    }
}
