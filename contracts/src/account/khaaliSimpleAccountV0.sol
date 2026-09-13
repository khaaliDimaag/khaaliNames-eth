// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IkhaaliSimpleAccountV0} from "./IkhaaliSimpleAccountV0.sol";

import {ERC1155Receiver} from "../util/ERC1155Receiver.sol";
import {ERC165} from "../util/ERC165.sol";
import {IERC165} from "../util/IERC165.sol";

contract khaaliSimpleAccountV0 is IkhaaliSimpleAccountV0, ERC1155Receiver {

  address public owner;
  string public khaaliName;


  ////////// ERC Functions //////////

  /// @dev explicit calls to avoid mid-chain hops forgetting to call `super`
  function supportsInterface(bytes4 _id)
    public
    virtual
    view
    override(ERC1155Receiver, IERC165)
    returns (bool)
  {
    return _id == type(IkhaaliSimpleAccountV0).interfaceId
      || ERC1155Receiver.supportsInterface(_id)
      || ERC165.supportsInterface(_id);
  }
}
