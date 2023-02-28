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

import "../external/CBOR.sol";
import "./BigIntCbor.sol";
import "./FilecoinCbor.sol";
import "../utils/CborDecode.sol";

import "../types/MarketTypes.sol";
import "../utils/Misc.sol";
import "../types/CommonTypes.sol";


/// @title This library is a set of functions meant to handle CBOR parameters serialization and return values deserialization for Market actor exported methods.
/// @author Zondax AG
library MarketCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for *;
    using FilecoinCBOR for *;

    /// @notice serialize WithdrawBalanceParams struct to cbor in order to pass as arguments to the market actor
    /// @param params WithdrawBalanceParams to serialize as cbor
    /// @return response cbor serialized data as bytes
    function serializeWithdrawBalanceParams(MarketTypes.WithdrawBalanceParams memory params) internal pure returns (bytes memory) {
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(2);
        buf.writeBytes(params.provider_or_client.data);
        buf.writeBytes(params.tokenAmount.serializeBigInt());

        return buf.data();
    }

    /// @notice deserialize GetBalanceReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of GetBalanceReturn created based on parsed data
    function deserializeGetBalanceReturn(bytes memory rawResp) internal pure returns (MarketTypes.GetBalanceReturn memory ret) {
        uint byteIdx = 0;
        uint len;
        bytes memory tmp;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.balance = tmp.deserializeBigInt();

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.locked = tmp.deserializeBigInt();

        return ret;
    }

    /// @notice deserialize GetDealDataCommitmentReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of GetDealDataCommitmentReturn created based on parsed data
    function deserializeGetDealDataCommitmentReturn(bytes memory rawResp) internal pure returns (MarketTypes.GetDealDataCommitmentReturn memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);

        if (len > 0) {
            (ret.data, byteIdx) = rawResp.readBytes(byteIdx);
            (ret.size, byteIdx) = rawResp.readUInt64(byteIdx);
        } else {
            ret.data = new bytes(0);
            ret.size = 0;
        }

        return ret;
    }

    /// @notice deserialize GetDealTermReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of GetDealTermReturn created based on parsed data
    function deserializeGetDealTermReturn(bytes memory rawResp) internal pure returns (MarketTypes.GetDealTermReturn memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (ret.start, byteIdx) = rawResp.readInt64(byteIdx);
        (ret.end, byteIdx) = rawResp.readInt64(byteIdx);

        return ret;
    }

    /// @notice deserialize GetDealActivationReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of GetDealActivationReturn created based on parsed data
    function deserializeGetDealActivationReturn(bytes memory rawResp) internal pure returns (MarketTypes.GetDealActivationReturn memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (ret.activated, byteIdx) = rawResp.readInt64(byteIdx);
        (ret.terminated, byteIdx) = rawResp.readInt64(byteIdx);

        return ret;
    }

    /// @notice serialize PublishStorageDealsParams struct to cbor in order to pass as arguments to the market actor
    /// @param params PublishStorageDealsParams to serialize as cbor
    /// @return cbor serialized data as bytes
    function serializePublishStorageDealsParams(MarketTypes.PublishStorageDealsParams memory params) internal pure returns (bytes memory) {
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(1);
        buf.startFixedArray(uint64(params.deals.length));

        for (uint64 i = 0; i < params.deals.length; i++) {
            buf.startFixedArray(2);

            buf.startFixedArray(11);

            buf.writeCid(params.deals[i].proposal.piece_cid.data);
            buf.writeUInt64(params.deals[i].proposal.piece_size);
            buf.writeBool(params.deals[i].proposal.verified_deal);
            buf.writeBytes(params.deals[i].proposal.client.data);
            buf.writeBytes(params.deals[i].proposal.provider.data);
            buf.writeString(params.deals[i].proposal.label);
            buf.writeInt64(params.deals[i].proposal.start_epoch);
            buf.writeInt64(params.deals[i].proposal.end_epoch);
            buf.writeBytes(params.deals[i].proposal.storage_price_per_epoch.serializeBigInt());
            buf.writeBytes(params.deals[i].proposal.provider_collateral.serializeBigInt());
            buf.writeBytes(params.deals[i].proposal.client_collateral.serializeBigInt());

            buf.writeBytes(params.deals[i].client_signature);
        }

        return buf.data();
    }

    /// @notice deserialize PublishStorageDealsReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of PublishStorageDealsReturn created based on parsed data
    function deserializePublishStorageDealsReturn(bytes memory rawResp) internal pure returns (MarketTypes.PublishStorageDealsReturn memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        ret.ids = new CommonTypes.FilActorId[](len);

        for (uint i = 0; i < len; i++) {
            (ret.ids[i], byteIdx) = rawResp.readFilActorId(byteIdx);
        }

        (ret.valid_deals, byteIdx) = rawResp.readBytes(byteIdx);

        return ret;
    }

    /// @notice serialize deal id (uint64) to cbor in order to pass as arguments to the market actor
    /// @param id deal id to serialize as cbor
    /// @return cbor serialized data as bytes
    function serializeDealID(uint64 id) internal pure returns (bytes memory) {
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.writeUInt64(id);

        return buf.data();
    }

    function deserializeMarketDealNotifyParams(bytes memory rawResp) internal pure returns (MarketTypes.MarketDealNotifyParams memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (ret.dealProposal, byteIdx) = rawResp.readBytes(byteIdx);
        (ret.dealId, byteIdx) = rawResp.readUInt64(byteIdx);

    }

    function serializeDealProposal(MarketTypes.DealProposal memory dealProposal) internal pure returns (bytes memory) {
        // FIXME what should the max length be on the buffer?
        CBOR.CBORBuffer memory buf = CBOR.create(64);

        buf.startFixedArray(11);

        buf.writeCid(dealProposal.piece_cid.data);
        buf.writeUInt64(dealProposal.piece_size);
        buf.writeBool(dealProposal.verified_deal);
        buf.writeBytes(dealProposal.client.data);
        buf.writeBytes(dealProposal.provider.data);
        buf.writeString(dealProposal.label);
        buf.writeInt64(dealProposal.start_epoch);
        buf.writeInt64(dealProposal.end_epoch);
        buf.writeBytes(dealProposal.storage_price_per_epoch.serializeBigInt());
        buf.writeBytes(dealProposal.provider_collateral.serializeBigInt());
        buf.writeBytes(dealProposal.client_collateral.serializeBigInt());

        return buf.data();
    }


    function deserializeDealProposal(bytes memory rawResp) internal pure returns (MarketTypes.DealProposal memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 11);

        (ret.piece_cid.data, byteIdx) = rawResp.readBytes(byteIdx);
        (ret.piece_size, byteIdx) = rawResp.readUInt64(byteIdx);
        (ret.verified_deal, byteIdx) = rawResp.readBool(byteIdx);
        (ret.client.data, byteIdx) = rawResp.readBytes(byteIdx);
        (ret.provider.data, byteIdx) = rawResp.readBytes(byteIdx);

        (ret.label, byteIdx) = rawResp.readString(byteIdx);
        (ret.start_epoch, byteIdx) = rawResp.readInt64(byteIdx);
        (ret.end_epoch, byteIdx) = rawResp.readInt64(byteIdx);

        bytes memory storage_price_per_epoch_bytes;
        (storage_price_per_epoch_bytes, byteIdx) = rawResp.readBytes(byteIdx);
        ret.storage_price_per_epoch = storage_price_per_epoch_bytes.deserializeBigInt();

        bytes memory provider_collateral_bytes;
        (provider_collateral_bytes, byteIdx) = rawResp.readBytes(byteIdx);
        ret.provider_collateral = provider_collateral_bytes.deserializeBigInt();

        bytes memory client_collateral_bytes;
        (client_collateral_bytes, byteIdx) = rawResp.readBytes(byteIdx);
        ret.client_collateral = client_collateral_bytes.deserializeBigInt();

    }
}
