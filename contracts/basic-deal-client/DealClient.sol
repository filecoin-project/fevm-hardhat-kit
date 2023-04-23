// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import {AccountTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/AccountTypes.sol";
import {CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import {AccountCBOR} from "@zondax/filecoin-solidity/contracts/v0.8/cbor/AccountCbor.sol";
import {MarketCBOR} from "@zondax/filecoin-solidity/contracts/v0.8/cbor/MarketCbor.sol";
import {BytesCBOR} from "@zondax/filecoin-solidity/contracts/v0.8/cbor/BytesCbor.sol";
import {BigNumbers, BigNumber} from "@zondax/solidity-bignumber/src/BigNumbers.sol";
import {BigInts} from "@zondax/filecoin-solidity/contracts/v0.8/utils/BigInts.sol";
import {CBOR} from "solidity-cborutils/contracts/CBOR.sol";
import {Misc} from "@zondax/filecoin-solidity/contracts/v0.8/utils/Misc.sol";
import {FilAddresses} from "@zondax/filecoin-solidity/contracts/v0.8/utils/FilAddresses.sol";

using CBOR for CBOR.CBORBuffer;

struct RequestId {
  bytes32 requestId;
  bool valid;
}

struct RequestIdx {
  uint256 idx;
  bool valid;
}

struct ProviderSet {
  bytes provider;
  bool valid;
}

// User request for this contract to make a deal. This structure is modelled after Filecoin's Deal
// Proposal, but leaves out the provider, since any provider can pick up a deal broadcast by this
// contract.
struct DealRequest {
  bytes piece_cid;
  uint64 piece_size;
  bool verified_deal;
  string label;
  int64 start_epoch;
  int64 end_epoch;
  uint256 storage_price_per_epoch;
  uint256 provider_collateral;
  uint256 client_collateral;
  uint64 extra_params_version;
  ExtraParamsV1 extra_params;
}

// Extra parameters associated with the deal request. These are off-protocol flags that
// the storage provider will need.
struct ExtraParamsV1 {
  string location_ref;
  uint64 car_size;
  bool skip_ipni_announce;
  bool remove_unsealed_copy;
}

function serializeExtraParamsV1(
  ExtraParamsV1 memory params
) pure returns (bytes memory) {
  CBOR.CBORBuffer memory buf = CBOR.create(64);
  buf.startFixedArray(4);
  buf.writeString(params.location_ref);
  buf.writeUInt64(params.car_size);
  buf.writeBool(params.skip_ipni_announce);
  buf.writeBool(params.remove_unsealed_copy);
  return buf.data();
}

contract DealClient {
  using AccountCBOR for *;
  using MarketCBOR for *;

  uint64 public constant AUTHENTICATE_MESSAGE_METHOD_NUM = 2643134072;
  uint64 public constant DATACAP_RECEIVER_HOOK_METHOD_NUM = 3726118371;
  uint64 public constant MARKET_NOTIFY_DEAL_METHOD_NUM = 4186741094;
  address public constant MARKET_ACTOR_ETH_ADDRESS =
    address(0xff00000000000000000000000000000000000005);
  address public constant DATACAP_ACTOR_ETH_ADDRESS =
    address(0xfF00000000000000000000000000000000000007);


  enum Status {
    None,
    RequestSubmitted,
    DealPublished,
    DealActivated,
    DealTerminated
  }

  mapping(bytes32 => RequestIdx) public dealRequestIdx; // contract deal id -> deal index
  DealRequest[] public dealRequests;

  mapping(bytes => RequestId) public pieceRequests; // commP -> dealProposalID
  mapping(bytes => ProviderSet) public pieceProviders; // commP -> provider
  mapping(bytes => uint64) public pieceDeals; // commP -> deal ID
  mapping(bytes => Status) public pieceStatus;

  event ReceivedDataCap(string received);
  event DealProposalCreate(
    bytes32 indexed id,
    uint64 size,
    bool indexed verified,
    uint256 price
  );

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function getProviderSet(
    bytes calldata cid
  ) public view returns (ProviderSet memory) {
    return pieceProviders[cid];
  }

  function getProposalIdSet(
    bytes calldata cid
  ) public view returns (RequestId memory) {
    return pieceRequests[cid];
  }

  function dealsLength() public view returns (uint256) {
    return dealRequests.length;
  }

  function getDealByIndex(
    uint256 index
  ) public view returns (DealRequest memory) {
    return dealRequests[index];
  }

  function makeDealProposal(
    DealRequest calldata deal
  ) public returns (bytes32) {
    require(msg.sender == owner);

    if (pieceStatus[deal.piece_cid] == Status.DealPublished ||
        pieceStatus[deal.piece_cid] == Status.DealActivated) {
      revert("deal with this pieceCid already published");
    }

    uint256 index = dealRequests.length;
    dealRequests.push(deal);

    // creates a unique ID for the deal proposal -- there are many ways to do this
    bytes32 id = keccak256(
      abi.encodePacked(block.timestamp, msg.sender, index)
    );
    dealRequestIdx[id] = RequestIdx(index, true);

    pieceRequests[deal.piece_cid] = RequestId(id, true);
    pieceStatus[deal.piece_cid] = Status.RequestSubmitted;

    // writes the proposal metadata to the event log
    emit DealProposalCreate(
      id,
      deal.piece_size,
      deal.verified_deal,
      deal.storage_price_per_epoch
    );

    return id;
  }

  // helper function to get deal request based from id
  function getDealRequest(
    bytes32 requestId
  ) internal view returns (DealRequest memory) {
    RequestIdx memory ri = dealRequestIdx[requestId];
    require(ri.valid, "proposalId not available");
    return dealRequests[ri.idx];
  }

  // Returns a CBOR-encoded DealProposal.
  function getDealProposal(
    bytes32 proposalId
  ) public view returns (bytes memory) {
    DealRequest memory deal = getDealRequest(proposalId);

    MarketTypes.DealProposal memory ret;
    ret.piece_cid = CommonTypes.Cid(deal.piece_cid);
    ret.piece_size = deal.piece_size;
    ret.verified_deal = deal.verified_deal;
    ret.client = FilAddresses.fromEthAddress(address(this));
    // Set a dummy provider. The provider that picks up this deal will need to set its own address.
    ret.provider = FilAddresses.fromActorID(0);
    ret.label = CommonTypes.DealLabel(bytes(deal.label), true);
    ret.start_epoch = CommonTypes.ChainEpoch.wrap(deal.start_epoch);
    ret.end_epoch = CommonTypes.ChainEpoch.wrap(deal.end_epoch);
    ret.storage_price_per_epoch = BigInts.fromUint256(
      deal.storage_price_per_epoch
    );
    ret.provider_collateral = BigInts.fromUint256(deal.provider_collateral);
    ret.client_collateral = BigInts.fromUint256(deal.client_collateral);

    return MarketCBOR.serializeDealProposal(ret);
  }

  function getExtraParams(
    bytes32 proposalId
  ) public view returns (bytes memory extra_params) {
    DealRequest memory deal = getDealRequest(proposalId);
    return serializeExtraParamsV1(deal.extra_params);
  }


  // authenticateMessage is the callback from the market actor into the contract
  // as part of PublishStorageDeals. This message holds the deal proposal from the
  // miner, which needs to be validated by the contract in accordance with the
  // deal requests made and the contract's own policies
  // @params - cbor byte array of AccountTypes.AuthenticateMessageParams
  function authenticateMessage(bytes memory params) internal view {
    require(
      msg.sender == MARKET_ACTOR_ETH_ADDRESS,
      "msg.sender needs to be market actor f05"
    );

    AccountTypes.AuthenticateMessageParams memory amp = params
    .deserializeAuthenticateMessageParams();
    MarketTypes.DealProposal memory proposal = MarketCBOR.deserializeDealProposal(
      amp.message
    );

    bytes memory pieceCid = proposal.piece_cid.data;
    require(pieceRequests[pieceCid].valid, "piece cid must be added before authorizing");
    require(!pieceProviders[pieceCid].valid, "deal failed policy check: provider already claimed this cid");

    DealRequest memory req = getDealRequest(pieceRequests[pieceCid].requestId);
    require(proposal.verified_deal == req.verified_deal, "verified_deal param mismatch");
    (uint256 proposalStoragePricePerEpoch, bool storagePriceConverted) = BigInts.toUint256(proposal.storage_price_per_epoch);
    require(!storagePriceConverted, "Issues converting uint256 to BigInt, may not have accurate values");
    (uint256 proposalClientCollateral, bool collateralConverted) = BigInts.toUint256(proposal.client_collateral);
    require(!collateralConverted, "Issues converting uint256 to BigInt, may not have accurate values");
    require(proposalStoragePricePerEpoch <= req.storage_price_per_epoch, "storage price greater than request amount");
    require(proposalClientCollateral <= req.client_collateral, "client collateral greater than request amount");

  }

  // dealNotify is the callback from the market actor into the contract at the end
  // of PublishStorageDeals. This message holds the previously approved deal proposal
  // and the associated dealID. The dealID is stored as part of the contract state
  // and the completion of this call marks the success of PublishStorageDeals
  // @params - cbor byte array of MarketDealNotifyParams
  function dealNotify(bytes memory params) internal {
    require(
      msg.sender == MARKET_ACTOR_ETH_ADDRESS,
      "msg.sender needs to be market actor f05"
    );

    MarketTypes.MarketDealNotifyParams memory mdnp = MarketCBOR.deserializeMarketDealNotifyParams(
      params
    );
    MarketTypes.DealProposal memory proposal = MarketCBOR.deserializeDealProposal(
      mdnp.dealProposal
    );

    // These checks prevent race conditions between the authenticateMessage and
    // marketDealNotify calls where someone could have 2 of the same deal proposals
    // within the same PSD msg, which would then get validated by authenticateMessage
    // However, only one of those deals should be allowed
    require(
      pieceRequests[proposal.piece_cid.data].valid,
      "piece cid must be added before authorizing"
    );
    require(
      !pieceProviders[proposal.piece_cid.data].valid,
      "deal failed policy check: provider already claimed this cid"
    );

    pieceProviders[proposal.piece_cid.data] = ProviderSet(
      proposal.provider.data,
      true
    );
    pieceDeals[proposal.piece_cid.data] = mdnp.dealId;
    pieceStatus[proposal.piece_cid.data] = Status.DealPublished;
  }


  // This function can be called/smartly polled to retrieve the deal activation status
  // associated with provided pieceCid and update the contract state based on that
  // info
  // @pieceCid - byte representation of pieceCid
  function updateActivationStatus(bytes memory pieceCid) public {
    require(pieceDeals[pieceCid] > 0, "no deal published for this piece cid");

    MarketTypes.GetDealActivationReturn memory ret = MarketAPI.getDealActivation(pieceDeals[pieceCid]);
    if (CommonTypes.ChainEpoch.unwrap(ret.terminated) > 0) {
      pieceStatus[pieceCid] = Status.DealTerminated;
    } else if (CommonTypes.ChainEpoch.unwrap(ret.activated) > 0) {
      pieceStatus[pieceCid] = Status.DealActivated;
    }
  }

  // addBalance funds the builtin storage market actor's escrow
  // with funds from the contract's own balance
  // @value - amount to be added in escrow in attoFIL
  function addBalance(uint256 value) public {
    require(msg.sender == owner);
    MarketAPI.addBalance(FilAddresses.fromEthAddress(address(this)), value);
  }

  // This function attempts to withdraw the specified amount from the contract addr's escrow balance
  // If less than the given amount is available, the full escrow balance is withdrawn
  // @client - Eth address where the balance is withdrawn to. This can be the contract address or an external address
  // @value - amount to be withdrawn in escrow in attoFIL
  function withdrawBalance(
    address client,
    uint256 value
  ) public returns (uint) {
    require(msg.sender == owner);

    MarketTypes.WithdrawBalanceParams memory params = MarketTypes
    .WithdrawBalanceParams(
      FilAddresses.fromEthAddress(client),
      BigInts.fromUint256(value)
    );
    CommonTypes.BigInt memory ret = MarketAPI.withdrawBalance(params);

    (uint256 withdrawBalanceAmount, bool withdrawBalanceConverted) = BigInts.toUint256(ret);
    require(withdrawBalanceConverted, "Problems converting withdraw balance into Big Int, may cause an overflow");

    return withdrawBalanceAmount;
  }

  function receiveDataCap(bytes memory params) internal {
    require(
      msg.sender == DATACAP_ACTOR_ETH_ADDRESS,
      "msg.sender needs to be datacap actor f07"
    );
    emit ReceivedDataCap("DataCap Received!");
    // Add get datacap balance api and store datacap amount
  }


  // handle_filecoin_method is the universal entry point for any evm based
  // actor for a call coming from a builtin filecoin actor
  // @method - FRC42 method number for the specific method hook
  // @params - CBOR encoded byte array params
  function handle_filecoin_method(
    uint64 method,
    uint64,
    bytes memory params
  ) public returns (uint32, uint64, bytes memory) {
    bytes memory ret;
    uint64 codec;
    // dispatch methods
    if (method == AUTHENTICATE_MESSAGE_METHOD_NUM) {
      authenticateMessage(params);
      // If we haven't reverted, we should return a CBOR true to indicate that verification passed.
      CBOR.CBORBuffer memory buf = CBOR.create(1);
      buf.writeBool(true);
      ret = buf.data();
      codec = Misc.CBOR_CODEC;
    } else if (method == MARKET_NOTIFY_DEAL_METHOD_NUM) {
      dealNotify(params);
    } else if (method == DATACAP_RECEIVER_HOOK_METHOD_NUM) {
      receiveDataCap(params);
    } else {
      revert("the filecoin method that was called is not handled");
    }
    return (0, codec, ret);
  }
}
