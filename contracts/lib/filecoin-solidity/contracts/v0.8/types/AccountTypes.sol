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

import "./CommonTypes.sol";

/// @title Filecoin account actor types for Solidity.
/// @author Zondax AG
library AccountTypes {
    uint constant AuthenticateMessageMethodNum = 2643134072;
    uint constant UniversalReceiverHookMethodNum = 3726118371;

    struct AuthenticateMessageParams {
        bytes signature;
        bytes message;
    }

    struct UniversalReceiverParams {
        /// Asset type
        uint32 type_;
        /// Payload corresponding to asset type
        bytes payload;
    }
}
