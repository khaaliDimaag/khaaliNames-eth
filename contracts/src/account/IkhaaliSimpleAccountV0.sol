// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IERC1155Receiver} from "../util/IERC1155Receiver.sol";
import {IkhaaliDeprecationV1} from "../util/IkhaaliDeprecationV1.sol";

interface IkhaaliSimpleAccountV0 is IERC1155Receiver, IkhaaliDeprecationV1 {

  ////////// Getter Functions //////////

  function owner() external view returns (address);

  function khaaliName() external view returns (string memory);


  ////////// Admin / Owner Functions //////////

  function deposit() external payable;

  function withdraw() external;

}
