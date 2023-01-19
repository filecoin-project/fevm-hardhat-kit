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

import "../cbor/BigIntCbor.sol";
import "./CommonTypes.sol";

/// @title Filecoin market actor types for Solidity.
/// @author Zondax AG
library MarketTypes {
    bytes constant ActorCode = hex"0005";
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

    struct WithdrawBalanceParams {
        bytes provider_or_client;
        BigInt tokenAmount;
    }

    struct WithdrawBalanceReturn {
        BigInt amount_withdrawn;
    }

    struct GetBalanceReturn {
        BigInt balance;
        BigInt locked;
    }

    struct GetDealDataCommitmentParams {
        uint64 id;
    }

    struct GetDealDataCommitmentReturn {
        bytes data;
        uint64 size;
    }

    struct GetDealClientParams {
        uint64 id;
    }

    struct GetDealClientReturn {
        uint64 client;
    }

    struct GetDealProviderParams {
        uint64 id;
    }

    struct GetDealProviderReturn {
        uint64 provider;
    }

    struct GetDealLabelParams {
        uint64 id;
    }

    struct GetDealLabelReturn {
        string label;
    }

    struct GetDealTermParams {
        uint64 id;
    }

    struct GetDealTermReturn {
        int64 start;
        int64 end;
    }

    struct GetDealEpochPriceParams {
        uint64 id;
    }

    struct GetDealEpochPriceReturn {
        BigInt price_per_epoch;
    }

    struct GetDealClientCollateralParams {
        uint64 id;
    }

    struct GetDealClientCollateralReturn {
        BigInt collateral;
    }

    struct GetDealProviderCollateralParams {
        uint64 id;
    }

    struct GetDealProviderCollateralReturn {
        BigInt collateral;
    }

    struct GetDealVerifiedParams {
        uint64 id;
    }

    struct GetDealVerifiedReturn {
        bool verified;
    }

    struct GetDealActivationParams {
        uint64 id;
    }

    struct GetDealActivationReturn {
        int64 activated;
        int64 terminated;
    }

    struct PublishStorageDealsParams {
        CommonTypes.ClientDealProposal[] deals;
    }

    struct PublishStorageDealsReturn {
        uint64[] ids;
        bytes valid_deals;
    }
}
