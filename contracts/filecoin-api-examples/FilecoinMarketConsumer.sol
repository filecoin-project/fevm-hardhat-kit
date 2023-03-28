pragma solidity ^0.8.0;

import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import {CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";

contract FilecoinMarketConsumer {
    string public dealLabel;
    uint64 public dealClientActorId;
    uint64 public dealProviderActorId;
    bool public isDealActivated;
    MarketTypes.GetDealDataCommitmentReturn public dealCommitment;
    MarketTypes.GetDealTermReturn public dealTerm;
    CommonTypes.BigInt public dealPricePerEpoch;
    CommonTypes.BigInt public clientCollateral; 
    CommonTypes.BigInt public providerCollateral;
    MarketTypes.GetDealActivationReturn public activationStatus;

    function storeAll(uint64 dealId) public {
        storeDealLabel(dealId);
        storeDealClient(dealId);
        storeDealClientProvider(dealId);
        storeDealCommitment(dealId);
        storeDealTerm(dealId);
        storeDealTotalPrice(dealId);
        storeClientCollateral(dealId);
        storeProviderCollateral(dealId);
        storeDealVerificaton(dealId);
        storeDealActivationStatus(dealId);
    } 

    function storeDealLabel(uint64 dealId) public  {
        dealLabel = MarketAPI.getDealLabel(dealId);
    }

    function storeDealClient(uint64 dealId) public {
        dealClientActorId = MarketAPI.getDealClient(dealId);
    }

    function storeDealClientProvider(uint64 dealId) public {
        dealProviderActorId = MarketAPI.getDealProvider(dealId);
    }

    function storeDealCommitment(uint64 dealId) public {
        dealCommitment = MarketAPI.getDealDataCommitment(dealId);
    }

    function storeDealTerm(uint64 dealId) public {
        dealTerm = MarketAPI.getDealTerm(dealId);
    }

    function storeDealTotalPrice(uint64 dealId) public {
       dealPricePerEpoch = MarketAPI.getDealTotalPrice(dealId);
    }

    function storeClientCollateral(uint64 dealId) public {
        clientCollateral = MarketAPI.getDealClientCollateral(dealId);
    }
    
    function storeProviderCollateral(uint64 dealId) public {
        providerCollateral = MarketAPI.getDealProviderCollateral(dealId);
    }

    function storeDealVerificaton(uint64 dealId) public {
        isDealActivated = MarketAPI.getDealVerified(dealId);
    }

    function storeDealActivationStatus(uint64 dealId) public {
        activationStatus = MarketAPI.getDealActivation(dealId);
    }
}