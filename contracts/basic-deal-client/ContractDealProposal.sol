// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
//import "@zondax/filecoin-solidity/contracts/v0.8/external/CBOR.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/utils/CborDecode.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/FilecoinCbor.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";


using CBOR for CBOR.CBORBuffer;
using CBORDecoder for bytes;
using BigIntCBOR for CommonTypes.BigInt;
using BigIntCBOR for bytes;
using FilecoinCBOR for CBOR.CBORBuffer;


struct ContractDealProposal{
    CommonTypes.Cid piece_cid;
    uint64 piece_size;
    bool verified_deal;
    CommonTypes.FilAddress client;
    string label;
    int64 start_epoch;
    int64 end_epoch;
    CommonTypes.BigInt storage_price_per_epoch;
    CommonTypes.BigInt provider_collateral;
    CommonTypes.BigInt client_collateral;
    string version;
    ParamsVersion1 params;
}

struct ParamsVersion1 {
	string location_ref;
	uint64 car_size;
	bool SkipIpniAnnounce;
	bool RemoveUnsealedCopy;
}


function serializeParamsVersion1(ParamsVersion1 memory params) pure returns (bytes memory) {
    CBOR.CBORBuffer memory buf = CBOR.create(64);
    buf.startFixedArray(4);
    buf.writeString(params.location_ref);
    buf.writeUInt64(params.car_size);
    buf.writeBool(params.SkipIpniAnnounce);
    buf.writeBool(params.RemoveUnsealedCopy);
    return buf.data();

}

function serializeContractDealProposal(ContractDealProposal memory dealProposal) pure returns (bytes memory) {
    // FIXME what should the max length be on the buffer?
    CBOR.CBORBuffer memory buf = CBOR.create(64);

    buf.startFixedArray(12);

    buf.writeCid(dealProposal.piece_cid.data);
    buf.writeUInt64(dealProposal.piece_size);
    buf.writeBool(dealProposal.verified_deal);
    buf.writeBytes(dealProposal.client.data);
    buf.writeString(dealProposal.label);
    buf.writeInt64(dealProposal.start_epoch);
    buf.writeInt64(dealProposal.end_epoch);
    buf.writeBytes(dealProposal.storage_price_per_epoch.serializeBigInt());
    buf.writeBytes(dealProposal.provider_collateral.serializeBigInt());
    buf.writeBytes(dealProposal.client_collateral.serializeBigInt());
    buf.writeString(dealProposal.version);
    buf.writeBytes(serializeParamsVersion1(dealProposal.params));
    return buf.data();
}


function deserializeContractDealProposal(bytes memory rawResp) pure returns (ContractDealProposal memory ret) {
    uint byteIdx = 0;
    uint len;

    (len, byteIdx) = rawResp.readFixedArray(byteIdx);
    assert(len == 12);

    (ret.piece_cid.data, byteIdx) = rawResp.readBytes(byteIdx);
    (ret.piece_size, byteIdx) = rawResp.readUInt64(byteIdx);
    (ret.verified_deal, byteIdx) = rawResp.readBool(byteIdx);
    (ret.client.data, byteIdx) = rawResp.readBytes(byteIdx);
//    (ret.provider, byteIdx) = rawResp.readBytes(byteIdx);

//    (ret.label, byteIdx) = rawResp.readString(byteIdx);
//    (ret.start_epoch, byteIdx) = rawResp.readInt64(byteIdx);
//    (ret.end_epoch, byteIdx) = rawResp.readInt64(byteIdx);
//
//    bytes memory storage_price_per_epoch_bytes;
//    (storage_price_per_epoch_bytes, byteIdx) = rawResp.readBytes(byteIdx);
//    ret.storage_price_per_epoch = storage_price_per_epoch_bytes.deserializeBigInt();
//
//    bytes memory provider_collateral_bytes;
//    (provider_collateral_bytes, byteIdx) = rawResp.readBytes(byteIdx);
//    ret.provider_collateral = provider_collateral_bytes.deserializeBigInt();
//
//    bytes memory client_collateral_bytes;
//    (client_collateral_bytes, byteIdx) = rawResp.readBytes(byteIdx);
//    ret.client_collateral = client_collateral_bytes.deserializeBigInt();
//
//    (ret.version, byteIdx) = rawResp.readString(byteIdx);
//    (ret.params, byteIdx) = rawResp.readBytes(byteIdx);

}




