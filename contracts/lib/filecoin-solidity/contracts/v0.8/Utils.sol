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

import "./types/AccountTypes.sol";
import "./types/DataCapTypes.sol";
import "./cbor/AccountCbor.sol";

/// @title This library compiles a bunch of help function.
/// @author Zondax AG
library Utils {
    using AuthenticateMessageCBOR for AccountTypes.AuthenticateMessageParams;
    using BytesCBOR for bytes;

    event ReceivedDataCap(string received);

    function handleFilecoinMethod(
        uint64 method,
        uint64,
        bytes calldata params
    ) internal returns (AccountTypes.AuthenticateMessageParams memory) {
        AccountTypes.AuthenticateMessageParams memory response;
        // dispatch methods
        if (method == AccountTypes.AuthenticateMessageMethodNum) {
            // deserialize params here
            response.deserialize(params);

            return response;
        } else if (method == DataCapTypes.ReceiverHookMethodNum) {
            emit ReceivedDataCap("DataCap Received!");

            return response;
        } else {
            revert("the filecoin method that was called is not handled");
        }
    }
}
