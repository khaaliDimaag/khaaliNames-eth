// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IkhaaliDictionaryV2} from "./IkhaaliDictionaryV2.sol";
import {khaaliDeprecationV1} from "../util/khaaliDeprecationV1.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";

contract khaaliDictionaryV2 is khaaliDeprecationV1 {

  string public name;

  constructor(
    uint64 _major, uint64 _minor, uint128 _patch,
    string memory _name
  )
    khaaliDeprecationV1(_major, _minor, _patch)
  {
    name = _name;
  }
}
