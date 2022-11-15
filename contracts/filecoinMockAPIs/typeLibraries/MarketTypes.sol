// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library MarketTypes{
    struct AddBalanceParams {
        bytes provider_or_client;
    }

    struct WithdrawBalanceParams {
        bytes provider_or_client;
        uint256 tokenAmount;
    }

    struct WithdrawBalanceReturn {
        uint256 amount_withdrawn;
    }

    struct GetBalanceReturn {
        uint256 balance;
        uint256 locked;
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
        bytes label;
    }

    struct GetDealTermParams {
        uint64 id;
    }

    struct GetDealTermReturn {
        int64 start;
        int64 end;
    }

    struct GetDealEpochPriceParams {
        int64 id;
    }

    struct GetDealEpochPriceReturn {
        uint256 price_per_epoch;
    }

    struct GetDealClientCollateralParams {
        uint64 id;
    }

    struct GetDealClientCollateralReturn {
        uint256 collateral;
    }

    struct GetDealProviderCollateralParams {
        uint64 id;
    }

    struct GetDealProviderCollateralReturn {
        uint256 collateral;
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
}