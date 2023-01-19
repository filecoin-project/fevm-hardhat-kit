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

/// @title Filecoin datacap actor types for Solidity.
/// @author Zondax AG
library DataCapTypes {
    bytes constant ActorCode = hex"0007";
    uint constant NameMethodNum = 48890204;
    uint constant SymbolMethodNum = 2061153854;
    uint constant TotalSupplyMethodNum = 114981429;
    uint constant BalanceOfMethodNum = 3261979605;
    uint constant TransferMethodNum = 80475954;
    uint constant TransferFromMethodNum = 3621052141;
    uint constant IncreaseAllowanceMethodNum = 1777121560;
    uint constant DecreaseAllowanceMethodNum = 1529376545;
    uint constant RevokeAllowanceMethodNum = 2765635761;
    uint constant BurnMethodNum = 1434719642;
    uint constant BurnFromMethodNum = 2979674018;
    uint constant AllowanceMethodNum = 4205072950;
    uint constant ReceiverHookMethodNum = 3726118371;

    struct GetAllowanceParams {
        bytes owner;
        bytes operator;
    }

    struct TransferParams {
        bytes to;
        /// A non-negative amount to transfer
        BigInt amount;
        /// Arbitrary data to pass on via the receiver hook
        bytes operator_data;
    }

    struct TransferReturn {
        BigInt from_balance;
        /// The new balance of the `to` address
        BigInt to_balance;
        /// (Optional) data returned from receiver hook
        bytes recipient_data;
    }

    struct TransferFromParams {
        bytes from;
        bytes to;
        /// A non-negative amount to transfer
        BigInt amount;
        /// Arbitrary data to pass on via the receiver hook
        bytes operator_data;
    }

    struct TransferFromReturn {
        BigInt from_balance;
        /// The new balance of the `to` address
        BigInt to_balance;
        /// The new remaining allowance between `owner` and `operator` (caller)
        BigInt allowance;
        /// (Optional) data returned from receiver hook
        bytes recipient_data;
    }

    struct IncreaseAllowanceParams {
        bytes operator;
        /// A non-negative amount to increase the allowance by
        BigInt increase;
    }
    struct DecreaseAllowanceParams {
        bytes operator;
        /// A non-negative amount to decrease the allowance by
        BigInt decrease;
    }
    struct RevokeAllowanceParams {
        bytes operator;
    }

    struct BurnParams {
        /// A non-negative amount to burn
        BigInt amount;
    }

    struct BurnReturn {
        /// New balance in the account after the successful burn
        BigInt balance;
    }

    struct BurnFromParams {
        bytes owner;
        /// A non-negative amount to burn
        BigInt amount;
    }

    struct BurnFromReturn {
        /// New balance in the account after the successful burn
        BigInt balance;
        /// New remaining allowance between the owner and operator (caller)
        BigInt allowance;
    }
}
