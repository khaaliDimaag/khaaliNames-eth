// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IkhaaliDeprecationV1, Version} from "./IkhaaliDeprecationV1.sol";

contract khaaliDeprecationV1 is IkhaaliDeprecationV1 {

  Version _v;
  address public admin;
  bool public isDeprecated;
  address public nextVersion;

  modifier onlyAdmin() {
    require(msg.sender == admin, AdminFunctionCalledByNonAdmin(msg.sender));
    _;
  }

  modifier undeprecated() {
    require(!isDeprecated, ContractDeprecated(nextVersion));
    _;
  }

  constructor (uint64 _major, uint64 _minor, uint128 _patch) {
    _v = Version(_major, _minor, _patch);
    admin = msg.sender; /// @dev in V2 let's be smarter about this
    isDeprecated = false;
    nextVersion = address(0);
  }

  function version() public view returns (string memory) {
    return string(
      abi.encodePacked(
        _uint2str(_v.major),
        ".",
        _uint2str(_v.minor),
        ".",
        _uint2str(_v.patch)
      )
    );
  }

  function deprecate(address _new) external onlyAdmin {


  }

  function updateAdmin(address _new) external onlyAdmin {
    require(_new != admin, NewAdminMustBeNew(admin));
    require(_new != address(0), NewAdminMustNotBeZero());

    admin = _new;
  }

  function _uint2str(uint256 _n) internal pure returns (string memory) {

    if(_n == 0) return "0";

    /// @dev count digits
    uint256 t = _n;
    uint256 len;
    while(t != 0) {
      len++;
      t/=10;
    }

    /// @dev build bytes
    bytes memory _str = new bytes(len);
    while(_n!=0) {
      len--; /// @dev reduce first since arrays start from 0
      _str[len] = bytes1(uint8(0x30 + (_n % 10))); /// @dev 0x30 == "0"
      _n/=10;
    }

    return string(_str);
  }
}
