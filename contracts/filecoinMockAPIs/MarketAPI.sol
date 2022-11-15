// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./typeLibraries/CommonTypes.sol";

contract MarketAPI{
    mapping(bytes => uint256) balances;

    function add_balance(MarketTypes.AddBalanceParams memory params) public payable {
        balances[params.provider_or_client] += msg.value;
    }

    function withdraw_balance(MarketTypes.WithdrawBalanceParams memory params) public returns (MarketTypes.WithdrawBalanceReturn memory) {
        return MarketTypes.WithdrawBalanceReturn(1);
    }

    function get_balance(bytes memory addr) public returns (MarketTypes.GetBalanceReturn memory) {
        uint256 actualBalance = balances[addr];

        return MarketTypes.GetBalanceReturn(actualBalance, 0);
    }

    function get_deal_data_commitment(MarketTypes.GetDealDataCommitmentParams memory params) public returns (MarketTypes.GetDealDataCommitmentReturn memory) {
        return MarketTypes.GetDealDataCommitmentReturn(bytes("0x111111"), 10000);
    }

    function get_deal_client(MarketTypes.GetDealClientParams memory params) public returns (MarketTypes.GetDealClientReturn memory) {
        return MarketTypes.GetDealClientReturn(1);
    }

    function get_deal_provider(MarketTypes.GetDealProviderParams memory params) public returns (MarketTypes.GetDealProviderReturn memory) {
        return MarketTypes.GetDealProviderReturn(1);
    }

    function get_deal_label(MarketTypes.GetDealLabelParams memory params) public returns (MarketTypes.GetDealLabelReturn memory) {
        return MarketTypes.GetDealLabelReturn(bytes("0x111111"));
    }

    function get_deal_term(MarketTypes.GetDealTermParams memory params) public returns (MarketTypes.GetDealTermReturn memory) {
        return MarketTypes.GetDealTermReturn(1668428301, 1699964301);
    }

    function get_deal_epoch_price(MarketTypes.GetDealEpochPriceParams memory params) public returns (MarketTypes.GetDealEpochPriceReturn memory) {
        return MarketTypes.GetDealEpochPriceReturn(1);
    }

    function get_deal_client_collateral(MarketTypes.GetDealClientCollateralParams memory params) public returns (MarketTypes.GetDealClientCollateralReturn memory) {
        return MarketTypes.GetDealClientCollateralReturn(1);
    }

    function get_deal_provider_collateral(MarketTypes.GetDealProviderCollateralParams memory params) public returns (MarketTypes.GetDealProviderCollateralReturn memory) {
        return MarketTypes.GetDealProviderCollateralReturn(1);
    }

    function get_deal_verified(MarketTypes.GetDealVerifiedParams memory params) public returns (MarketTypes.GetDealVerifiedReturn memory) {
        return MarketTypes.GetDealVerifiedReturn(true);
    }

    function get_deal_activation(MarketTypes.GetDealActivationParams memory params) public returns (MarketTypes.GetDealActivationReturn memory) {
        return MarketTypes.GetDealActivationReturn(1, 1);
    }
}