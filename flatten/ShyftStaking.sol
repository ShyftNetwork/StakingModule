// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{ value: amount }('');
    require(
      success,
      'Address: unable to send value, recipient may have reverted'
    );
  }

  /**
   * @dev Performs a Solidity function call using a low level `call`. A
   * plain`call` is an unsafe replacement for a function call: use this
   * function instead.
   *
   * If `target` reverts with a revert reason, it is bubbled up by this
   * function (like regular Solidity function calls).
   *
   * Returns the raw returned data. To convert to the expected return value,
   * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
   *
   * Requirements:
   *
   * - `target` must be a contract.
   * - calling `target` with `data` must not revert.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {
    return functionCall(target, data, 'Address: low-level call failed');
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
   * `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but also transferring `value` wei to `target`.
   *
   * Requirements:
   *
   * - the calling contract must have an ETH balance of at least `value`.
   * - the called Solidity function must be `payable`.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return
      functionCallWithValue(
        target,
        data,
        value,
        'Address: low-level call with value failed'
      );
  }

  /**
   * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
   * with `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(
      address(this).balance >= value,
      'Address: insufficient balance for call'
    );
    require(isContract(target), 'Address: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return
      functionStaticCall(target, data, 'Address: low-level static call failed');
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), 'Address: static call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private _initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private _initializing;

  /**
   * @dev Modifier to protect an initializer function from being invoked twice.
   */
  modifier initializer() {
    require(
      _initializing || _isConstructor() || !_initialized,
      'Initializable: contract is already initialized'
    );

    bool isTopLevelCall = !_initializing;
    if (isTopLevelCall) {
      _initializing = true;
      _initialized = true;
    }

    _;

    if (isTopLevelCall) {
      _initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function _isConstructor() private view returns (bool) {
    return !AddressUpgradeable.isContract(address(this));
  }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
  function __Context_init() internal initializer {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal initializer {}

  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }

  uint256[50] private __gap;
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  function __Ownable_init() internal initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
  }

  function __Ownable_init_unchained() internal initializer {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view virtual returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[49] private __gap;
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
  // Booleans are more expensive than uint256 or any type that takes up a full
  // word because each write operation emits an extra SLOAD to first read the
  // slot's contents, replace the bits taken up by the boolean, and then write
  // back. This is the compiler's defense against contract upgrades and
  // pointer aliasing, and it cannot be disabled.

  // The values being non-zero value makes deployment a bit more expensive,
  // but in exchange the refund on every call to nonReentrant will be lower in
  // amount. Since refunds are capped to a percentage of the total
  // transaction's gas, it is best to keep them low in cases like this one, to
  // increase the likelihood of the full refund coming into effect.
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  function __ReentrancyGuard_init() internal initializer {
    __ReentrancyGuard_init_unchained();
  }

  function __ReentrancyGuard_init_unchained() internal initializer {
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    // On the first call to nonReentrant, _notEntered will be true
    require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');

    // Any calls to nonReentrant after this point will fail
    _status = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _status = _NOT_ENTERED;
  }
  uint256[49] private __gap;
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }

  /**
   * @dev Returns the substraction of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b > a) return (false, 0);
    return (true, a - b);
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }

  /**
   * @dev Returns the division of two unsigned integers, with a division by zero flag.
   *
   * _Available since v3.4._
   */
  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a / b);
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
   *
   * _Available since v3.4._
   */
  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a % b);
  }

  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   *
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');
    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath: subtraction overflow');
    return a - b;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   *
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');
    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers, reverting on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, 'SafeMath: division by zero');
    return a / b;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverting when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, 'SafeMath: modulo by zero');
    return a % b;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {trySub}.
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

  /**
   * @dev Returns the integer division of two unsigned integers, reverting with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {tryDiv}.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverting with custom message when dividing by zero.
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {tryMod}.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

/**
 * @title ShyftDao test interface
 * @dev WARNING Only for testing purposes.
 */
interface IShyftDao {
  function getDaoMultiplier() external view returns (uint256);
}

/**
 * @title PriceFeeder test interface
 * @dev WARNING Only for testing purposes.
 */
