// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.4.25 <=0.8.17;

import "./types/MarketTypes.sol";

/// @title This contract is a proxy to the singleton Storage Market actor (address: f05). Calling one of its methods will result in a cross-actor call being performed. However, in this mock library, no actual call is performed.
/// @author Zondax AG
/// @dev Methods prefixed with mock_ will not be available in the real library. These methods are merely used to set mock state. Note that this interface will likely break in the future as we align it
//       with that of the real library!
contract MarketAPI {
    mapping(string => uint256) balances;
    mapping(uint64 => MarketTypes.MockDeal) deals;
    mapping(uint64 => address) userDeals;

    uint64[] internal idArray;
    /// @notice Deposits the received value into the balance held in escrow.
    /// @dev Because this is a mock method, no real balance is being deducted from the caller, nor incremented in the Storage Market actor (f05).
    function add_balance(
        MarketTypes.AddBalanceParams memory params
    ) public payable {
        balances[params.provider_or_client] += msg.value;
    }

    /// @notice Attempt to withdraw the specified amount from the balance held in escrow.
    /// @notice If less than the specified amount is available, yields the entire available balance.
    /// @dev This method should be called by an approved address, but the mock does not check that the caller is an approved party.
    /// @dev Because this is a mock method, no real balance is deposited in the designated address, nor decremented from the Storage Market actor (f05).
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

    /// @return the escrow balance and locked amount for an address.
    function get_balance(
        string memory addr
    ) public view returns (MarketTypes.GetBalanceReturn memory) {
        uint256 actualBalance = balances[addr];

        return MarketTypes.GetBalanceReturn(actualBalance, 0);
    }

    /// @return the data commitment and size of a deal proposal.
    /// @notice This will be available after the deal is published (whether or not is is activated) and up until some undefined period after it is terminated.
    /// @dev set data values correctly, currently returning fixed data, feel free to adjust in your local mock.
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

    function get_deals_of_user() public view returns(MarketTypes.MockDeal[] memory) {
        
        uint k = 0;
        uint j=0;
        for(uint i=0;i<idArray.length;i++){
            if(userDeals[idArray[i]] == msg.sender){
                k++;
            }
        }
        MarketTypes.MockDeal[] memory _deals = new MarketTypes.MockDeal[](k);
        for(uint i=0;i<idArray.length;i++){
            if(userDeals[idArray[i]] == msg.sender){
                _deals[j] = deals[idArray[i]];
                j++;
            }
        }
        return _deals;
    }

    /// @return the client of a deal proposal.
    function get_deal_client(
        MarketTypes.GetDealClientParams memory params
    ) public view returns (MarketTypes.GetDealClientReturn memory) {
        require(deals[params.id].id > 0);

        return MarketTypes.GetDealClientReturn(deals[params.id].client);
    }

    /// @return the provider of a deal proposal.
    function get_deal_provider(
        MarketTypes.GetDealProviderParams memory params
    ) public view returns (MarketTypes.GetDealProviderReturn memory) {
        require(deals[params.id].id > 0);

        return MarketTypes.GetDealProviderReturn(deals[params.id].provider);
    }

    /// @return the label of a deal proposal.
    function get_deal_label(
        MarketTypes.GetDealLabelParams memory params
    ) public view returns (MarketTypes.GetDealLabelReturn memory) {
        require(deals[params.id].id > 0);

        return MarketTypes.GetDealLabelReturn(deals[params.id].label);
    }

    /// @return the start epoch and duration (in epochs) of a deal proposal.
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

    /// @return the per-epoch price of a deal proposal.
    function get_deal_total_price(
        MarketTypes.GetDealEpochPriceParams memory params
    ) public view returns (MarketTypes.GetDealEpochPriceReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealEpochPriceReturn(
                deals[params.id].price_per_epoch
            );
    }

    /// @return the client collateral requirement for a deal proposal.
    function get_deal_client_collateral(
        MarketTypes.GetDealClientCollateralParams memory params
    ) public view returns (MarketTypes.GetDealClientCollateralReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealClientCollateralReturn(
                deals[params.id].client_collateral
            );
    }

    /// @return the provider collateral requirement for a deal proposal.
    function get_deal_provider_collateral(
        MarketTypes.GetDealProviderCollateralParams memory params
    ) public view returns (MarketTypes.GetDealProviderCollateralReturn memory) {
        require(deals[params.id].id > 0);

        return
            MarketTypes.GetDealProviderCollateralReturn(
                deals[params.id].provider_collateral
            );
    }

    /// @return the verified flag for a deal proposal.
    /// @notice Note that the source of truth for verified allocations and claims is the verified registry actor.
    function get_deal_verified(
        MarketTypes.GetDealVerifiedParams memory params
    ) public view returns (MarketTypes.GetDealVerifiedReturn memory) {
        require(deals[params.id].id > 0);

        return MarketTypes.GetDealVerifiedReturn(deals[params.id].verified);
    }

    /// @notice Fetches activation state for a deal.
    /// @notice This will be available from when the proposal is published until an undefined period after the deal finishes (either normally or by termination).
    /// @return USR_NOT_FOUND if the deal doesn't exist (yet), or EX_DEAL_EXPIRED if the deal has been removed from state.
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

    /// @notice Publish a new set of storage deals (not yet included in a sector).
    function publish_storage_deals(bytes memory raw_auth_params, address callee) public {
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

    /// @notice Adds mock deal data to the internal state of this mock.
    /// @dev Feel free to adjust the data here to make it align with deals in your network.
    function add_deals(MarketTypes.MockDeal calldata mockDeal) external {

        // As EVM smart contract has a limited capacity for size (24KiB), we cannot set all deals directly here.
        // Please, take them from docs.
        deals[mockDeal.id] = mockDeal;
        idArray.push(mockDeal.id);
        userDeals[mockDeal.id] = msg.sender;
        // Add or replace more deals here.
    }

    
}
