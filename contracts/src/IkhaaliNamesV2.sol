// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IERC165} from "./util/IERC165.sol";

/// @dev Because of how the bitmask works, can only have 15 milestones
///      while leaving 0 / no-op and upper 16 bits
enum Milestone {
  // GETTING_STARTED,  // no-op
  // FIRST_HUNDRED,    // 10**2
  // FIRST_THOUSAND,   // 10**3
  // FIRST_TEN_K,      // 10**4
  // FIRST_LAKH,       // 10**5
  // MILLIONAIRE,      // 10**6
  // CROREPATI,        // 10**7
  // UNICORN_STATUS,    // 10**9
  // MILESTONE_0,
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

interface IkhaaliNamesV2 is IERC165 {

  error DictionaryListEmpty();
  error TooManyDictionaries();
  error DictionaryMustBeUnique();
  error UnsupportedDictionaryInterface(address dictionary);

  error TooManyMilestons();
  error MilestoneMismatch();
  error MilestoneCannotBeZero();
  error MaxMilestoneCannotBeZero();
  error MilestoneMaskCannotBeZero();
  error FutureMilestoneMustBeGreater();
  error MilestoneNotAchievable(Milestone m, uint80 expected, uint80 possible);

  /// @notice Get the max milestone supported by the contract
  function maxMilestone() external view returns (Milestone);

  /// @notice Generate a deterministic random name
  /// @dev Same recepient and milestone always yields same name
  /// @param recepient The address for whom this name is to be generated
  /// @param m Milestone identifier
  function getDeterministicName(address recepient, Milestone m)
    external view returns (string memory);

  /// @notice Genereate a random name
  /// @dev Some randomness added to allow different name generation for
  ///      (recepient, milestone) pair
  /// @param recepient The address for whom this name is to be generated
  /// @param m Milestone identifier
  function getRandomName(address recepient, Milestone m)
    external view returns (string memory);

  /// @notice Genereate a random name with an external seed
  /// @dev Randomness handled offchain to generate same name for every
  ///      (recepient, milestone, seed) pair
  /// @param recepient The address for whom this name is to be generated
  /// @param m Milestone identifier
  /// @param salt Offchain entropy / randomness
  function getSeededName(address recepient, Milestone m, uint256 salt)
    external view returns (string memory);
}
