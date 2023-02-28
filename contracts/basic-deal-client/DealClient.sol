// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


import { MarketAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import { FilAddresses } from "@zondax/filecoin-solidity/contracts/v0.8/utils/FilAddresses.sol";
import { MarketTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import { AccountTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/AccountTypes.sol";
import { AccountCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/AccountCbor.sol";
import { MarketCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/MarketCbor.sol";
import { BytesCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/BytesCbor.sol";
import { BigNumbers} from "@zondax/filecoin-solidity/contracts/v0.8/external/BigNumbers.sol";
import { ContractDealProposal, ContractDealProposalNew, serializeContractDealProposal, deserializeContractDealProposal} from "./ContractDealProposal.sol";

import "hardhat/console.sol";


contract MockMarket {
    function publish_deal(bytes memory raw_auth_params, address callee) public {
/*
TODO
        // calls standard filecoin receiver on message authentication api method number
        (bool success, ) = callee.call(abi.encodeWithSignature("handle_filecoin_method(uint64,uint64,bytes)", 0, 2643134072, raw_auth_params));
        require(success, "client contract failed to authorize deal publish");
*/
    }
}

struct MarketDealNotifyParams {
    MarketTypes.DealProposal proposal;
    uint64 dealId;
}


struct ProposalIdSet {
    bytes32 proposalId;
    bool valid;
}

struct ProviderSet {
    bytes provider;
    bool valid;
}

contract DealClient {

    using AccountCBOR for *;
    using MarketCBOR for *;

    uint64 constant public AUTHENTICATE_MESSAGE_METHOD_NUM = 2643134072;
    uint64 constant public DATACAP_RECEIVER_HOOK_METHOD_NUM = 3726118371;
    uint64 constant public MARKET_NOTIFY_DEAL_METHOD_NUM = 4186741094;

    mapping(bytes32 => uint256) public dealProposals; // dealID -> dealProposalBytes
    mapping(bytes => ProposalIdSet) public pieceToProposal; // commP -> dealProposalID
    mapping(bytes => ProviderSet) public pieceProviders; // commP -> provider
    mapping(bytes => uint64) public pieceDeals; // commP -> deal ID
    ContractDealProposalNew[] deals; // required to add to avoid CompilerError: Stack too deep, try removing local variables

    event ReceivedDataCap(string received);
    event DealProposalCreate(bytes32 indexed id, uint64 size, bool indexed verified, uint256 price);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // FOR DEMO PURPOSES
    function simpleDealProposal(bytes memory pieceCid, uint64 pieceSize) public {
        ContractDealProposalNew memory deal;
        CommonTypes.Cid memory dealCid = CommonTypes.Cid({
            data: pieceCid
        });

        deal.piece_cid = dealCid;
        deal.piece_size = pieceSize;
        deal.storage_price_per_epoch = uintToBigInt(0);

        makeDealProposal(deal);

    }

    function makeDealProposal(ContractDealProposalNew memory deal) public {
        // TODO: evaluate permissioning here
        require(msg.sender == owner);

        uint256 index = deals.length;
        // creates a unique ID for the deal proposal -- there are many ways to do this
        bytes32 _id = keccak256(abi.encodePacked(block.timestamp, msg.sender, index));
        dealProposals[_id] = index;
        deals.push(deal);

        pieceToProposal[deal.piece_cid.data] = ProposalIdSet(_id, true);

        // writes the proposal metadata to the event log
        emit DealProposalCreate(_id, deal.piece_size, deal.verified_deal, bigIntToUint(deal.storage_price_per_epoch));
    }


    function getDealProposal(bytes32 proposalId) view public returns (ContractDealProposalNew memory) {
        return deals[dealProposals[proposalId]];
    }


    function authenticateMessage(MarketTypes.DealProposal memory proposal) view internal {

        //AccountTypes.AuthenticateMessageParams memory amp = params.deserializeAuthenticateMessageParams();
        //MarketTypes.DealProposal memory proposal = amp.message.deserializeDealProposal();

        require(pieceToProposal[proposal.piece_cid.data].valid, "piece cid must be added before authorizing");
        require(!pieceProviders[proposal.piece_cid.data].valid, "deal failed policy check: provider already claimed this cid");
    }

    function dealNotify(MarketDealNotifyParams memory mdnp) internal {

        MarketTypes.DealProposal memory proposal = mdnp.proposal;

        require(pieceToProposal[proposal.piece_cid.data].valid, "piece cid must be added before authorizing");
        require(!pieceProviders[proposal.piece_cid.data].valid, "deal failed policy check: provider already claimed this cid");

        pieceProviders[proposal.piece_cid.data] = ProviderSet(proposal.provider.data, true);
        pieceDeals[proposal.piece_cid.data] = mdnp.dealId;

    }

    // client - filecoin address byte format
    function addBalance(CommonTypes.FilAddress memory client, uint256 value) public {

        require(msg.sender == owner);

        // TODO:: remove first arg
        // change to ethAddr -> actorId and use that in the below API

        MarketAPI.addBalance(client, value);
    }

    // Below 2 funcs need to go to filecoin.sol
    function uintToBigInt(uint256 value) internal view returns(CommonTypes.BigInt memory) {
        BigNumbers.BigNumber memory bigNumVal = BigNumbers.init(value, false);
        CommonTypes.BigInt memory bigIntVal = CommonTypes.BigInt(bigNumVal.val, bigNumVal.neg);
        return bigIntVal;
    }

    function bigIntToUint(CommonTypes.BigInt memory bigInt) internal view returns (uint256) {
        BigNumbers.BigNumber memory bigNumUint = BigNumbers.init(bigInt.val, bigInt.neg);
        uint256 bigNumExtractedUint = uint256(bytes32(bigNumUint.val));
        return bigNumExtractedUint;
    }

    function withdrawBalance(uint256 value) public returns(uint) {
      return withdrawBalance(FilAddresses.getDelegatedAddress(address(this)), value);
    }

    function withdrawBalance(address client, uint256 value) public returns(uint) {
      return withdrawBalance(FilAddresses.getDelegatedAddress(client), value);
    }

    function withdrawBalance(CommonTypes.FilAddress memory client, uint256 value) public returns(uint) {
        // TODO:: remove first arg
        // change to ethAddr -> actorId and use that in the below API

        require(msg.sender == owner);

        MarketTypes.WithdrawBalanceParams memory params = MarketTypes.WithdrawBalanceParams(client, uintToBigInt(value));
        CommonTypes.BigInt memory ret = MarketAPI.withdrawBalance(params);

        return bigIntToUint(ret);
    }

    function receiveDataCap(bytes memory params) internal {
        emit ReceivedDataCap("DataCap Received!");
        // Add get datacap balance api and store datacap amount
    }


    function handle_filecoin_method(uint64 method, uint64, bytes memory params) public {
        // dispatch methods
/* TODO WHY THIS
        if (method == AUTHENTICATE_MESSAGE_METHOD_NUM) {
            authenticateMessage(params);
        } else if (method == MARKET_NOTIFY_DEAL_METHOD_NUM) {
            dealNotify(params);
        }
        else if (method == DATACAP_RECEIVER_HOOK_METHOD_NUM) {
            receiveDataCap(params);
        } else {
            revert("the filecoin method that was called is not handled");
        }
*/
    }
}
