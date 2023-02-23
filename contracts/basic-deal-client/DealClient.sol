// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {specific_authenticate_message_params_parse, specific_deal_proposal_cbor_parse} from "./CBORParse.sol";

contract DealClient {
  uint64 constant public AUTHORIZE_MESSAGE_METHOD_NUM = 2643134072;
  uint64 constant public DATACAP_RECEIVER_HOOK_METHOD_NUM = 3726118371;


  mapping(bytes => bool) public cidSet;
  mapping(bytes => uint) public cidSizes;
  mapping(bytes => mapping(bytes => bool)) public cidProviders;

  mapping(bytes32 => bytes) public proposals;

  event ReceivedDataCap(string received);
  event DealProposalCreate(bytes32 indexed id, bytes size, bool indexed verified, uint price);

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function addCID(bytes calldata cidraw, uint size) public {
    require(msg.sender == owner);
    cidSet[cidraw] = true;
    cidSizes[cidraw] = size;
  }

  function policyOK(bytes calldata cidraw, bytes calldata provider) internal view returns (bool) {
    bool alreadyStoring = cidProviders[cidraw][provider];
    return !alreadyStoring;
  }

  function authorizeData(bytes calldata cidraw, bytes calldata provider, uint size) public {
    // if (msg.sender != f05) return;
    require(cidSet[cidraw], "cid must be added before authorizing");
    require(cidSizes[cidraw] == size, "data size must match expected");
    require(policyOK(cidraw, provider), "deal failed policy check: has provider already claimed this cid?");

    cidProviders[cidraw][provider] = true;
  }

  function handle_filecoin_method(uint64 method, uint64, bytes calldata params) public {
    if (method == AUTHORIZE_MESSAGE_METHOD_NUM) {
      return;
      bytes calldata deal_proposal_cbor_bytes = specific_authenticate_message_params_parse(params);
      (bytes calldata cidraw, bytes calldata provider, uint size) = specific_deal_proposal_cbor_parse(deal_proposal_cbor_bytes);
      authorizeData(cidraw, provider, size);
    } else if (method == DATACAP_RECEIVER_HOOK_METHOD_NUM) {
      emit ReceivedDataCap("DataCap Received!");
    } else {
      revert("the filecoin method that was called is not handled");
    }
  }

  function makeDealProposal(bytes memory _deal, bytes memory size, bool verified, uint price) public returns (bytes32) {
    bytes32 _id = keccak256(abi.encodePacked(block.timestamp, msg.sender));
    proposals[_id] = _deal;

    emit DealProposalCreate(_id, size, verified, price);

    return _id;
  }

  function getDealProposal(bytes32 id) public view returns(bytes memory) {
    return proposals[id];
  }

  function publish_deal(bytes memory raw_auth_params, address callee) public {
    // calls standard filecoin receiver on message authentication api method number
    (bool success, ) = callee.call(abi.encodeWithSignature("handle_filecoin_method(uint64,uint64,bytes)", 0, 2643134072, raw_auth_params));
    require(success, "client contract failed to authorize deal publish");
  }
}

