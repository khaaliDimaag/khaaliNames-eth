// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IERC165} from "./util/IERC165.sol";

/// @dev Because of how the bitmask works, can only have 15 milestones
///      while leaving 0 / no-op and upper 16 bits
enum Milestone {
  JUST_DEPLOYED, // no-op
  MILESTONE_1,
  MILESTONE_2,
  MILESTONE_3,
  MILESTONE_4,
  MILESTONE_5,
  MILESTONE_6,
  MILESTONE_7,
  MILESTONE_8,
  MILESTONE_9,
  MILESTONE_A,
  MILESTONE_B,
  MILESTONE_C,
  MILESTONE_D,
  MILESTONE_E,
  MILESTONE_F
}

/// @title IkhaaliNamesV2
/// Interface for `khaaliNamesV2`, an onchain utility to get unique names
interface IkhaaliNamesV2 is IERC165 {

  ////////// Errors //////////

  error DictionaryListEmpty();
  error TooManyDictionaries();
  error DictionaryMustBeUnique();
  error UnsupportedDictionaryInterface(address dictionary);

  error MilestoneTooHigh();
  error TooManyMilestones();
  error MilestoneMismatch();
  error MilestoneCannotBeZero();
  error MaxMilestoneCannotBeZero();
  error MilestoneMaskCannotBeZero();
  error FutureMilestoneMustBeGreater();
  error MilestoneNotAchievable(Milestone m, uint80 expected, uint80 possible);


  ////////// Getters //////////

  /// @notice Check if a certain dictionary is supported by name
  /// @dev Only last 12 bytes are used for hash due to word-packing
  /// @return The address of the dictionary if supported, else `address(0)`
  function nameToDict(bytes12 nameHashLSB) external view returns (address);

  /// @notice Get the max milestone supported by the contract
  /// @return Milestone enum member, except `Milestone.JUST_DEPLOYED`
  function maxMilestone() external view returns (Milestone);

  /// @notice Get the bitmask for dictionary application per milestone
  /// @dev Bitmask is 16 bits for each dictionary, per milestone
  ///      top 16 bits are preserved
  /// @return The 256-bit bitmask in use
  function bitmask() external view returns (uint256);


  ////////// Public Functions //////////

  /// @notice Get details for a particular milestone
  /// @return milestoneNumber The position of the milestone in the enum
  /// @return milestoneCount How may values possible in that milestone
  /// @return bitmask The dictionary application bitmask
  function getMilestoneDetails(Milestone m)
    external view
    returns (uint8 milestoneNumber, uint80 milestoneCount, uint16 bitmask);

  /// @notice Generate a deterministic random name
  /// @dev Same recepient and milestone always yields same name
  /// @param recepient The address for whom this name is to be generated
  /// @param m Milestone identifier
  /// @return
  function getDeterministicName(address recepient, Milestone m)
    external view returns (string memory);

  /// @notice Genereate a random name with timestamp as salt
  /// @dev Some randomness added to allow different name generation for
  ///      (recepient, milestone) pair
  /// @param recepient The address for whom this name is to be generated
  /// @param m Milestone identifier
  function getTimestampedName(address recepient, Milestone m)
    external view returns (string memory);

  /// @notice Genereate a random name with an external salt
  /// @dev Randomness handled offchain to generate same name for every
  ///      (recepient, milestone, seed) pair
  /// @param recepient The address for whom this name is to be generated
  /// @param m Milestone identifier
  /// @param salt Offchain entropy / randomness
  function getSeededName(address recepient, Milestone m, uint256 salt)
    external view returns (string memory);


  ////////// Admin Functions //////////

  // TODO: Add admin functionality to update dictionary, bitmask, or milestones

}
