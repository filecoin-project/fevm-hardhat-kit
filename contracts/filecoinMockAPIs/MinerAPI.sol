// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.4.25 <=0.8.17;

import "./types/MinerTypes.sol";

/// @title This contract is a proxy to a built-in Miner actor. Calling one of its methods will result in a cross-actor call being performed. However, in this mock library, no actual call is performed.
/// @author Zondax AG
/// @dev Methods prefixed with mock_ will not be available in the real library. These methods are merely used to set mock state. Note that this interface will likely break in the future as we align it
//       with that of the real library!
contract MinerAPI {
    string owner;
    bool isBeneficiarySet = false;
    CommonTypes.ActiveBeneficiary activeBeneficiary;
    mapping(CommonTypes.SectorSize => uint64) sectorSizesBytes;

    /// @notice (Mock method) Sets the owner of a Miner on contract deployment, which will be returned via get_owner().
    constructor(string memory _owner) {
        owner = _owner;

        sectorSizesBytes[CommonTypes.SectorSize._2KiB] = 2 << 10;
        sectorSizesBytes[CommonTypes.SectorSize._8MiB] = 8 << 20;
        sectorSizesBytes[CommonTypes.SectorSize._512MiB] = 512 << 20;
        sectorSizesBytes[CommonTypes.SectorSize._32GiB] = 32 << 30;
        sectorSizesBytes[CommonTypes.SectorSize._64GiB] = 2 * (32 << 30);
    }

    /// @notice (Mock method) Sets the owner of a Miner, which will be returned via get_owner().
    function mock_set_owner(string memory addr) public {
        require(bytes(owner).length == 0);
        owner = addr;
    }

    /// @notice Income and returned collateral are paid to this address
    /// @notice This address is also allowed to change the worker address for the miner
    /// @return the owner address of a Miner
    function get_owner()
        public
        view
        returns (MinerTypes.GetOwnerReturn memory)
    {
        require(bytes(owner).length != 0);

        return MinerTypes.GetOwnerReturn(owner);
    }

    /// @param addr New owner address
    /// @notice Proposes or confirms a change of owner address.
    /// @notice If invoked by the current owner, proposes a new owner address for confirmation. If the proposed address is the current owner address, revokes any existing proposal that proposed address.
    function change_owner_address(string memory addr) public {
        owner = addr;
    }

    /// @param params The "controlling" addresses are the Owner, the Worker, and all Control Addresses.
    /// @return Whether the provided address is "controlling".
    function is_controlling_address(
        MinerTypes.IsControllingAddressParam memory params
    ) public pure returns (MinerTypes.IsControllingAddressReturn memory) {
        return MinerTypes.IsControllingAddressReturn(false);
    }

    /// @return the miner's sector size.
    function get_sector_size()
        public
        view
        returns (MinerTypes.GetSectorSizeReturn memory)
    {
        return
            MinerTypes.GetSectorSizeReturn(
                sectorSizesBytes[CommonTypes.SectorSize._8MiB]
            );
    }

    /// @notice This is calculated as actor balance - (vesting funds + pre-commit deposit + initial pledge requirement + fee debt)
    /// @notice Can go negative if the miner is in IP debt.
    /// @return the available balance of this miner.
    function get_available_balance()
        public
        pure
        returns (MinerTypes.GetAvailableBalanceReturn memory)
    {
        return MinerTypes.GetAvailableBalanceReturn(10000000000000000000000);
    }

    /// @return the funds vesting in this miner as a list of (vesting_epoch, vesting_amount) tuples.
    function get_vesting_funds()
        public
        pure
        returns (MinerTypes.GetVestingFundsReturn memory)
    {
        CommonTypes.VestingFunds[]
            memory vesting_funds = new CommonTypes.VestingFunds[](1);
        vesting_funds[0] = CommonTypes.VestingFunds(
            1668514825,
            2000000000000000000000
        );

        return MinerTypes.GetVestingFundsReturn(vesting_funds);
    }

    /// @notice Proposes or confirms a change of beneficiary address.
    /// @notice A proposal must be submitted by the owner, and takes effect after approval of both the proposed beneficiary and current beneficiary, if applicable, any current beneficiary that has time and quota remaining.
    /// @notice See FIP-0029, https://github.com/filecoin-project/FIPs/blob/master/FIPS/fip-0029.md
    function change_beneficiary(
        MinerTypes.ChangeBeneficiaryParams memory params
    ) public {
        if (!isBeneficiarySet) {
            CommonTypes.BeneficiaryTerm memory term = CommonTypes
                .BeneficiaryTerm(params.new_quota, 0, params.new_expiration);
            activeBeneficiary = CommonTypes.ActiveBeneficiary(
                params.new_beneficiary,
                term
            );
            isBeneficiarySet = true;
        } else {
            activeBeneficiary.beneficiary = params.new_beneficiary;
            activeBeneficiary.term.quota = params.new_quota;
            activeBeneficiary.term.expiration = params.new_expiration;
        }
    }

    /// @notice This method is for use by other actors (such as those acting as beneficiaries), and to abstract the state representation for clients.
    /// @notice Retrieves the currently active and proposed beneficiary information.
    function get_beneficiary()
        public
        view
        returns (MinerTypes.GetBeneficiaryReturn memory)
    {
        require(isBeneficiarySet);

        CommonTypes.PendingBeneficiaryChange memory proposed;
        return MinerTypes.GetBeneficiaryReturn(activeBeneficiary, proposed);
    }
}
