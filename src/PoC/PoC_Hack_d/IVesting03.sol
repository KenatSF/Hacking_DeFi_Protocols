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