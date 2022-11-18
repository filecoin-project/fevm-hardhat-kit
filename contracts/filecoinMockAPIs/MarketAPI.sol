// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "./typeLibraries/MarketTypes.sol";

contract MarketAPI {
    mapping(string => uint256) balances;
    mapping(uint64 => MarketTypes.MockDeal) deals;

    constructor() {
        generate_deal_mocks();
    }

    function add_balance(
        MarketTypes.AddBalanceParams memory params
    ) public payable {
        balances[params.provider_or_client] += msg.value;
    }

    function withdraw_balance(
        MarketTypes.WithdrawBalanceParams memory params
    ) public returns (MarketTypes.WithdrawBalanceReturn memory) {
        uint256 tmp = balances[params.provider_or_client];
        if (balances[params.provider_or_client] >= params.tokenAmount) {
            balances[params.provider_or_client] -= params.tokenAmount;
            tmp = params.tokenAmount;
        } else {
            balances[params.provider_or_client] = 0;
        }

        return MarketTypes.WithdrawBalanceReturn(tmp);
    }

    function get_balance(
        string memory addr
    ) public view returns (MarketTypes.GetBalanceReturn memory) {
        uint256 actualBalance = balances[addr];

        return MarketTypes.GetBalanceReturn(actualBalance, 0);
    }

    // FIXME set data values correctly
    function get_deal_data_commitment(
        MarketTypes.GetDealDataCommitmentParams memory params
    ) public view returns (MarketTypes.GetDealDataCommitmentReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealDataCommitmentReturn(
                bytes("0x111111"),
                deals[params.id].size
            );
    }

    function get_deal_client(
        MarketTypes.GetDealClientParams memory params
    ) public view returns (MarketTypes.GetDealClientReturn memory) {
        require(deals[params.id].id > 0);

        return MarketTypes.GetDealClientReturn(deals[params.id].client);
    }

    function get_deal_provider(
        MarketTypes.GetDealProviderParams memory params
    ) public view returns (MarketTypes.GetDealProviderReturn memory) {
        require(deals[params.id].id > 0);

        return MarketTypes.GetDealProviderReturn(deals[params.id].provider);
    }

    function get_deal_label(
        MarketTypes.GetDealLabelParams memory params
    ) public view returns (MarketTypes.GetDealLabelReturn memory) {
        require(deals[params.id].id > 0);

        return MarketTypes.GetDealLabelReturn(deals[params.id].label);
    }

    function get_deal_term(
        MarketTypes.GetDealTermParams memory params
    ) public view returns (MarketTypes.GetDealTermReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealTermReturn(
                deals[params.id].start,
                deals[params.id].end
            );
    }

    function get_deal_epoch_price(
        MarketTypes.GetDealEpochPriceParams memory params
    ) public view returns (MarketTypes.GetDealEpochPriceReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealEpochPriceReturn(
                deals[params.id].price_per_epoch
            );
    }

    function get_deal_client_collateral(
        MarketTypes.GetDealClientCollateralParams memory params
    ) public view returns (MarketTypes.GetDealClientCollateralReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealClientCollateralReturn(
                deals[params.id].client_collateral
            );
    }

    function get_deal_provider_collateral(
        MarketTypes.GetDealProviderCollateralParams memory params
    ) public view returns (MarketTypes.GetDealProviderCollateralReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealProviderCollateralReturn(
                deals[params.id].provider_collateral
            );
    }

    function get_deal_verified(
        MarketTypes.GetDealVerifiedParams memory params
    ) public view returns (MarketTypes.GetDealVerifiedReturn memory) {
        require(deals[params.id].id > 0);

        return MarketTypes.GetDealVerifiedReturn(deals[params.id].verified);
    }

    function get_deal_activation(
        MarketTypes.GetDealActivationParams memory params
    ) public view returns (MarketTypes.GetDealActivationReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealActivationReturn(
                deals[params.id].activated,
                deals[params.id].terminated
            );
    }

    function publish_deal(bytes memory raw_auth_params, address callee) public {
        // calls standard filecoin receiver on message authentication api method number
        (bool success, ) = callee.call(
            abi.encodeWithSignature(
                "handle_filecoin_method(uint64,uint64,bytes)",
                0,
                2643134072,
                raw_auth_params
            )
        );
        require(success, "client contract failed to authorize deal publish");
    }

    function generate_deal_mocks() internal {
        MarketTypes.MockDeal memory deal_67;
        deal_67.id = 67;
        deal_67
            .cid = "baga6ea4seaqlkg6mss5qs56jqtajg5ycrhpkj2b66cgdkukf2qjmmzz6ayksuci";
        deal_67.size = 8388608;
        deal_67.verified = false;
        deal_67.client = "t01109";
        deal_67.provider = "t01113";
        deal_67.label = "mAXCg5AIg8YBXbFjtdBy1iZjpDYAwRSt0elGLF5GvTqulEii1VcM";
        deal_67.start = 25245;
        deal_67.end = 545150;
        deal_67.price_per_epoch = 1100000000000;
        deal_67.provider_collateral = 0;
        deal_67.client_collateral = 0;
        deal_67.activated = 1;
        deal_67.terminated = 0;

        deals[deal_67.id] = deal_67;

        // As EVM smart contract has a limited capacity for size, we cannot set all deals directly here.
        // Please, take them from docs.

        // Add or replace more deals here.
    }
}