interface IPriceFeeder {
  function getCurrentPrice() external view returns (uint256);

  function getMarketAveragePrice() external view returns (uint256);
}

/**
 * @title ShyftStaking Contract
 */
contract ShyftStaking is
  Initializable,
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable
{
  using SafeMath for uint256;

  // Timestamp when current staking period is finishing.
  uint256 public periodFinish;
  // The reward rate for current period.
  uint256 public rewardRate;
  // The normal amount of rewards to be provided every period.
  uint256 public rewardsAmount;
  // The duration of a period.
  uint256 public rewardsDuration;
  // The time needed to be able to unstake after calling unbond.
  uint256 public unbondingPeriod;
  // The timestamp that the rewards were updated.
  uint256 public lastUpdateTime;
  // The reward amount for every Shft that is staked.
  uint256 public rewardPerShftStored;
  // The timestamp at which the pre purchasers amounts are released.
  uint256 public prePurchasersReleaseTimestamp;

  // The user reward per every shft staked already paid.
  mapping(address => uint256) public userRewardPerShftPaid;
  // The user rewards already added.
  mapping(address => uint256) public rewards;

  // The total supply staked or added (prepurchasers) inside the contract.
  uint256 private _totalSupply;
  // The balance of an address (prepurchasers don't have any till they stake).
  mapping(address => uint256) private _balances;

  // The address of the rewardsDistribution contract.
  address public rewardsDistribution;
  // The dao contract, that provides the rewards multiplier.
  IShyftDao public shyftDao;
  // The priceFeeder contract, that provides the marketAveragePrice and the currentPrice of SHFT.
  IPriceFeeder public priceFeeder;

  // The lowest voting bound price for SHFT.
  uint256 public lowestVotingBoundPrice;

  // A struct containing the unbonding details.
  struct UnbondingDetails {
    // The account requested the unbonding.
    address account;
    // The remaining amount to be unstaked.
    uint256 remainingAmount;
    // The timestamp when unstaking is enabled for this unbonding.
    uint256 unstakeEnabledTimestamp;
    // The index, in which the unbonding exists into the account's unbonding array.
    uint256 indexIntoUnbondingArray;
  }

  // UnbondingId => UnbondingDetails.
  mapping(uint256 => UnbondingDetails) public unbondingDetailsForId;
  // Staker => Unbonding ids array.
  mapping(address => uint256[]) public unbondingIdsPerAddress;
  // The total amount of unbondings.
  uint256 public totalUnbondings;

  // A struct containing the prepurchaser details.
  struct PrePurchaserDetails {
    // The amount added for the prepurchasers.
    uint256 amountAdded;
    // True if prepurchaser has staked, false otherwise (initilized with false).
    bool staked;
  }

  // Prepurchaser's address => PrePurchaserDetails.
  mapping(address => PrePurchaserDetails) public prePurchasersDetails;
  // The amount remaining to be staked by all prepurchasers.
  uint256 public totalPrePurchasersAmountToBeStaked;

  // True if prepurchasers mode is on, false otherwise.
  bool prePurchasersModeOn;

  /**
   * @notice Initialize the contract.
   * @param rewardsDistribution_ The address of the rewardsDistribution contract.
   * @param shyftDao_ The address of the shyftDao contract.
   * @param priceFeeder_ The address of the priceFeeder contract.
   * @param prePurchasersReleaseTimestamp_ The timestamp at which the pre purchasers amounts are released
   * @param rewardsDuration_ The duration of a period.
   * @param rewardsAmount_ The normal amount provided as reward every period.
   * @param lowestVotingBoundPrice_ The lowest voting bound price for SHFT.
   */
  function initialize(
    address rewardsDistribution_,
    address shyftDao_,
    address priceFeeder_,
    uint256 prePurchasersReleaseTimestamp_,
    uint256 rewardsDuration_,
    uint256 rewardsAmount_,
    uint256 lowestVotingBoundPrice_
  ) external initializer {
    __Ownable_init();
    __ReentrancyGuard_init();

    rewardsDistribution = rewardsDistribution_;
    shyftDao = IShyftDao(shyftDao_);
    priceFeeder = IPriceFeeder(priceFeeder_);

    prePurchasersReleaseTimestamp = prePurchasersReleaseTimestamp_;
    rewardsDuration = rewardsDuration_;
    rewardsAmount = rewardsAmount_;
    lowestVotingBoundPrice = lowestVotingBoundPrice_;

    prePurchasersModeOn = true;
    unbondingPeriod = 28 days;
  }

  /* ======================================================= MODIFIERS ====================================================== */

  modifier updateReward(address account) {
    rewardPerShftStored = rewardPerShft();
    lastUpdateTime = lastTimeRewardApplicable();
    if (account != address(0)) {
      rewards[account] = earned(account);
      userRewardPerShftPaid[account] = rewardPerShftStored;
    }
    _;
  }

  modifier onlyRewardsDistribution() {
    require(
      msg.sender == rewardsDistribution,
      'Only rewardsDistribution contract'
    );
    _;
  }

  modifier onlyAfterRelease() {
    require(
      block.timestamp >= prePurchasersReleaseTimestamp,
      'Cannot do this action yet'
    );
    _;
  }

  modifier onlyPrePurchaserModeOn() {
    require(prePurchasersModeOn, 'Only if prepurchasers mode is ON');
    _;
  }

  /* ======================================================== EVENTS ======================================================== */

  event RewardAdded(uint256 reward);
  event Staked(address indexed user, uint256 amount);
  event Unbonded(
    address indexed user,
    uint256 amount,
    uint256 timestamp,
    uint256 id
  );
  event RewardPaid(address indexed user, uint256 reward);
  event RewardsDurationUpdated(uint256 newDuration);
  event RewardAmountUpdated(uint256 newRewardAmount);
  event LowestVotingBoundPriceUpdated(uint256 newLowestVotingBoundPrice);
  event Unstaked(uint256 indexed unbondingId, uint256 amount);
  event PrePurchaserAdded(address indexed prePurchaser, uint256 amount);
  event PrePurchaserStaked(address indexed prePurchaser, uint256 amount);
  event PrepurchasersModeFinished(uint256 amountOfRewardsReturned);

  /* ================================================== MUTATIVE FUNCTIONS ================================================== */

  /**
   * @notice Stake
   * @dev This function is used by users to stake.
   * @notice Prepurchasers cannot stake till the prepurchasers mode goes off.
   */
  function stake() external payable nonReentrant updateReward(msg.sender) {
    if (prePurchasersDetails[msg.sender].amountAdded > 0) {
      require(
        !prePurchasersModeOn,
        'Prepurchasers can normally stake only if prepurchasers mode is not ON'
      );
    }

    uint256 amount = msg.value;
    require(amount > 0, 'Cannot stake 0');

    _totalSupply = _totalSupply.add(amount);
    _balances[msg.sender] = _balances[msg.sender].add(amount);

    emit Staked(msg.sender, amount);
  }

  /**
   * @notice Stake for prepurchasers
   * @dev This function is used by prepurchasers so that they can add the amount needed to be eligible
   * @dev for already farmed rewards.
   * @notice Prepurchasers can only use this function after their release and only if prepurchasers mode is on.
   */
  function stakePrePurchaser()
    external
    payable
    nonReentrant
    onlyAfterRelease
    onlyPrePurchaserModeOn
  {
    require(!prePurchasersDetails[msg.sender].staked, 'Cannot stake again');
    require(
      prePurchasersDetails[msg.sender].amountAdded > 0,
      'Only Prepurchasers can call this function'
    );
    require(
      msg.value == prePurchasersDetails[msg.sender].amountAdded,
      'Prepurchasers should stake the whole exact amount'
    );

    uint256 amount = msg.value;

    prePurchasersDetails[msg.sender].staked = true;
    _balances[msg.sender] = _balances[msg.sender].add(amount);

    totalPrePurchasersAmountToBeStaked = totalPrePurchasersAmountToBeStaked.sub(
        amount
      );

    emit PrePurchaserStaked(msg.sender, amount);
  }

  /**
   * @notice Unbond
   * @dev This function is used by users to unbond part of their stake.
   * @notice This function can only be called after prepurchasers' release happens.
   * @param amount The amount to be unbonded.
   */
  function unbond(uint256 amount)
    external
    nonReentrant
    onlyAfterRelease
    updateReward(msg.sender)
  {
    _unbond(amount);
  }

  /**
   * @notice UnbondAll
   * @dev This function is used by users to unbond their whole stake.
   * @notice This function can only be called after prepurchasers' release happens.
   */
  function unbondAll()
    external
    nonReentrant
    onlyAfterRelease
    updateReward(msg.sender)
  {
    _unbond(_balances[msg.sender]);
    _getReward();
  }

  /**
   * @notice Unstake
   * @dev This function is used by users to unstake their unbonded stakes.
   * @notice This function is associated with an unbonding id generated from the unbond function.
   * @notice Must have passed at least time equal to unbondingPeriod between unbond and unstake
   * @notice for users to be able to unstake.
   * @param unbondingId The unbondingId from which user would like to unstake.
   * @param amount The amount from the unbonding id, which user would like to unstake.
   */
  function unstake(uint256 unbondingId, uint256 amount) external nonReentrant {
    require(
      block.timestamp >=
        unbondingDetailsForId[unbondingId].unstakeEnabledTimestamp,
      'Cannot unstake before unbonding period ends'
    );
    require(
      msg.sender == unbondingDetailsForId[unbondingId].account,
      'Only owner of unbonding id can unstake'
    );
    require(
      unbondingDetailsForId[unbondingId].remainingAmount >= amount,
      'Cannot unstake more than remaining amount in unbonding id'
    );

    unbondingDetailsForId[unbondingId].remainingAmount = unbondingDetailsForId[
      unbondingId
    ].remainingAmount.sub(amount);

    if (unbondingDetailsForId[unbondingId].remainingAmount == 0) {
      uint256 index = unbondingDetailsForId[unbondingId]
        .indexIntoUnbondingArray;
      uint256 length = unbondingIdsPerAddress[msg.sender].length;

      uint256 unbondingIdToMove = unbondingIdsPerAddress[msg.sender][
        length.sub(1)
      ];
      unbondingIdsPerAddress[msg.sender][index] = unbondingIdToMove;
      unbondingIdsPerAddress[msg.sender].pop();

      // Case that rubbish remains in here, that does not play any role though.
      unbondingDetailsForId[unbondingIdToMove].indexIntoUnbondingArray = index;
    }

    emit Unstaked(unbondingId, amount);

    msg.sender.transfer(amount);
  }

  /**
   * @notice GetReward
   * @dev This function is used by users to get their rewards.
   * @notice This function can only be called after prepurchasers' release happens.
   */
  function getReward()
    external
    nonReentrant
    onlyAfterRelease
    updateReward(msg.sender)
  {
    _getReward();
  }

  /* ================================================= RESTRICTED FUNCTIONS ================================================= */

  /**
   * @notice NotifyRewardAmount
   * @dev This function can only be called by rewardsDistribution contract to provide rewards.
   */
  function notifyRewardAmount()
    external
    payable
    onlyRewardsDistribution
    updateReward(address(0))
  {
    require(msg.value == rewardsAmount, 'Whole rewardsAmount should be sent');

    uint256 marketAveragePrice = priceFeeder.getMarketAveragePrice();
    uint256 currentPrice = priceFeeder.getCurrentPrice();

    uint256 reward;

    if (marketAveragePrice <= lowestVotingBoundPrice) {
      // normal rewards
      reward = rewardsAmount;
    } else if (marketAveragePrice <= currentPrice) {
      // reward based on dao multiplie
      uint256 daoMultiplier = shyftDao.getDaoMultiplier();
      require(
        daoMultiplier > 0 && daoMultiplier <= 1 ether,
        'Wrong dao multiplier limits'
      );
      reward = rewardsAmount.mul(daoMultiplier).div(1 ether);
    } else {
      // no rewards
      reward = 0;
    }

    if (block.timestamp >= periodFinish) {
      rewardRate = reward.div(rewardsDuration);
    } else {
      uint256 remaining = periodFinish.sub(block.timestamp);
      uint256 leftover = remaining.mul(rewardRate);
      rewardRate = reward.add(leftover).div(rewardsDuration);
    }

    lastUpdateTime = block.timestamp;
    periodFinish = block.timestamp.add(rewardsDuration);

    emit RewardAdded(reward);

    msg.sender.transfer(msg.value.sub(reward));
  }

  /**
   * @notice SetRewardsDuration
   * @dev This function can be called by the owner to change the rewards period.
   * @notice Can only be called after previous rewards period has finished.
   * @param rewardsDuration_ The new rewards duration.
   */
  function setRewardsDuration(uint256 rewardsDuration_) external onlyOwner {
    require(
      block.timestamp > periodFinish,
      'Previous rewards period must be complete before changing the duration for the new period'
    );
    rewardsDuration = rewardsDuration_;
    emit RewardsDurationUpdated(rewardsDuration);
  }

  /**
   * @notice SetRewardsAmount
   * @dev This function can be called by the owner to change the normal rewards amount.
   * @param rewardsAmount_ The new rewards amount.
   */
  function setRewardsAmount(uint256 rewardsAmount_) external onlyOwner {
    rewardsAmount = rewardsAmount_;
    emit RewardAmountUpdated(rewardsAmount);
  }

  /**
   * @notice SetLowestVotingBoundPrice
   * @dev This function can be called by the owner to change the lowest voting bound price.
   * @param lowestVotingBoundPrice_ The new lowest voting bound price.
   */
  function setLowestVotingBoundPrice(uint256 lowestVotingBoundPrice_)
    external
    onlyOwner
  {
    lowestVotingBoundPrice = lowestVotingBoundPrice_;
    emit LowestVotingBoundPriceUpdated(lowestVotingBoundPrice);
  }

  /**
   * @notice setPriceFeeder
   * @dev This function can be called by the owner to change the priceFeeder contract.
   * @param priceFeeder_ The new priceFeeder address.
   */
  function setPriceFeeder(address priceFeeder_) external onlyOwner {
    priceFeeder = IPriceFeeder(priceFeeder_);
  }

  /**
   * @notice setShyftDao
   * @dev This function can be called by the owner to change the shyftDao contract.
   * @param shyftDao_ The new shyftDao address.
   */
  function setShyftDao(address shyftDao_) external onlyOwner {
    shyftDao = IShyftDao(shyftDao_);
  }

  /**
   * @notice setRewardsDistribution
   * @dev This function can be called by the owner to change the rewardsDistribution address.
   * @param rewardsDistribution_ The new rewardsDistribution address.
   */
  function setRewardsDistribution(address rewardsDistribution_)
    external
    onlyOwner
  {
    rewardsDistribution = rewardsDistribution_;
  }

  /**
   * @notice AddPrePurchasers
   * @dev This function can be called by the owner to add prepurchasers.
   * @notice Can only be called before any rewards have been provided.
   * @notice Careful on inputs creation, prepurchasers already added cannot be added again.
   * @param prePurchasers The array of the prepurchasers' addresses to be added.
   * @param amounts The array of the amounts to be added for each prepurchaser.
   */
  function addPrePurchasers(
    address[] calldata prePurchasers,
    uint256[] calldata amounts
  ) external onlyOwner {
    require(
      rewardRate == 0,
      'Cannot add prepurchasers after rewards are provided'
    );
    require(
      prePurchasers.length == amounts.length && prePurchasers.length > 0,
      'Wrong input'
    );

    for (uint256 i = 0; i < prePurchasers.length; i++) {
      require(amounts[i] > 0, 'Amount to be added must be greater than 0');
      require(
        prePurchasersDetails[prePurchasers[i]].amountAdded == 0,
        'Cannot add prepurchaser again'
      );
      prePurchasersDetails[prePurchasers[i]].amountAdded = amounts[i];

      _totalSupply = _totalSupply.add(amounts[i]);
      totalPrePurchasersAmountToBeStaked = totalPrePurchasersAmountToBeStaked
        .add(amounts[i]);

      emit PrePurchaserAdded(prePurchasers[i], amounts[i]);
    }
  }

  /**
   * @notice FinishPrePurchasersMode
   * @dev This function can be called by the owner to finish the prepurchasers mode.
   * @notice After that function is called prepurchasers that have not yet staked are losing
   * @notice already farmed rewards, which are returned back to the rewardsDistribution contract.
   */
  function finishPrePurchasersMode()
    external
    onlyOwner
    onlyAfterRelease
    onlyPrePurchaserModeOn
  {
    prePurchasersModeOn = false;

    uint256 rewardsToBeReturned = totalPrePurchasersAmountToBeStaked
      .mul(rewardPerShft())
      .div(1e18);
    uint256 newTotalSupply = _totalSupply.sub(
      totalPrePurchasersAmountToBeStaked
    );
    rewardRate = rewardRate.mul(newTotalSupply).div(_totalSupply);
    _totalSupply = newTotalSupply;

    address(uint160(rewardsDistribution)).transfer(rewardsToBeReturned);

    emit PrepurchasersModeFinished(rewardsToBeReturned);
  }

  /* ======================================================= INTERNALS ====================================================== */

  function _unbond(uint256 amount_) internal {
    require(amount_ > 0, 'Cannot unbond 0');
    require(_balances[msg.sender] >= amount_, 'Cannot unbond more than staked');

    _totalSupply = _totalSupply.sub(amount_);
    _balances[msg.sender] = _balances[msg.sender].sub(amount_);

    totalUnbondings = totalUnbondings.add(1);

    unbondingIdsPerAddress[msg.sender].push(totalUnbondings);

    UnbondingDetails memory currentUnbondingDetails;
    currentUnbondingDetails.account = msg.sender;
    currentUnbondingDetails.remainingAmount = amount_;
    currentUnbondingDetails.unstakeEnabledTimestamp = block.timestamp.add(
      unbondingPeriod
    );
    currentUnbondingDetails.indexIntoUnbondingArray = unbondingIdsPerAddress[
      msg.sender
    ].length.sub(1);

    unbondingDetailsForId[totalUnbondings] = currentUnbondingDetails;

    emit Unbonded(msg.sender, amount_, block.timestamp, totalUnbondings);
  }

  function _getReward() internal {
    uint256 reward = rewards[msg.sender];
    if (reward > 0) {
      rewards[msg.sender] = 0;
      msg.sender.transfer(reward);

      emit RewardPaid(msg.sender, reward);
    }
  }

  /* ========================================================= VIEWS ======================================================== */

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function lastTimeRewardApplicable() public view returns (uint256) {
    return block.timestamp < periodFinish ? block.timestamp : periodFinish;
  }

  function rewardPerShft() public view returns (uint256) {
    if (_totalSupply == 0) {
      return rewardPerShftStored;
    }
    return
      rewardPerShftStored.add(
        lastTimeRewardApplicable()
          .sub(lastUpdateTime)
          .mul(rewardRate)
          .mul(1e18)
          .div(_totalSupply)
      );
  }

  function earned(address account) public view returns (uint256) {
    return
      _balances[account]
        .mul(rewardPerShft().sub(userRewardPerShftPaid[account]))
        .div(1e18)
        .add(rewards[account]);
  }

  function getRewardForDuration() external view returns (uint256) {
    return rewardRate.mul(rewardsDuration);
  }

  function getUnbondingIdsLength(address account)
    external
    view
    returns (uint256)
  {
    return unbondingIdsPerAddress[account].length;
  }

  function getUnbondingIds(
    address account,
    uint256 offset,
    uint256 size
  ) external view returns (uint256[] memory, uint256) {
    uint256 length = size;
    uint256 unbondingIdsLength = unbondingIdsPerAddress[account].length;

    if (length > unbondingIdsLength - offset) {
      length = unbondingIdsLength - offset;
    }

    uint256[] memory unbondingIds = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      unbondingIds[i] = unbondingIdsPerAddress[account][i + offset];
    }

    return (unbondingIds, offset + length);
  }
}
