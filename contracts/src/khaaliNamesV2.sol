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

  uint256 public constant MAX_MILESTONES = 15;
  uint256 public constant MAX_DICTIONARIES = 16;


  ////////// Modifiers //////////

  modifier validMilestone(Milestone _m) {
    _validMilestone(_m);
    _;
  }

  function _validMilestone(Milestone _m) internal view {
    require(_m != Milestone.JUST_DEPLOYED, MilestoneCannotBeZero());
    require(_m <= maxMilestone, MilestoneTooHigh());
  }


  ////////// Initializers //////////

  function _setupDefault() private {
    // TODO: color, animal, and adjective dictionaries with V1 milestones
    // see https://github.com/thisispalash/rootcamp-capstone/blob/account/src/khaaliNamesV1.sol
    revert Unimplemented();
  }

  constructor (
    uint64 _major, uint64 _minor, uint128 _patch,
    bool useDefault, address[] memory _dicts,
    Milestone _max, uint80[] memory _miles, uint256 _mask
  )
    khaaliDeprecationV1(_major, _minor, _patch)
  {

    if(useDefault) _setupDefault();
    else {

      require(_miles.length == uint8(_max), MilestoneMismatch());
      require(_dicts.length > 0, DictionaryListEmpty());
      require(_dicts.length <= MAX_DICTIONARIES, TooManyDictionaries());

      uint256 dictsLen = _dicts.length;

      /// @dev verify interface implementation first
      for(uint i=0; i<dictsLen; i++) {
        require(
          _dicts[i].code.length > 0 &&
          IERC165(_dicts[i]).supportsInterface(
            type(IkhaaliDictionaryV2).interfaceId
          ),
          UnsupportedDictionaryInterface(_dicts[i])
        );
      }

      /// @dev get counts to verify milestone mask before storing
      uint64[] memory _counts = new uint64[](dictsLen);
      for(uint i=0; i<dictsLen; i++) {
        _counts[i] = IkhaaliDictionaryV2(_dicts[i]).wordCount();
      }
      uint256 _stripped = _stripMask(_mask, _max);
      _verifyMilestones(_counts, _miles, _stripped);
      milestones = _miles;
      bitmask = _stripped;
      maxMilestone = _max;

      /// @dev finally, save the dictionary references
      for(uint i=0; i<dictsLen; i++) {
        IkhaaliDictionaryV2 _dict = IkhaaliDictionaryV2(_dicts[i]);
        dictionaries.push(_dict);
        bytes12 _hash = bytes12(
          keccak256(abi.encodePacked(_dict.getDictionaryName()))
        );
        require(nameToDict[_hash] == address(0), DictionaryMustBeUnique());
        nameToDict[_hash] = address(_dict);
      }

    } // close `else` block

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
    // casting to 'uint8' is safe because max value possible is 16 * 15 = 240
    // forge-lint: disable-next-line(unsafe-typecast)
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

      uint16 _temp = _getRelevantBits(_strippedMask, i);

      require(_temp != 0x0, MilestoneMaskCannotBeZero());
      require(_miles[i] > _prev, FutureMilestoneMustBeGreater());
      _prev = _miles[i];

      /// @dev Check if a milestone number is achievable with given dictionary
      ///      combination bitmask
      uint80 combinations = 1;
      for(uint j=0; j<_counts.length; j++) {
        if(_temp & 2**j != 0) combinations *= _counts[j];
        if(combinations >= _miles[i]) break; /// @dev exit early -> no overflow
      }
      require(
        combinations >= _miles[i],
        MilestoneNotAchievable(Milestone(uint8(i) + 1), _miles[i], combinations)
      );

    }

  }


  ////////// Public Functions //////////

  function getMilestoneDetails(Milestone m)
    public
    view
    validMilestone(m)
    returns (uint8, uint80, uint16)
  {
    uint8 index = uint8(m) - 1;
    return (
      index + 1,
      milestones[index],
      _getRelevantBits(bitmask, index)
    );
  }

  function getDeterministicName(address recepient, Milestone m)
    public
    view
    validMilestone(m)
    returns (string memory)
  {
    return _generate(recepient, m, 0);
  }

  function getTimestampedName(address recepient, Milestone m)
    public
    view
    validMilestone(m)
    returns (string memory)
  {
    return _generate(recepient, m, block.timestamp);
  }

  function getSeededName(address recepient, Milestone m, uint256 salt)
    public
    view
    validMilestone(m)
    returns (string memory)
  {
    return _generate(recepient, m, salt);
  }

  ////////// Admin Functions //////////


  ////////// Internal Functions //////////

  /// @dev Get the combination pattern using bit operations
  function _getRelevantBits(uint256 _mask, uint256 _index)
    internal
    pure
    returns (uint16)
  {
    // casting to 'uint16' is safe because we only care about 16 bits
    // forge-lint: disable-next-line(unsafe-typecast)
    return uint16(
      (
        _mask
        &
        (2 ** (MAX_DICTIONARIES * (_index+1)) - 1)
      ) /// @dev extract `MAX_DICTIONARIES` bits of interest
      >>
      MAX_DICTIONARIES * _index /// @dev move to LSB before downcast
    );
  }

  // @dev Core generation logic
  function _generate(address _r, Milestone _m, uint256 _s)
    internal
    view
    returns (string memory)
  {
    bytes memory _name;
    uint16 _mask = _getRelevantBits(bitmask, uint8(_m) - 1);
    uint256 _seed = uint256(
      keccak256(
        _s == 0x0 ?
          abi.encodePacked(_r, uint8(_m))
          :
          abi.encodePacked(_r, uint8(_m), _s)
      )
    );

    for(uint i=0; i<dictionaries.length; i++) {
      if(_mask & 2**i != 0) {
        _name = abi.encodePacked(
          _name, /// @dev First iteration bytes(_name) == 0x0
          _pickWord(dictionaries[i], _seed),
          "-"
        );
      }
    }

    // @dev being extra cautious; prolly unneeded
    if(_name.length != 0) {
      // @dev AI generated logic
      assembly {
        mstore(_name, sub(mload(_name), 1))
      }
    }

    return string(_name);
  }

  // @dev Pick a word from the given dictionary using the given seed
  function _pickWord(IkhaaliDictionaryV2 _dict, uint256 _seed)
    internal
    view
    returns (string memory)
  {
    return _dict.wordAt(
      uint64(
        // casting to 'bytes8' is safe because wordCount is uint64
        // forge-lint: disable-next-line(unsafe-typecast)
        bytes8(keccak256(abi.encodePacked(_seed)))
      )
      %
      _dict.wordCount()
    );
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
