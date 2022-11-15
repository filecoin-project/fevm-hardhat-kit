// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./CommonTypes.sol";

library MinerTypes{
    struct GetOwnerReturn {
        bytes owner;
    }
    struct IsControllingAddressParam {
        bytes addr;
    }
    struct IsControllingAddressReturn {
        bool is_controlling;
    }
    struct GetSectorSizeReturn {
        CommonTypes.SectorSize sector_size;
    }
    struct GetAvailableBalanceReturn {
        int256 available_balance;
    }
    struct GetVestingFundsReturn {
        CommonTypes.VestingFunds[] vesting_funds;
    }

    struct ChangeBeneficiaryParams {
        bytes new_beneficiary;
        int256 new_quota;
        uint64 new_expiration;
    }

    struct GetBeneficiaryReturn {
        CommonTypes.ActiveBeneficiary active;
        CommonTypes.PendingBeneficiaryChange proposed;
    }
}