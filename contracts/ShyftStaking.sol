// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import {IShyftDao} from './interfaces/IShyftDao.sol';
import {IPriceFeeder} from './interfaces/IPriceFeeder.sol';

/**
 * @title ShyftStaking Contract
 */
contract ShyftStaking is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
  using SafeMath for uint256;

  // Timestamp when current staking period is finishing.
  uint256 public periodFinish;
  // The reward rate for current period.
  uint256 public rewardRate;
  // The norma; amount of rewards to be provided every period.
  uint256 public rewardsAmount;
  // The duration of a period.
  uint256 public rewardsDuration;
  // The time needed to be able to unstake after calling unbond.
  uint256 public unbondingPeriod = 28 days;
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
  }

  // UnbondingId => UnbondingDetails.
  mapping(uint256 => UnbondingDetails) public unbondingDetailsForId;
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
  bool prePurchasersModeOn = true;

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
    require(msg.sender == rewardsDistribution,
      "Only rewardsDistribution contract");
    _;
  }

  modifier onlyAfterRelease() {
    require(block.timestamp >= prePurchasersReleaseTimestamp,
      "Cannot withdraw yet");
    _;
  }

  modifier onlyPrePurchaserModeOn() {
    require(prePurchasersModeOn, "Only if prepurchasers mode is ON");
    _;
  }

  /* ======================================================== EVENTS ======================================================== */

  event RewardAdded(uint256 reward);
  event Staked(address indexed user, uint256 amount);
  event Unbonded(address indexed user, uint256 amount, uint256 timestamp, uint256 id);
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
      require(!prePurchasersModeOn,
        "Prepurchasers can normally stake only if prepurchasers mode is not ON"
      );
    }

    uint256 amount = msg.value;
    require(amount > 0, "Cannot stake 0");

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
  function stakePrePurchaser() external payable nonReentrant onlyAfterRelease onlyPrePurchaserModeOn {
    require(!prePurchasersDetails[msg.sender].staked, "Cannot stake again");
    require(prePurchasersDetails[msg.sender].amountAdded > 0,
      "Only Prepurchasers can call this function");
    require(msg.value == prePurchasersDetails[msg.sender].amountAdded,
      "Prepurchasers should stake the whole exact amount");

    uint256 amount = msg.value;

    prePurchasersDetails[msg.sender].staked = true;
    _balances[msg.sender] = _balances[msg.sender].add(amount);

    totalPrePurchasersAmountToBeStaked = totalPrePurchasersAmountToBeStaked.sub(amount);

    emit PrePurchaserStaked(msg.sender, amount);
  }

  /**
   * @notice Unbond
   * @dev This function is used by users to unbond part of their stake.
   * @notice This function can only be called after prepurchasers' release happens.
   * @param amount The amount to be unbonded.
   */
  function unbond(uint256 amount) public nonReentrant onlyAfterRelease updateReward(msg.sender) {
    require(amount > 0, "Cannot unbond 0");

    _totalSupply = _totalSupply.sub(amount);
    _balances[msg.sender] = _balances[msg.sender].sub(amount);

    totalUnbondings = totalUnbondings.add(1);

    UnbondingDetails memory currentUnbondingDetails;
    currentUnbondingDetails.account = msg.sender;
    currentUnbondingDetails.remainingAmount = amount;
    currentUnbondingDetails.unstakeEnabledTimestamp = block.timestamp.add(unbondingPeriod);

    unbondingDetailsForId[totalUnbondings] = currentUnbondingDetails;

    emit Unbonded(msg.sender, amount, block.timestamp, totalUnbondings);
  }

  /**
   * @notice UnbondAll
   * @dev This function is used by users to unbond their whole stake.
   * @notice This function can only be called after prepurchasers' release happens.
   */
  function unbondAll() external {
    unbond(_balances[msg.sender]);
    getReward();
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
    require(block.timestamp >= unbondingDetailsForId[unbondingId].unstakeEnabledTimestamp,
      "Cannot unstake before unbonding period ends");
    require(msg.sender == unbondingDetailsForId[unbondingId].account,
      "Only owner of unbonding id can unstake");
    require(unbondingDetailsForId[unbondingId].remainingAmount >= amount,
      "Cannot unstake more than remaining amount in unbonding id");

    unbondingDetailsForId[unbondingId].remainingAmount =
      unbondingDetailsForId[unbondingId].remainingAmount.sub(amount);

    emit Unstaked(unbondingId, amount);

    msg.sender.transfer(amount);
  }

  /**
   * @notice GetReward
   * @dev This function is used by users to get their rewards.
   * @notice This function can only be called after prepurchasers' release happens.
   */
  function getReward() public nonReentrant onlyAfterRelease updateReward(msg.sender) {
    uint256 reward = rewards[msg.sender];
    if (reward > 0) {
      rewards[msg.sender] = 0;
      msg.sender.transfer(reward);

      emit RewardPaid(msg.sender, reward);
    }
  }

  /* ================================================= RESTRICTED FUNCTIONS ================================================= */

  /**
   * @notice NotifyRewardAmount
   * @dev This function can only be called by rewardsDistribution contract to provide rewards.
   */
  function notifyRewardAmount() external payable onlyRewardsDistribution updateReward(address(0)) {
    require(msg.value == rewardsAmount, "Whole rewardsAmount should be sent");

    uint256 marketAveragePrice = priceFeeder.getMarketAveragePrice();
    uint256 currentPrice = priceFeeder.getCurrentPrice();

    uint256 reward;

    if (marketAveragePrice <= lowestVotingBoundPrice) { // normal rewards
      reward = rewardsAmount;
    } else if (marketAveragePrice <= currentPrice) { // reward based on dao multiplie
      uint256 daoMultiplier = shyftDao.getDaoMultiplier();
      require(daoMultiplier > 0 && daoMultiplier <= 1 ether, "Wrong dao multiplier limits");
      reward = rewardsAmount.mul(daoMultiplier).div(1 ether);
    } else { // no rewards
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
      "Previous rewards period must be complete before changing the duration for the new period"
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
  function setLowestVotingBoundPrice(uint256 lowestVotingBoundPrice_) external onlyOwner {
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
  function setRewardsDistribution(address rewardsDistribution_) external onlyOwner {
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
    require(rewardRate == 0, "Cannot add prepurchasers after rewards are provided");
    require(prePurchasers.length == amounts.length &&
      prePurchasers.length > 0, "Wrong input");

    for (uint256 i = 0; i < prePurchasers.length; i++) {
      require(amounts[i] > 0, "Amount to be added must be greater than 0");
      require(prePurchasersDetails[prePurchasers[i]].amountAdded == 0,
        "Cannot add prepurchaser again");
      prePurchasersDetails[prePurchasers[i]].amountAdded = amounts[i];

      _totalSupply = _totalSupply.add(amounts[i]);
      totalPrePurchasersAmountToBeStaked = totalPrePurchasersAmountToBeStaked.add(amounts[i]);

      emit PrePurchaserAdded(prePurchasers[i], amounts[i]);
    }
  }

  /**
   * @notice FinishPrePurchasersMode
   * @dev This function can be called by the owner to finish the prepurchasers mode.
   * @notice After that function is called prepurchasers that have not yet staked are losing
   * @notice already farmed rewards, which are returned back to the rewardsDistribution contract.
   */
  function finishPrePurchasersMode() external onlyOwner onlyPrePurchaserModeOn {
    prePurchasersModeOn = false;

    uint256 rewardsToBeReturned = totalPrePurchasersAmountToBeStaked.mul(rewardPerShft()).div(1e18);
    _totalSupply = _totalSupply.sub(totalPrePurchasersAmountToBeStaked);

    address(uint160(rewardsDistribution)).transfer(rewardsToBeReturned);

    emit PrepurchasersModeFinished(rewardsToBeReturned);
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
        lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
      );
  }

  function earned(address account) public view returns (uint256) {
    return _balances[account].mul(rewardPerShft().sub(userRewardPerShftPaid[account])).div(1e18).add(rewards[account]);
  }

  function getRewardForDuration() external view returns (uint256) {
    return rewardRate.mul(rewardsDuration);
  }
}
