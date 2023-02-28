// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { MarketTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import { CBOR } from "@zondax/filecoin-solidity/contracts/v0.8/external/CBOR.sol";
import { FilecoinCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/FilecoinCbor.sol";
import { CBORDecoder } from "@zondax/filecoin-solidity/contracts/v0.8/utils/CborDecode.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import { BigIntCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";

using CBOR for CBOR.CBORBuffer;
using CBORDecoder for bytes;
using BigIntCBOR for CommonTypes.BigInt;
using BigIntCBOR for bytes;
using FilecoinCBOR for CBOR.CBORBuffer;

struct MarketDealNotifyParams {
    bytes dealProposal;
    uint64 dealId;
}

function deserializeMarketDealNotifyParams(bytes memory rawResp) pure returns (MarketDealNotifyParams memory ret) {
    uint byteIdx = 0;
    uint len;

    (len, byteIdx) = rawResp.readFixedArray(byteIdx);
    assert(len == 2);

    (ret.dealProposal, byteIdx) = rawResp.readBytes(byteIdx);
    (ret.dealId, byteIdx) = rawResp.readUInt64(byteIdx);
}

function serializeDealProposal(MarketTypes.DealProposal memory dealProposal) pure returns (bytes memory) {
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


function deserializeDealProposal(bytes memory rawResp) pure returns (MarketTypes.DealProposal memory ret) {
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
