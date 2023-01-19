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

/// @title Filecoin miner actor types for Solidity.
/// @author Zondax AG
library MinerTypes {
    uint constant GetOwnerMethodNum = 3275365574;
    uint constant ChangeOwnerAddressMethodNum = 1010589339;
    uint constant IsControllingAddressMethodNum = 348244887;
    uint constant GetSectorSizeMethodNum = 3858292296;
    uint constant GetAvailableBalanceMethodNum = 4026106874;
    uint constant GetVestingFundsMethodNum = 1726876304;
    uint constant ChangeBeneficiaryMethodNum = 1570634796;
    uint constant GetBeneficiaryMethodNum = 4158972569;
    uint constant ChangeWorkerAddressMethodNum = 3302309124;
    uint constant ChangePeerIDMethodNum = 1236548004;
    uint constant ChangeMultiaddrsMethodNum = 1063480576;
    uint constant RepayDebtMethodNum = 3665352697;
    uint constant ConfirmChangeWorkerAddressMethodNum = 2354970453;
    uint constant GetPeerIDMethodNum = 2812875329;
    uint constant GetMultiaddrsMethodNum = 1332909407;
    uint constant WithdrawBalanceMethodNum = 2280458852;

    struct GetOwnerReturn {
        bytes owner;
        bytes proposed;
    }

    struct IsControllingAddressParam {
        bytes addr;
    }

    struct IsControllingAddressReturn {
        bool is_controlling;
    }

    struct GetSectorSizeReturn {
        uint64 sector_size;
    }
    struct GetAvailableBalanceReturn {
        BigInt available_balance;
    }

    struct GetVestingFundsReturn {
        CommonTypes.VestingFunds[] vesting_funds;
    }

    struct ChangeBeneficiaryParams {
        bytes new_beneficiary;
        BigInt new_quota;
        uint64 new_expiration;
    }

    struct GetBeneficiaryReturn {
        CommonTypes.ActiveBeneficiary active;
        CommonTypes.PendingBeneficiaryChange proposed;
    }

    struct ChangeWorkerAddressParams {
        bytes new_worker;
        bytes[] new_control_addresses;
    }

    struct ChangePeerIDParams {
        bytes new_id;
    }

    struct ChangeMultiaddrsParams {
        bytes[] new_multi_addrs;
    }

    struct GetPeerIDReturn {
        bytes peer_id;
    }

    struct GetMultiaddrsReturn {
        bytes[] multi_addrs;
    }

    struct WithdrawBalanceParams {
        bytes amount_requested;
    }

    struct WithdrawBalanceReturn {
        bytes amount_withdrawn;
    }
}
