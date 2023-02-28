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
pragma solidity ^0.8.17;

import "../cbor/BigIntCbor.sol";
import "./CommonTypes.sol";

/// @title Filecoin market actor types for Solidity.
/// @author Zondax AG
library MarketTypes {
    CommonTypes.FilActorId constant ActorID = CommonTypes.FilActorId.wrap(5);
    uint constant AddBalanceMethodNum = 822473126;
    uint constant WithdrawBalanceMethodNum = 2280458852;
    uint constant GetBalanceMethodNum = 726108461;
    uint constant GetDealDataCommitmentMethodNum = 1157985802;
    uint constant GetDealClientMethodNum = 128053329;
    uint constant GetDealProviderMethodNum = 935081690;
    uint constant GetDealLabelMethodNum = 46363526;
    uint constant GetDealTermMethodNum = 163777312;
    uint constant GetDealEpochPriceMethodNum = 4287162428;
    uint constant GetDealClientCollateralMethodNum = 200567895;
    uint constant GetDealProviderCollateralMethodNum = 2986712137;
    uint constant GetDealVerifiedMethodNum = 2627389465;
    uint constant GetDealActivationMethodNum = 2567238399;
    uint constant PublishStorageDealsMethodNum = 2236929350;

    /// @param provider_or_client the address of provider or client.
    /// @param tokenAmount the token amount to withdraw.
    struct WithdrawBalanceParams {
        CommonTypes.FilAddress provider_or_client;
        CommonTypes.BigInt tokenAmount;
    }

    /// @param balance the escrow balance for this address.
    /// @param locked the escrow locked amount for this address.
    struct GetBalanceReturn {
        CommonTypes.BigInt balance;
        CommonTypes.BigInt locked;
    }

    /// @param data the data commitment of this deal.
    /// @param size the size of this deal.
    struct GetDealDataCommitmentReturn {
        bytes data;
        uint64 size;
    }

    /// @param start the chain epoch to start the deal.
    /// @param endthe chain epoch to end the deal.
    struct GetDealTermReturn {
        int64 start;
        int64 end;
    }

    /// @param activated Epoch at which the deal was activated, or -1.
    /// @param terminated Epoch at which the deal was terminated abnormally, or -1.
    struct GetDealActivationReturn {
        int64 activated;
        int64 terminated;
    }

    /// @param deals list of deal proposals signed by a client
    struct PublishStorageDealsParams {
        ClientDealProposal[] deals;
    }

    /// @param ids returned storage deal IDs.
    /// @param valid_deals represent all the valid deals.
    struct PublishStorageDealsReturn {
        CommonTypes.FilActorId[] ids;
        bytes valid_deals;
    }

    /// @param piece_cid PieceCID.
    /// @param piece_size the size of the piece.
    /// @param verified_deal if the deal is verified or not.
    /// @param client the address of the storage client.
    /// @param provider the address of the storage provider.
    /// @param label any label that client choose for the deal.
    /// @param start_epoch the chain epoch to start the deal.
    /// @param end_epoch the chain epoch to end the deal.
    /// @param storage_price_per_epoch the token amount to pay to provider per epoch.
    /// @param provider_collateral the token amount as collateral paid by the provider.
    /// @param client_collateral the token amount as collateral paid by the client.
    struct DealProposal {
        CommonTypes.Cid piece_cid;
        uint64 piece_size;
        bool verified_deal;
        CommonTypes.FilAddress client;
        CommonTypes.FilAddress provider;
        string label;
        int64 start_epoch;
        int64 end_epoch;
        CommonTypes.BigInt storage_price_per_epoch;
        CommonTypes.BigInt provider_collateral;
        CommonTypes.BigInt client_collateral;
    }

    /// @param proposal Proposal
    /// @param client_signature the signature signed by the client.
    struct ClientDealProposal {
        DealProposal proposal;
        bytes client_signature;
    }

    struct MarketDealNotifyParams {
        bytes dealProposal;
        uint64 dealId;
    }
}
