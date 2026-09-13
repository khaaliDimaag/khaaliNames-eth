// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC1155Receiver} from "./IERC1155Receiver.sol";
import {ERC165} from "./ERC165.sol";
import {IERC165} from "./IERC165.sol";

abstract contract ERC1155Receiver is IERC1155Receiver, ERC165 {

  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  )
    external
    pure
    returns (bytes4)
  {
    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  )
    external
    pure
    returns (bytes4)
  {
    return bytes4(0x0); /// @dev We do not support batch transfers by default
  }

  /// @dev explicit calls to avoid mid-chain hops forgetting to call `super`
  function supportsInterface(bytes4 _id)
    public
    virtual
    view
    override(ERC165, IERC165)
    returns (bool)
  {
    return _id == type(IERC1155Receiver).interfaceId
      || ERC165.supportsInterface(_id);
  }
}
