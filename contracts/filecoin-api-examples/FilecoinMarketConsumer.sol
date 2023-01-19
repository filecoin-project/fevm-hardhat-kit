pragma solidity ^0.8.0;

import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";

contract FilecoinMarketConsumer {
    string public dealLabel;
    uint64 public dealClientActorId;
    uint64 public dealProviderActorId;
    bool public isDealActivated;
    MarketTypes.GetDealDataCommitmentReturn public dealCommitment;
    MarketTypes.GetDealTermReturn public dealTerm;
    MarketTypes.GetDealEpochPriceReturn public dealPricePerEpoch;
    MarketTypes.GetDealClientCollateralReturn public clientCollateral; 
    MarketTypes.GetDealProviderCollateralReturn public providerCollateral;
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
        dealLabel = MarketAPI.getDealLabel(dealId).label;
    }

    function storeDealClient(uint64 dealId) public {
        dealClientActorId = MarketAPI.getDealClient(dealId).client;
    }

    function storeDealClientProvider(uint64 dealId) public {
        dealProviderActorId = MarketAPI.getDealProvider(dealId).provider;
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
        isDealActivated = MarketAPI.getDealVerified(dealId).verified;
    }

    function storeDealActivationStatus(uint64 dealId) public {
        activationStatus = MarketAPI.getDealActivation(dealId);
    }
}