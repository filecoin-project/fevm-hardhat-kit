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

/// @title Filecoin init actor types for Solidity.
/// @author Zondax AG
library InitTypes {
    bytes constant ActorCode = hex"0001";
    uint constant ExecMethodNum = 81225168;
    uint constant Exec4MethodNum = 3;

    struct ExecParams {
        bytes code_cid;
        bytes constructor_params;
    }

    struct ExecReturn {
        /// ID based address for created actor
        bytes id_address;
        /// Reorg safe address for actor
        bytes robust_address;
    }

    struct Exec4Params {
        bytes code_cid;
        bytes constructor_params;
        bytes subaddress;
    }

    struct Exec4Return {
        /// ID based address for created actor
        bytes id_address;
        /// Reorg safe address for actor
        bytes robust_address;
    }
}
