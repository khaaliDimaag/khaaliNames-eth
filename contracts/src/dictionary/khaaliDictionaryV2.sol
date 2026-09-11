// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {SSTORE2} from "solady/utils/SSTORE2.sol";
import {khaaliDeprecationV1} from "../util/khaaliDeprecationV1.sol";
import {IkhaaliDictionaryV2, khaaliDictionary} from "./IkhaaliDictionaryV2.sol";

import {ERC165} from "../util/ERC165.sol";
import {IERC165} from "../util/IERC165.sol";

contract khaaliDictionaryV2 is
  IkhaaliDictionaryV2,
  ERC165,
  khaaliDeprecationV1
{

  khaaliDictionary public dict;
  bytes32 public immutable FINGERPRINT;


  ////////// Initializers //////////

  constructor(
    uint64 _major, uint64 _minor, uint128 _patch,
    uint32 _length, uint32 _count, address _loc, string memory _name
  )
    khaaliDeprecationV1(_major, _minor, _patch)
  {
    require(_length != 0, WordLengthMustNotBeZero());
    require(_count != 0, DictionaryMustNotBeEmpty());
    require(bytes(_name).length > 0, DictionaryNeedsName());
    require(_loc != address(0), DictionaryMustNotBeZeroAddress());
    require(
      _loc.code.length == (uint256(_count) * _length) + 10,
      DictionaryLocationBlobSizeInvalid(
        (uint256(_length) * _count) + 10, _loc.code.length
      )
    );

    /// @dev further hardening for SSTORE2 deployment may be useful in V3

    dict = khaaliDictionary({
      LOCATION: _loc,
      WORD_COUNT: _count,
      WORD_LENGTH: _length,
      NAME: _name
    });
    FINGERPRINT = keccak256(SSTORE2.read(_loc, 0, (uint256(_count) * _length)));
  }


  ////////// Public Functions //////////

  function getDictionaryName()
    public
    view
    returns (string memory)
  {
    return dict.NAME;
  }

  function wordLength()
    public
    view
    undeprecated
    returns (uint256)
  {
    return dict.WORD_LENGTH;
  }

  function wordCount()
    public
    view
    undeprecated
    returns (uint256)
  {
    return dict.WORD_COUNT;
  }

  function wordAt(uint256 _i)
    public
    view
    undeprecated
    returns (string memory)
  {
    return _get(_i);
  }


  ////////// Admin Functions //////////

  function migrate(uint256 _i)
    public
    view
    onlyAdmin /// @dev notice the modifer switch for "escape hatch"
    returns (string memory)
  {
    return _get(_i);
  }


  ////////// Internal Functions //////////

  /// @dev Not rule-of-3, but 2 identicals also annoy me
  function _get(uint256 _i) internal view returns (string memory) {
    require(
      _i < dict.WORD_COUNT,
      DictionaryIndexOutOfBounds(address(this), dict.WORD_COUNT, _i)
    );
    bytes memory _raw = SSTORE2.read(
      dict.LOCATION, _i * dict.WORD_LENGTH, (_i + 1) * dict.WORD_LENGTH
    );
    return _bytes2str(_raw);
  }

  /// @notice Convert the raw bytes to a string, trimming the padding bytes
  /// @notice AI generated logic, lgtm; tho, "trust, but verify"!
  /// @dev 1 loop is cheaper than 2 loops by 100-150 gas
  function _bytes2str(bytes memory _raw)
    internal
    view
    returns (string memory)
  {
    uint256 _len;
    bytes memory _word = new bytes(dict.WORD_LENGTH);

    for (_len = 0; _len < dict.WORD_LENGTH; _len++) {
      if (_raw[_len] == 0) break;
      _word[_len] = _raw[_len];
    }

    assembly {
      mstore(_word, _len) // overwrite the length of the word
    }

    return string(_word);
  }

  ////////// ERC Functions //////////

  /// @dev explicit calls to avoid mid-chain hops forgetting to call `super`
  function supportsInterface(bytes4 _id)
    public
    view
    override(khaaliDeprecationV1, ERC165, IERC165)
    returns (bool)
  {
    return _id == type(IkhaaliDictionaryV2).interfaceId
      || khaaliDeprecationV1.supportsInterface(_id)
      || ERC165.supportsInterface(_id);
  }

}
