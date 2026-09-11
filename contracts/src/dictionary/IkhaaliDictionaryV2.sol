// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IkhaaliDeprecationV1} from "../util/IkhaaliDeprecationV1.sol";

struct khaaliDictionary {
  address LOCATION; /// @dev we use SSTORE2 to store the dictionary data
  uint64 WORD_COUNT;
  uint32 WORD_LENGTH; /// @dev length of each word in bytes (padded)
  string NAME;
}

/// @title IkhaaliDictionaryV2
/// @notice Interface for onchain word dictionaries used by khaaliNames
/// @dev Consider multi pointer dictionaries for V3
interface IkhaaliDictionaryV2 is IkhaaliDeprecationV1 {

  ////////// Errors //////////

  error DictionaryNeedsName();
  error WordLengthMustNotBeZero();
  error DictionaryMustNotBeEmpty();
  error DictionaryMustNotBeZeroAddress();
  error DictionaryLocationBlobSizeInvalid(uint256 expected, uint256 received);

  error DictionaryIndexOutOfBounds (
    address dictionary,
    uint256 length,
    uint256 index
  );


  ////////// Public Functions //////////

  /// @notice Return the dictionary name as a string only
  /// @return The name of the dictionary
  function getDictionaryName() external view returns (string memory);

  /// @notice Return the word at a certain index
  /// @param index The zero-based index in the dictionary
  /// @return The word as a string
  function wordAt(uint256 index) external view returns (string memory);

  /// @return The total number of words in the dictionary
  function wordCount() external view returns (uint256);

  /// @return The max byte length for each word
  function wordLength() external view returns (uint256);


  ////////// Admin Functions //////////

  /// @notice Identical to `wordAt` with the exception of being an escape hatch
  ///         for the admin post deprecation
  /// @dev Intended use is as seeds for new version
  /// @param index The zero-based index in the dictionary
  /// @return The word as a string
  function migrate(uint256 index) external view returns (string memory);
}

/** @dev V3 considerations ~
 *    . Smarter fingerprinting
 *    . Stronger constructor checks for data contract before assignment
 *    . Batch reads, tho unsure if and where needed
 *    . Dictionaries larger than 24KB (ie, multi pointer)
 *    . Registry contract to decouple data with logic
 *    . Reverse lookup, O(n) is a concern
 */
