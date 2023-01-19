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

/// @title Filecoin multisig actor types for Solidity.
/// @author Zondax AG
library MultisigTypes {
    uint constant ProposeMethodNum = 1696838335;
    uint constant ApproveMethodNum = 1289044053;
    uint constant CancelMethodNum = 3365893656;
    uint constant AddSignerMethodNum = 3028530033;
    uint constant RemoveSignerMethodNum = 21182899;
    uint constant SwapSignerMethodNum = 3968117037;
    uint constant ChangeNumApprovalsThresholdMethodNum = 3375931653;
    uint constant LockBalanceMethodNum = 1999470977;
    uint constant UniversalReceiverHookMethodNum = 3726118371;

    struct ProposeParams {
        bytes to;
        BigInt value;
        uint64 method;
        bytes params;
    }

    struct ProposeReturn {
        /// TxnID is the ID of the proposed transaction.
        int64 txn_id;
        /// Applied indicates if the transaction was applied as opposed to proposed but not applied
        /// due to lack of approvals.
        bool applied;
        /// Code is the exitcode of the transaction, if Applied is false this field should be ignored.
        uint32 code;
        /// Ret is the return value of the transaction, if Applied is false this field should
        /// be ignored.
        bytes ret;
    }

    struct TxnIDParams {
        int64 id;
        /// Optional hash of proposal to ensure an operation can only apply to a
        /// specific proposal.
        bytes proposal_hash;
    }

    struct ApproveReturn {
        /// Applied indicates if the transaction was applied as opposed to proposed but not applied
        /// due to lack of approvals
        bool applied;
        /// Code is the exitcode of the transaction, if Applied is false this field should be ignored.
        uint32 code;
        /// Ret is the return value of the transaction, if Applied is false this field should
        /// be ignored.
        bytes ret;
    }

    struct AddSignerParams {
        bytes signer;
        bool increase;
    }

    struct RemoveSignerParams {
        bytes signer;
        bool decrease;
    }

    struct SwapSignerParams {
        bytes from;
        bytes to;
    }

    struct ChangeNumApprovalsThresholdParams {
        uint64 new_threshold;
    }

    struct LockBalanceParams {
        int64 start_epoch;
        int64 unlock_duration;
        BigInt amount;
    }
}
