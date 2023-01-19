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
pragma solidity >=0.4.25 <=0.8.17;

import "./types/MarketTypes.sol";
import "./cbor/MarketCbor.sol";
import "./types/CommonTypes.sol";
import "./utils/Misc.sol";
import "./utils/Actor.sol";


library MarketAPI {
    using AddressCBOR for bytes;
    using WithdrawBalanceCBOR for MarketTypes.WithdrawBalanceParams;
    using WithdrawBalanceCBOR for MarketTypes.WithdrawBalanceReturn;
    using GetBalanceCBOR for MarketTypes.GetBalanceReturn;
    using GetDealDataCommitmentCBOR for MarketTypes.GetDealDataCommitmentParams;
    using GetDealDataCommitmentCBOR for MarketTypes.GetDealDataCommitmentReturn;
    using GetDealClientCBOR for MarketTypes.GetDealClientParams;
    using GetDealClientCBOR for MarketTypes.GetDealClientReturn;
    using GetDealProviderCBOR for MarketTypes.GetDealProviderParams;
    using GetDealProviderCBOR for MarketTypes.GetDealProviderReturn;
    using GetDealLabelCBOR for MarketTypes.GetDealLabelParams;
    using GetDealLabelCBOR for MarketTypes.GetDealLabelReturn;
    using GetDealTermCBOR for MarketTypes.GetDealTermParams;
    using GetDealTermCBOR for MarketTypes.GetDealTermReturn;
    using GetDealEpochPriceCBOR for MarketTypes.GetDealEpochPriceParams;
    using GetDealEpochPriceCBOR for MarketTypes.GetDealEpochPriceReturn;
    using GetDealClientCollateralCBOR for MarketTypes.GetDealClientCollateralParams;
    using GetDealClientCollateralCBOR for MarketTypes.GetDealClientCollateralReturn;
    using GetDealProviderCollateralCBOR for MarketTypes.GetDealProviderCollateralParams;
    using GetDealProviderCollateralCBOR for MarketTypes.GetDealProviderCollateralReturn;
    using GetDealVerifiedCBOR for MarketTypes.GetDealVerifiedParams;
    using GetDealVerifiedCBOR for MarketTypes.GetDealVerifiedReturn;
    using GetDealActivationCBOR for MarketTypes.GetDealActivationParams;
    using GetDealActivationCBOR for MarketTypes.GetDealActivationReturn;
    using PublishStorageDealsCBOR for MarketTypes.PublishStorageDealsParams;
    using PublishStorageDealsCBOR for MarketTypes.PublishStorageDealsReturn;

    /// @return the data commitment and size of a deal proposal.
    /// @notice This will be available after the deal is published (whether or not is is activated) and up until some undefined period after it is terminated.
    function getDealDataCommitment(
        MarketTypes.GetDealDataCommitmentParams memory params
    ) internal returns (MarketTypes.GetDealDataCommitmentReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory result = HyperActor.call(
            MarketTypes.GetDealDataCommitmentMethodNum,
            MarketTypes.ActorCode,
            raw_request,
            Misc.CBOR_CODEC
        );

        MarketTypes.GetDealDataCommitmentReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the client of a deal proposal.
    function getDealClient(MarketTypes.GetDealClientParams memory params) internal returns (MarketTypes.GetDealClientReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory result = HyperActor.call(MarketTypes.GetDealClientMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        MarketTypes.GetDealClientReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the provider of a deal proposal.
    function getDealProvider(MarketTypes.GetDealProviderParams memory params) internal returns (MarketTypes.GetDealProviderReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory result = HyperActor.call(MarketTypes.GetDealProviderMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        MarketTypes.GetDealProviderReturn memory response;
        response.deserialize(result);

        return response;
    }
    
}

/// @title This contract is a proxy to the singleton Storage Market actor (address: f05). Calling one of its methods will result in a cross-actor call being performed.
/// @author Zondax AG
library MarketAPIOld {
    using AddressCBOR for bytes;
    using WithdrawBalanceCBOR for MarketTypes.WithdrawBalanceParams;
    using WithdrawBalanceCBOR for MarketTypes.WithdrawBalanceReturn;
    using GetBalanceCBOR for MarketTypes.GetBalanceReturn;
    using GetDealDataCommitmentCBOR for MarketTypes.GetDealDataCommitmentParams;
    using GetDealDataCommitmentCBOR for MarketTypes.GetDealDataCommitmentReturn;
    using GetDealClientCBOR for MarketTypes.GetDealClientParams;
    using GetDealClientCBOR for MarketTypes.GetDealClientReturn;
    using GetDealProviderCBOR for MarketTypes.GetDealProviderParams;
    using GetDealProviderCBOR for MarketTypes.GetDealProviderReturn;
    using GetDealLabelCBOR for MarketTypes.GetDealLabelParams;
    using GetDealLabelCBOR for MarketTypes.GetDealLabelReturn;
    using GetDealTermCBOR for MarketTypes.GetDealTermParams;
    using GetDealTermCBOR for MarketTypes.GetDealTermReturn;
    using GetDealEpochPriceCBOR for MarketTypes.GetDealEpochPriceParams;
    using GetDealEpochPriceCBOR for MarketTypes.GetDealEpochPriceReturn;
    using GetDealClientCollateralCBOR for MarketTypes.GetDealClientCollateralParams;
    using GetDealClientCollateralCBOR for MarketTypes.GetDealClientCollateralReturn;
    using GetDealProviderCollateralCBOR for MarketTypes.GetDealProviderCollateralParams;
    using GetDealProviderCollateralCBOR for MarketTypes.GetDealProviderCollateralReturn;
    using GetDealVerifiedCBOR for MarketTypes.GetDealVerifiedParams;
    using GetDealVerifiedCBOR for MarketTypes.GetDealVerifiedReturn;
    using GetDealActivationCBOR for MarketTypes.GetDealActivationParams;
    using GetDealActivationCBOR for MarketTypes.GetDealActivationReturn;
    using PublishStorageDealsCBOR for MarketTypes.PublishStorageDealsParams;
    using PublishStorageDealsCBOR for MarketTypes.PublishStorageDealsReturn;

    /// @notice Deposits the received value into the balance held in escrow.
    function addBalance(bytes memory provider_or_client) internal {
        bytes memory raw_request = provider_or_client.serializeAddress();

        bytes memory raw_response = Actor.call(MarketTypes.AddBalanceMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        Actor.readRespData(raw_response);

        return;
    }

    /// @notice Attempt to withdraw the specified amount from the balance held in escrow.
    /// @notice If less than the specified amount is available, yields the entire available balance.
    function withdrawBalance(MarketTypes.WithdrawBalanceParams memory params) internal returns (MarketTypes.WithdrawBalanceReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(MarketTypes.WithdrawBalanceMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.WithdrawBalanceReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the escrow balance and locked amount for an address.
    function getBalance(bytes memory addr) internal returns (MarketTypes.GetBalanceReturn memory) {
        bytes memory raw_request = addr.serializeAddress();

        bytes memory raw_response = Actor.call(MarketTypes.GetBalanceMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetBalanceReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the data commitment and size of a deal proposal.
    /// @notice This will be available after the deal is published (whether or not is is activated) and up until some undefined period after it is terminated.
    function getDealDataCommitment(
        MarketTypes.GetDealDataCommitmentParams memory params
    ) internal returns (MarketTypes.GetDealDataCommitmentReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(
            MarketTypes.GetDealDataCommitmentMethodNum,
            MarketTypes.ActorCode,
            raw_request,
            Misc.CBOR_CODEC
        );

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealDataCommitmentReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the client of a deal proposal.
    function getDealClient(MarketTypes.GetDealClientParams memory params) internal returns (MarketTypes.GetDealClientReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(MarketTypes.GetDealClientMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealClientReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the provider of a deal proposal.
    function getDealProvider(MarketTypes.GetDealProviderParams memory params) internal returns (MarketTypes.GetDealProviderReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(MarketTypes.GetDealProviderMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealProviderReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the label of a deal proposal.
    function getDealLabel(MarketTypes.GetDealLabelParams memory params) internal returns (MarketTypes.GetDealLabelReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(MarketTypes.GetDealLabelMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealLabelReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the start epoch and duration (in epochs) of a deal proposal.
    function getDealTerm(MarketTypes.GetDealTermParams memory params) internal returns (MarketTypes.GetDealTermReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(MarketTypes.GetDealTermMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealTermReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the per-epoch price of a deal proposal.
    function getDealTotalPrice(
        MarketTypes.GetDealEpochPriceParams memory params
    ) internal returns (MarketTypes.GetDealEpochPriceReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(MarketTypes.GetDealEpochPriceMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealEpochPriceReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the client collateral requirement for a deal proposal.
    function getDealClientCollateral(
        MarketTypes.GetDealClientCollateralParams memory params
    ) internal returns (MarketTypes.GetDealClientCollateralReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(
            MarketTypes.GetDealClientCollateralMethodNum,
            MarketTypes.ActorCode,
            raw_request,
            Misc.CBOR_CODEC
        );

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealClientCollateralReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the provider collateral requirement for a deal proposal.
    function getDealProviderCollateral(
        MarketTypes.GetDealProviderCollateralParams memory params
    ) internal returns (MarketTypes.GetDealProviderCollateralReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(
            MarketTypes.GetDealProviderCollateralMethodNum,
            MarketTypes.ActorCode,
            raw_request,
            Misc.CBOR_CODEC
        );

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealProviderCollateralReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @return the verified flag for a deal proposal.
    /// @notice Note that the source of truth for verified allocations and claims is the verified registry actor.
    function getDealVerified(MarketTypes.GetDealVerifiedParams memory params) internal returns (MarketTypes.GetDealVerifiedReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(MarketTypes.GetDealVerifiedMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealVerifiedReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @notice Fetches activation state for a deal.
    /// @notice This will be available from when the proposal is published until an undefined period after the deal finishes (either normally or by termination).
    /// @return USR_NOT_FOUND if the deal doesn't exist (yet), or EX_DEAL_EXPIRED if the deal has been removed from state.
    function getDealActivation(
        MarketTypes.GetDealActivationParams memory params
    ) internal returns (MarketTypes.GetDealActivationReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(MarketTypes.GetDealActivationMethodNum, MarketTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.GetDealActivationReturn memory response;
        response.deserialize(result);

        return response;
    }

    /// @notice Publish a new set of storage deals (not yet included in a sector).
    function publishStorageDeals(
        MarketTypes.PublishStorageDealsParams memory params
    ) internal returns (MarketTypes.PublishStorageDealsReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(
            MarketTypes.PublishStorageDealsMethodNum,
            MarketTypes.ActorCode,
            raw_request,
            Misc.CBOR_CODEC
        );

        bytes memory result = Actor.readRespData(raw_response);

        MarketTypes.PublishStorageDealsReturn memory response;
        response.deserialize(result);

        return response;
    }
}
