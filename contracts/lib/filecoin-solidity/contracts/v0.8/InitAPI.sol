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

import "./types/InitTypes.sol";
import "./cbor/InitCbor.sol";
import "./types/CommonTypes.sol";
import "./utils/Misc.sol";
import "./utils/Actor.sol";

/// @title This contract is a proxy to the singleton Init actor (address: f01). Calling one of its methods will result in a cross-actor call being performed.
/// @author Zondax AG
library InitAPI {
    using ExecCBOR for InitTypes.ExecParams;
    using ExecCBOR for InitTypes.ExecReturn;
    using Exec4CBOR for InitTypes.Exec4Params;
    using Exec4CBOR for InitTypes.Exec4Return;

    /// @notice FIXME
    function exec(InitTypes.ExecParams memory params) internal returns (InitTypes.ExecReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(InitTypes.ExecMethodNum, InitTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        InitTypes.ExecReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @notice FIXME
    function exec4(InitTypes.Exec4Params memory params) internal returns (InitTypes.Exec4Return memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(InitTypes.Exec4MethodNum, InitTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        InitTypes.Exec4Return memory response;
        response.deserialize(result);

        return response;
    }
}
