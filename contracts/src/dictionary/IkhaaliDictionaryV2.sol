// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IkhaaliDeprecationV1} from "../util/IkhaaliDeprecationV1.sol";

/// @title IkhaaliDictionaryV1
/// @notice Interface for onchain word dictionaries used by khaaliNames
interface IkhaaliDictionaryV2 is IkhaaliDeprecationV1 {

  error DictionaryIndexOutOfBounds (
    address dictionary,
    uint256 length,
    uint256 index
  );

  /// @notice Return the word at a certain index
  /// @param index The zero-based index in the dictionary
  /// @return The word as a string
  function wordAt(uint256 index) external view returns (string memory);

  /// @return The total number of words in the dictionary
  function wordCount() external view returns (uint256);

  /// @return The max byte length for each word
  function wordLength() external view returns (uint256);
}
