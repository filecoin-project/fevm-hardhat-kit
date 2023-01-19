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

/// @title Filecoin Verified Registry actor types for Solidity.
/// @author Zondax AG
library VerifRegTypes {
    bytes constant ActorCode = hex"0006";
    uint constant GetClaimsMethodNum = 2199871187;
    uint constant AddVerifierClientMethodNum = 3916220144;
    uint constant RemoveExpiredAllocationsMethodNum = 2421068268;
    uint constant ExtendClaimTermsMethodNum = 1752273514;
    uint constant RemoveExpiredClaimsMethodNum = 2873373899;
    uint constant UniversalReceiverMethodNum = 3726118371;

    struct GetClaimsParams {
        uint64 provider;
        uint64[] claim_ids;
    }
    struct GetClaimsReturn {
        CommonTypes.BatchReturn batch_info;
        CommonTypes.Claim[] claims;
    }
    struct AddVerifierClientParams {
        bytes addr;
        bytes allowance;
    }
    struct RemoveExpiredAllocationsParams {
        // Client for which to remove expired allocations.
        uint64 client;
        // Optional list of allocation IDs to attempt to remove.
        // Empty means remove all eligible expired allocations.
        uint64[] allocation_ids;
    }
    struct RemoveExpiredAllocationsReturn {
        // Ids of the allocations that were either specified by the caller or discovered to be expired.
        uint64[] considered;
        // Results for each processed allocation.
        CommonTypes.BatchReturn results;
        // The amount of datacap reclaimed for the client.
        BigInt datacap_recovered;
    }
    struct RemoveExpiredClaimsParams {
        // Provider to clean up (need not be the caller)
        uint64 provider;
        // Optional list of claim IDs to attempt to remove.
        // Empty means remove all eligible expired claims.
        uint64[] claim_ids;
    }
    struct RemoveExpiredClaimsReturn {
        // Ids of the claims that were either specified by the caller or discovered to be expired.
        uint64[] considered;
        // Results for each processed claim.
        CommonTypes.BatchReturn results;
    }
    struct ExtendClaimTermsParams {
        CommonTypes.ClaimTerm[] terms;
    }
    struct UniversalReceiverParams {
        /// Asset type
        uint32 type_;
        /// Payload corresponding to asset type
        bytes payload;
    }

    struct AllocationsResponse {
        // Result for each allocation request.
        CommonTypes.BatchReturn allocation_results;
        // Result for each extension request.
        CommonTypes.BatchReturn extension_results;
        // IDs of new allocations created.
        uint64[] new_allocations;
    }
}
