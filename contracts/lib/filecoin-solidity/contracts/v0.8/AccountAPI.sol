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

import "./types/AccountTypes.sol";
import "./cbor/AccountCbor.sol";
import "./types/CommonTypes.sol";
import "./utils/Misc.sol";
import "./utils/Actor.sol";

/// @title This contract is a proxy to the Account actor. Calling one of its methods will result in a cross-actor call being performed.
/// @author Zondax AG
library AccountAPI {
    using AuthenticateMessageCBOR for AccountTypes.AuthenticateMessageParams;
    using UniversalReceiverHookCBOR for AccountTypes.UniversalReceiverParams;
    using BytesCBOR for bytes;

    /// @notice FIXME
    function authenticateMessage(bytes memory target, AccountTypes.AuthenticateMessageParams memory params) internal {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(AccountTypes.AuthenticateMessageMethodNum, target, raw_request, Misc.CBOR_CODEC);

        Actor.readRespData(raw_response);
    }

    /// @notice FIXME
    function universalReceiverHook(bytes memory target, AccountTypes.UniversalReceiverParams memory params) internal {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(AccountTypes.UniversalReceiverHookMethodNum, target, raw_request, Misc.CBOR_CODEC);

        Actor.readRespData(raw_response);
    }
}
