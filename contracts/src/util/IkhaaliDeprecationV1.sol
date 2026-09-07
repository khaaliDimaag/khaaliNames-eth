// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

struct Version {
  uint64 major;
  uint64 minor;
  uint128 patch;
}


/// @title IkhaaliDeprecation
/// @notice Small module to handle contract deprecations
interface IkhaaliDeprecationV1 {

  ////////// Errors //////////

  error ContractDeprecated(address newAddress);

  error NewAdminMustNotBeZero();
  error NewAdminMustBeNew(address admin);

  error AdminFunctionCalledByNonAdmin(address caller);

  ////////// Events //////////

  event AdminUpdated(address oldAdmin, address newAdmin);
  event Deprecated(address newVersion, Version oldVersion);

  ////////// Main Functions //////////

  function version() external view returns (string memory);

  /// @notice Deprecate the current contract
  /// @param _new Address for the new version
  function deprecate(address _new) external;

  ////////// Admin Functions //////////

  function updateAdmin(address _new) external;

}
