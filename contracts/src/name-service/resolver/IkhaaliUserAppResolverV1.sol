// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IkhaaliBaseResolverV1} from "./IkhaaliBaseResolverV1.sol";

// Optional resolver for each app the user is a member of
// @note overrides Forward Resolution
interface IkhaaliUserResolverV1 is IkhaaliBaseResolverV1 {

}
