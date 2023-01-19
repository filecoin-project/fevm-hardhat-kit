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

import "./types/DataCapTypes.sol";
import "./cbor/DataCapCbor.sol";
import "./cbor/BigIntCbor.sol";

import "./utils/Actor.sol";

/// @title This contract is a proxy to the singleton DataCap actor (address: f0X). Calling one of its methods will result in a cross-actor call being performed.
/// @author Zondax AG
library DataCapAPI {
    using BytesCBOR for bytes;
    using GetAllowanceCBOR for DataCapTypes.GetAllowanceParams;
    using TransferCBOR for DataCapTypes.TransferParams;
    using TransferCBOR for DataCapTypes.TransferReturn;
    using TransferFromCBOR for DataCapTypes.TransferFromParams;
    using TransferFromCBOR for DataCapTypes.TransferFromReturn;
    using IncreaseAllowanceCBOR for DataCapTypes.IncreaseAllowanceParams;
    using DecreaseAllowanceCBOR for DataCapTypes.DecreaseAllowanceParams;
    using RevokeAllowanceCBOR for DataCapTypes.RevokeAllowanceParams;
    using BurnCBOR for DataCapTypes.BurnParams;
    using BurnCBOR for DataCapTypes.BurnReturn;
    using BurnFromCBOR for DataCapTypes.BurnFromParams;
    using BurnFromCBOR for DataCapTypes.BurnFromReturn;

    function name() internal returns (string memory) {
        bytes memory raw_request = new bytes(0);

        bytes memory raw_response = Actor.call(DataCapTypes.NameMethodNum, DataCapTypes.ActorCode, raw_request, Misc.NONE_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        return result.deserializeString();
    }

    function symbol() internal returns (string memory) {
        bytes memory raw_request = new bytes(0);

        bytes memory raw_response = Actor.call(DataCapTypes.SymbolMethodNum, DataCapTypes.ActorCode, raw_request, Misc.NONE_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        return result.deserializeString();
    }

    function totalSupply() internal returns (BigInt memory) {
        bytes memory raw_request = new bytes(0);

        bytes memory raw_response = Actor.call(DataCapTypes.TotalSupplyMethodNum, DataCapTypes.ActorCode, raw_request, Misc.NONE_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        return result.deserializeBigNum();
    }

    function balance(bytes memory addr) internal returns (BigInt memory) {
        bytes memory raw_request = addr.serializeAddress();

        bytes memory raw_response = Actor.call(DataCapTypes.BalanceOfMethodNum, DataCapTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        return result.deserializeBigNum();
    }

    function allowance(DataCapTypes.GetAllowanceParams memory params) internal returns (BigInt memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(DataCapTypes.AllowanceMethodNum, DataCapTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        return result.deserializeBigNum();
    }

    function transfer(DataCapTypes.TransferParams memory params) internal returns (DataCapTypes.TransferReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(DataCapTypes.TransferMethodNum, DataCapTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        DataCapTypes.TransferReturn memory response;
        response.deserialize(result);

        return response;
    }

    function transferFrom(DataCapTypes.TransferFromParams memory params) internal returns (DataCapTypes.TransferFromReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(DataCapTypes.TransferFromMethodNum, DataCapTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        DataCapTypes.TransferFromReturn memory response;
        response.deserialize(result);

        return response;
    }

    function increaseAllowance(DataCapTypes.IncreaseAllowanceParams memory params) internal returns (BigInt memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(
            DataCapTypes.IncreaseAllowanceMethodNum,
            DataCapTypes.ActorCode,
            raw_request,
            Misc.CBOR_CODEC
        );

        bytes memory result = Actor.readRespData(raw_response);

        return result.deserializeBigNum();
    }

    function decreaseAllowance(DataCapTypes.DecreaseAllowanceParams memory params) internal returns (BigInt memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(
            DataCapTypes.DecreaseAllowanceMethodNum,
            DataCapTypes.ActorCode,
            raw_request,
            Misc.CBOR_CODEC
        );

        bytes memory result = Actor.readRespData(raw_response);

        return result.deserializeBigNum();
    }

    function revokeAllowance(DataCapTypes.RevokeAllowanceParams memory params) internal returns (BigInt memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(DataCapTypes.RevokeAllowanceMethodNum, DataCapTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        return result.deserializeBigNum();
    }

    function burn(DataCapTypes.BurnParams memory params) internal returns (DataCapTypes.BurnReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(DataCapTypes.BurnMethodNum, DataCapTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        DataCapTypes.BurnReturn memory response;
        response.deserialize(result);

        return response;
    }

    function burnFrom(DataCapTypes.BurnFromParams memory params) internal returns (DataCapTypes.BurnFromReturn memory) {
        bytes memory raw_request = params.serialize();

        bytes memory raw_response = Actor.call(DataCapTypes.BurnFromMethodNum, DataCapTypes.ActorCode, raw_request, Misc.CBOR_CODEC);

        bytes memory result = Actor.readRespData(raw_response);

        DataCapTypes.BurnFromReturn memory response;
        response.deserialize(result);

        return response;
    }
}
