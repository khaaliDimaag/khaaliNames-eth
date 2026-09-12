// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IkhaaliNamesV2, Milestone} from "./IkhaaliNamesV2.sol";
import {khaaliDeprecationV1} from "./util/khaaliDeprecationV1.sol";

import {IkhaaliDictionaryV2} from "./dictionary/IkhaaliDictionaryV2.sol";

import {ERC165} from "./util/ERC165.sol";
import {IERC165} from "./util/IERC165.sol";

contract khaaliNamesV2 is IkhaaliNamesV2, ERC165, khaaliDeprecationV1 {

  IkhaaliDictionaryV2[] public dictionaries;
  mapping(bytes12 => address) public nameToDict;
  uint80[] milestones;
  Milestone public maxMilestone;
  uint256 public bitmask;

  uint256 public constant MAX_DICTIONARIES = 16;


  ////////// Initializers //////////

  constructor (
    uint64 _major, uint64 _minor, uint128 _patch,
    bool useDefault, address[] memory _dicts,
    Milestone _max, uint80[] memory _miles, uint256 _mask
  )
    khaaliDeprecationV1(_major, _minor, _patch)
  {

    if(useDefault) _setupDefault();
    else {

      uint256 len = _dicts.length;
      require(len <= MAX_DICTIONARIES, TooManyDictionaries());

      /// @dev verify interface implementation first
      for(uint i=0; i<len; i++) {
        require(
          IERC165(_dicts[i]).supportsInterface(
            type(IkhaaliDictionaryV2).interfaceId
          ),
          UnsupportedDictionaryInterface(_dicts[i])
        );
      }

      /// @dev get counts to verify milestone mask before storing
      uint64[] memory _counts = new uint64[](len);
      for(uint i=0; i<len; i++) {
        _counts[i] = IkhaaliDictionaryV2(_dicts[i]).wordCount();
      }
      uint256 _stripped = _stripMask(_mask, _max);
      _verifyMilestones(_counts, _miles, _stripped);
      milestones = _miles;
      bitmask = _stripped;

      /// @dev finally, save the dictionary references
      for(uint i=0; i<len; i++) {
        IkhaaliDictionaryV2 _dict = IkhaaliDictionaryV2(_dicts[i]);
        dictionaries.push(_dict);
        bytes12 _hash = bytes12(
          keccak256(abi.encodePacked(_dict.getDictionaryName()))
        );
        require(nameToDict[_hash] == address(0), DictionaryMustBeUnique());
        nameToDict[_hash] = address(_dict);
      }

    }

  }

  function _setupDefault() private {
    // TODO: color, animal, and adjective dictionaries with V1 milestones
    // see https://github.com/thisispalash/rootcamp-capstone/blob/account/src/khaaliNamesV1.sol
  }

  /// Strip the non-relevant bits out of the full 32-byte word
  /// @param _mask Complete 256 bit mask
  /// @param _max Max milestone (0..F)
  function _stripMask(uint256 _mask, Milestone _max)
    private
    pure
    returns (uint256)
  {
    require(_max != Milestone.JUST_DEPLOYED, MaxMilestoneCannotBeZero());
    uint8 _boundary = uint8(MAX_DICTIONARIES * uint8(_max));
    return _mask & (2 ** _boundary - 1);
  }

  /// Checks whether every milestone is achievable or not
  /// Also checks that milestones are ascending
  /// @param _counts Word count of all dictionaries
  /// @param _miles Given milestone numbers
  /// @param _strippedMask Stripped bitmask
  function _verifyMilestones(
    uint64[] memory _counts,
    uint80[] memory _miles,
    uint256 _strippedMask
  )
    private
    pure
  {

    uint80 _prev = 0;
    for(uint i=0; i<_miles.length; i++) {

      /// @dev Get the combination pattern using bit operations
      uint16 _temp = uint16(
        (
          _strippedMask
          &
          (2 ** (MAX_DICTIONARIES * (i+1)) - 1)
        ) /// @dev extract `MAX_DICTIONARIES` bits of interest
        >>
        MAX_DICTIONARIES * i /// @dev move to LSB before downcast
      );

      require(_temp != 0x0, MilestoneMaskCannotBeZero());
      require(_miles[i] > _prev, FutureMilestoneMustBeGreater());
      _prev = _miles[i];

      /// @dev Check if a milestone number is achievable with given dictionary
      ///      combination bitmask
      uint80 combinations = 1;
      for(uint j=0; j<_counts.length; j++) {
        if(_temp & 2**j != 0) combinations *= _counts[j];
      }
      require(
        combinations >= _miles[i],
        MilestoneNotAchievable(Milestone(uint8(i)), _miles[i], combinations)
      );

    }

  }


  ////////// Public Functions //////////

  function getMilestoneDetails(Milestone m)
    public
    view
    returns (uint8, uint80, uint16)
  {
    require(m != Milestone.JUST_DEPLOYED, MilestoneCannotBeZero());
    uint8 index = uint8(m) - 1;
    return (
      index + 1,
      milestones[index],
      uint16(bitmask & (2 ** (MAX_DICTIONARIES * (index+1)) - 1))
    );
  }

  function getDeterministicName(address recepient, Milestone m)
    public
    view
    returns (string memory)
  {
    return _generate(recepient, m, 0);
  }

  function getRandomName(address recepient, Milestone m)
    public
    view
    returns (string memory)
  {
    return _generate(recepient, m, block.timestamp);
  }

  function getSeededName(address recepient, Milestone m, uint256 salt)
    public
    view
    returns (string memory)
  {
    return _generate(recepient, m, salt);
  }


  ////////// Admin Functions //////////


  ////////// Internal Functions //////////

  function _generate(address _r, Milestone _m, uint256 _s)
    internal
    view
    returns (string memory name)
  {

  }

  function _pickWord(IkhaaliDictionaryV2 _dict, uint256 _seed, uint256 _salt)
    internal
    view
    returns (string memory)
  {
    uint64 _count = _dict.wordCount();
    uint64 _index = uint64(bytes8(keccak256(abi.encodePacked(_seed, _salt))))
      % _count;
    return _dict.wordAt(_index);
  }


  ////////// ERC Functions //////////

  function supportsInterface(bytes4 _id)
    public
    virtual
    view
    override(khaaliDeprecationV1, ERC165, IERC165)
    returns (bool)
  {
    return _id == type(IkhaaliNamesV2).interfaceId
      ||super.supportsInterface(_id);
  }

}
