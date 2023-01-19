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

/// @title Filecoin actors' common types for Solidity.
/// @author Zondax AG
library CommonTypes {
    enum RegisteredSealProof {
        StackedDRG2KiBV1,
        StackedDRG512MiBV1,
        StackedDRG8MiBV1,
        StackedDRG32GiBV1,
        StackedDRG64GiBV1,
        StackedDRG2KiBV1P1,
        StackedDRG512MiBV1P1,
        StackedDRG8MiBV1P1,
        StackedDRG32GiBV1P1,
        StackedDRG64GiBV1P1,
        Invalid
    }

    enum RegisteredPoStProof {
        StackedDRGWinning2KiBV1,
        StackedDRGWinning8MiBV1,
        StackedDRGWinning512MiBV1,
        StackedDRGWinning32GiBV1,
        StackedDRGWinning64GiBV1,
        StackedDRGWindow2KiBV1,
        StackedDRGWindow8MiBV1,
        StackedDRGWindow512MiBV1,
        StackedDRGWindow32GiBV1,
        StackedDRGWindow64GiBV1,
        Invalid
    }

    enum RegisteredUpdateProof {
        StackedDRG2KiBV1,
        StackedDRG8MiBV1,
        StackedDRG512MiBV1,
        StackedDRG32GiBV1,
        StackedDRG64GiBV1,
        Invalid
    }
    enum ExtensionKind {
        ExtendCommittmentLegacy,
        ExtendCommittment
    }

    enum SectorSize {
        _2KiB,
        _8MiB,
        _512MiB,
        _32GiB,
        _64GiB
    }

    struct ValidatedExpirationExtension {
        uint64 deadline;
        uint64 partition;
        uint8 sectors;
        int64 new_expiration;
    }

    struct ExtendExpirationsInner {
        ValidatedExpirationExtension[] extensions;
        bytes claims; // FIXME this is a BTreeMap<SectorNumber, (u64, u64)> on rust
    }

    struct PendingBeneficiaryChange {
        bytes new_beneficiary;
        BigInt new_quota;
        uint64 new_expiration;
        bool approved_by_beneficiary;
        bool approved_by_nominee;
    }

    struct BeneficiaryTerm {
        BigInt quota;
        BigInt used_quota;
        uint64 expiration;
    }

    struct ActiveBeneficiary {
        bytes beneficiary;
        BeneficiaryTerm term;
    }

    struct RecoveryDeclaration {
        uint64 deadline;
        uint64 partition;
        uint8 sectors;
    }

    struct FaultDeclaration {
        uint64 deadline;
        uint64 partition;
        uint8 sectors;
    }

    struct TerminationDeclaration {
        uint64 deadline;
        uint64 partition;
        uint8 sectors;
    }

    struct SectorClaim {
        uint64 sector_number;
        uint64[] maintain_claims;
        uint64[] drop_claims;
    }

    struct ExpirationExtension2 {
        uint64 deadline;
        uint64 partition;
        uint8 sectors;
        SectorClaim[] sectors_with_claims;
        int64 new_expiration;
    }

    struct ExpirationExtension {
        uint64 deadline;
        uint64 partition;
        uint8 sectors;
        int64 new_expiration;
    }

    struct SectorPreCommitInfoInner {
        RegisteredSealProof seal_proof;
        uint64 sector_number;
        bytes sealed_cid;
        int64 seal_rand_epoch;
        uint64[] deal_ids;
        int64 expiration;
        bytes unsealed_cid;
    }

    struct SectorPreCommitInfo {
        RegisteredSealProof seal_proof;
        uint64 sector_number;
        bytes sealed_cid;
        int64 seal_rand_epoch;
        uint64[] deal_ids;
        int64 expiration;
        bytes unsealed_cid;
    }
    struct ReplicaUpdateInner {
        uint64 sector_number;
        uint64 deadline;
        uint64 partition;
        bytes new_sealed_cid;
        bytes new_unsealed_cid;
        uint64[] deals;
        RegisteredUpdateProof update_proof_type;
        bytes replica_proof;
    }

    struct ReplicaUpdate {
        uint64 sector_number;
        uint64 deadline;
        uint64 partition;
        bytes new_sealed_cid;
        uint64 deals;
        RegisteredUpdateProof update_proof_type;
        bytes replica_proof;
    }

    struct ReplicaUpdate2 {
        uint64 sector_number;
        uint64 deadline;
        uint64 partition;
        bytes new_sealed_cid;
        bytes new_unsealed_cid;
        uint64 deals;
        RegisteredUpdateProof update_proof_type;
        bytes replica_proof;
    }

    struct PoStPartition {
        uint64 index;
        int8 skipped;
    }

    struct PoStProof {
        RegisteredPoStProof post_proof;
        bytes proof_bytes;
    }

    struct VestingFunds {
        int64 epoch;
        BigInt amount;
    }
    struct SectorDeals {
        int64 sector_type;
        int64 sector_expiry;
        uint64[] deal_ids;
    }

    struct DealProposal {
        bytes piece_cid;
        uint64 piece_size;
        bool verified_deal;
        bytes client;
        bytes provider;
        string label;
        int64 start_epoch;
        int64 end_epoch;
        BigInt storage_price_per_epoch;
        BigInt provider_collateral;
        BigInt client_collateral;
    }

    struct ClientDealProposal {
        DealProposal proposal;
        bytes client_signature;
    }

    struct SectorDealData {
        bytes commd;
    }

    struct CID {
        uint8 version;
        uint64 codec;
        Multihash hash;
    }

    struct Multihash {
        uint64 code;
        uint8 size;
        bytes digest;
    }

    struct VerifiedDealInfo {
        uint64 client;
        uint64 allocation_id;
        bytes data;
        uint64 size;
    }

    struct SectorDataSpec {
        uint64[] deal_ids;
        int64 sector_type;
    }

    struct FailCode {
        uint32 idx;
        uint32 code;
    }

    struct BatchReturn {
        // Total successes in batch
        uint32 success_count;
        // Failure code and index for each failure in batch
        FailCode[] fail_codes;
    }

    struct Claim {
        // The provider storing the data (from allocation).
        uint64 provider;
        // The client which allocated the DataCap (from allocation).
        uint64 client;
        // Identifier of the data committed (from allocation).
        bytes data;
        // The (padded) size of data (from allocation).
        uint64 size;
        // The min period after term_start which the provider must commit to storing data
        int64 term_min;
        // The max period after term_start for which provider can earn QA-power for the data
        int64 term_max;
        // The epoch at which the (first range of the) piece was committed.
        int64 term_start;
        // ID of the provider's sector in which the data is committed.
        uint64 sector;
    }
    struct ClaimTerm {
        uint64 provider;
        uint64 claim_id;
        int64 term_max;
    }
}
