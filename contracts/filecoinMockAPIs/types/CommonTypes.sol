// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.4.25 <=0.8.17;

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
        int256 new_quota;
        uint64 new_expiration;
        bool approved_by_beneficiary;
        bool approved_by_nominee;
    }

    struct BeneficiaryTerm {
        int256 quota;
        int256 used_quota;
        uint64 expiration;
    }

    struct ActiveBeneficiary {
        string beneficiary;
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

    struct FilterEstimate {
        int256 position;
        int256 velocity;
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
        int256 amount;
    }
    struct SectorDeals {
        int64 sector_type;
        int64 sector_expiry;
        uint64[] deal_ids;
    }

    struct Signature {
        int8 sig_type;
        bytes data;
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
        int storage_price_per_epoch;
        int provider_collateral;
        int client_collateral;
    }

    struct ClientDealProposal {
        DealProposal proposal;
        Signature client_signature;
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
}
