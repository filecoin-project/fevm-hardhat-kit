// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./typeLibraries/CommonTypes.sol";
import "./typeLibraries/MinerTypes.sol";

contract MinerAPI{
    bytes owner;
    CommonTypes.ActiveBeneficiary activeBeneficiary;
    bool isBeneficiarySet = false;

    function get_owner() public returns (MinerTypes.GetOwnerReturn memory)  {
        require(owner.length != 0);

        return MinerTypes.GetOwnerReturn(owner);
    }

    function is_controlling_address( MinerTypes.IsControllingAddressParam memory params ) public returns (MinerTypes.IsControllingAddressReturn memory) {
        return MinerTypes.IsControllingAddressReturn(false);
    }

    function get_sector_size() public returns (MinerTypes.GetSectorSizeReturn memory params ) {
        return MinerTypes.GetSectorSizeReturn(CommonTypes.SectorSize._8MiB);
    }

    function get_available_balance( ) public returns (MinerTypes.GetAvailableBalanceReturn memory params ) {
        return MinerTypes.GetAvailableBalanceReturn(10000000000000000000000);
    }

    function get_vesting_funds() public returns (MinerTypes.GetVestingFundsReturn memory params ) {
        CommonTypes.VestingFunds[] memory vesting_funds = new CommonTypes.VestingFunds[](1);
        vesting_funds[0] = CommonTypes.VestingFunds(1668514825, 2000000000000000000000);

        return MinerTypes.GetVestingFundsReturn(vesting_funds);
    }

    function change_beneficiary(MinerTypes.ChangeBeneficiaryParams memory params) public {
        if(!isBeneficiarySet){
            CommonTypes.BeneficiaryTerm memory term = CommonTypes.BeneficiaryTerm(params.new_quota, 0, params.new_expiration);
            activeBeneficiary = CommonTypes.ActiveBeneficiary(params.new_beneficiary, term);
            isBeneficiarySet = true;
        } else {
            activeBeneficiary.beneficiary = params.new_beneficiary;
            activeBeneficiary.term.quota = params.new_quota;
            activeBeneficiary.term.expiration = params.new_expiration;
        }
    }

    function get_beneficiary() public returns (MinerTypes.GetBeneficiaryReturn memory) {
        require(isBeneficiarySet);

        CommonTypes.PendingBeneficiaryChange memory proposed;
        return MinerTypes.GetBeneficiaryReturn(activeBeneficiary, proposed);
    }

}