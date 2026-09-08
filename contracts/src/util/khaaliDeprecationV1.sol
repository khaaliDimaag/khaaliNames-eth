// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IkhaaliDeprecationV1, Version} from "./IkhaaliDeprecationV1.sol";

/// @dev Marked `abstract` since this is not meant to be standalone
abstract contract khaaliDeprecationV1 is IkhaaliDeprecationV1 {

  Version _v;
  address public admin;
  bool public isAbandoned;
  bool public isDeprecated;
  address public nextVersion;

  ////////// Modifiers //////////

  modifier onlyAdmin() {
    _onlyAdmin();
    _;
  }

  function _onlyAdmin() internal view {
    require(msg.sender == admin, AdminFunctionCalledByNonAdmin(msg.sender));
  }

  modifier undeprecated() {
    _undeprecated();
    _;
  }

  function _undeprecated() internal view {
    require(!isDeprecated, ContractDeprecated(nextVersion));
    require(!isAbandoned, ContractAbandoned());
  }

  ////////// Initializers //////////

  constructor (uint64 _major, uint64 _minor, uint128 _patch) {
    _v = Version({major: _major, minor: _minor, patch: _patch});
    admin = msg.sender; /// @dev in V2 let's be smarter about this
    isDeprecated = false;
    nextVersion = address(0);
  }

  ////////// Public Functions //////////

  function version() public view returns (string memory) {
    return string(
      string.concat(
        _uint2str(_v.major),
        ".",
        _uint2str(_v.minor),
        ".",
        _uint2str(_v.patch)
      )
    );
  }

  function semantic() public view returns (Version memory) {
    return _v;
  }

  ////////// Main Functionality //////////

  function deprecate(address _new) external undeprecated onlyAdmin {
    require(_new != address(0), NewVersionMustNotBeZero()); /// @dev cosmetic
    require(_new.code.length > 0, NewVersionNotAContract());

    Version memory _nv = IkhaaliDeprecationV1(_new).semantic();
    bool ok = _nv.major > _v.major
    || (_nv.major == _v.major && _nv.minor > _v.minor)
    || (_nv.major == _v.major && _nv.minor == _v.minor && _nv.patch > _v.patch);
    require(
      ok,
      NewVersionMustBeGreater(version(), IkhaaliDeprecationV1(_new).version())
    );

    UpdateKind _kind = _nv.major != _v.major ? UpdateKind.BREAKING
      : _nv.minor != _v.minor ? UpdateKind.FEATURE : UpdateKind.FIX;

    nextVersion = _new;
    isDeprecated = true;

    // reentrancy (should) not possible since only view functions called above
    // forge-lint: disable-next-line(reentrancy-events)
    emit Deprecated(_new, _kind, _v, _nv);
  }

  function abandon() external undeprecated onlyAdmin {
    isAbandoned = true;
    nextVersion = address(0); /// @dev extra sure to reset pointer; may not need
    emit Abandoned(_v);
  }

  ////////// Admin Related Functions //////////


  function updateAdmin(address _new) external onlyAdmin {
    require(_new != admin, NewAdminMustBeNew(admin));
    require(_new != address(0), NewAdminMustNotBeZero());

    address _old = admin; /// @dev only for the event; rather emit after update
    admin = _new;
    emit AdminUpdated(_old, _new);
  }

  ////////// Internal Functions //////////

  /// @notice Convert a uint256 to its decimal string representation
  function _uint2str(uint256 _n) internal pure returns (string memory) {

    if(_n == 0) return "0";

    /// @dev count digits
    uint256 t = _n;
    uint256 len = 0;
    while(t != 0) {
      len++;
      t/=10;
    }

    /// @dev build bytes
    bytes memory _str = new bytes(len);
    while(_n!=0) {
      len--; /// @dev reduce first since arrays start from 0
      // casting to `uint8` is safe since the `% 10` ensures < 0x3A
      // forge-lint: disable-next-line(unsafe-typecast)
      _str[len] = bytes1(uint8(0x30 + (_n % 10))); /// @dev 0x30 == "0"
      _n/=10;
    }

    return string(_str);
  }

}
