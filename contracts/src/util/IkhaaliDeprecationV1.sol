// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IERC165} from "../util/IERC165.sol";

struct Version {
  uint64 major;
  uint64 minor;
  uint128 patch;
}

/// @title IkhaaliDeprecation
/// @notice Small module to handle contract deprecations
interface IkhaaliDeprecationV1 is IERC165 {

  enum UpdateKind { UNCHANGED, BREAKING, FEATURE, FIX }

  ////////// Errors //////////

  error Unimplemented();

  error ContractAbandoned();
  error ContractDeprecated(address newAddress);

  error NewVersionNotAContract();
  error NewVersionMustNotBeZero();
  error NewVersionMustBeGreater(string oldVersion, string newVersion);

  error NewAdminMustNotBeZero();
  error NewAdminMustBeNew(address admin);

  error AdminFunctionCalledByNonAdmin(address caller);


  ////////// Events //////////

  event Deprecated(
    address indexed newAddress,
    UpdateKind indexed kind,
    Version oldVersion, Version newVersion
  );
  event Abandoned(Version current);
  event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);


  ////////// Public Functions //////////

  /// @notice Get the current version of the contract as a string
  function version() external view returns (string memory);

  /// @notice Get the current version of the contract as a tuple
  function semantic() external view returns (Version memory);


  ////////// Main Functionality //////////

  /// @notice Deprecate the current contract
  /// @param _new Address for the new version
  function deprecate(address _new) external;

  /// @notice Remove support for current logic
  /// @dev Consider supporting "fallbacks" in V2
  function abandon() external;


  ////////// Admin Related Functions //////////

  /// @notice Update the admin manager of this contract
  /// @dev V2 needs to explicitly check for EOA vs contract admin
  /// @param _new Address for the new admin
  function updateAdmin(address _new) external;

}
