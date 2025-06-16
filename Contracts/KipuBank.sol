// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/** 
 * @title KIPU bank contract
 */
contract KipuBank {
    // ============== STATE VARS ==============

    /*
     * @notice Max limit in wei that the contract accept.
     * @dev Set in the constructor and cannot be change.
     */
    uint256 public immutable bankCap;
    
    /*
     * @notice Max limit in wei that can be withdraw by one user in each transacction.
     * @dev Set in the constructor and cannot be change.
     */
    uint256 public immutable thresholdWithdrawl;
     
    /*
     * @notice Total balance deposit from all user in wei.  
     * @dev Update in each deposit and withrdraw.
     */
    uint256 public totalDeposits;

    /*
     * @notice Deposits operations counter.  
     * @dev Update in each success deposit.
     */
    uint256 public depositCount;

    /*
     * @notice Withdrawals operations counter.  
     * @dev Update in each success withrdrawal.
     */
    uint256 public withdrawalCount;

    // ============== Mappings ==============
    /*
     * @notice User mapping to balance in vaults.  
     * @dev Balance only update in success deposits or withrawlas.
     */
    mapping(address => uint256) public vaults;

    // ============== ERRORS ==============
    /*
     * @notice Error reverts transacction when deposit amount exceeds global bank cap.  
     * @param amount in wei trying to deposit by user.
     * @param remainBankCap Remaining bank capacity in wei.
     */
    error ExceedsBankCap(uint256 amount, uint256 remainBankCap); 
    
    /*
     * @notice Error reverts transacction when amount to withdraw exceeds 
       `thresholdWithdrawl` state var.  
     * @param amount in wei trying to withdraw by user.
     * @param thresholdWithdrawl Current config state var value.
     */
    error ExceedsWithdrawlThreshold(uint256 amount, uint256 thresholdWithdrawl);

    /*
     * @notice Error reverts transacction when withdrawal amount exceeds user vault balance.  
     * @param user Address from user.
     * @param amount in wei trying to withdraw by user.
     * @param vaultBalance Current user vault balance.
     */
    error InsufficientVaultBalance(address user, uint256 amount, uint256 vaultBalance);
    
    /*
     * @notice Error reverts deploy when `thresholdWithdrawl` > `bankCap`.
     * @dev Avoid wrong contract config.
     */
    error InvalidThreshold();

    /*
     * @notice Error reverts when amount is cero.
     * @dev Avoid deposit/withdraw without value.
     */
    error ZeroAmountNotAllowed();

    // ============== EVENTS ==============

    /*
     * @notice Emit on a successful deposits.  
     * @param user Address from user.
     * @param depositAmount Amount deposited in wei.
     * @param newVaultBalance Updated user vualt balance after deposit in wei.
     * @param newtotalDeposits Updated global total after deposit in wei.
     */
    event SuccessDeposit(
        address indexed user,
        uint256 depositAmount,
        uint256 newVaultBalance,
        uint256 newtotalDeposits
    );

    /*
     * @notice Emit on a successful withdraw.  
     * @param user Address from user.
     * @param withdrawAmount Amount withdrawal in wei.
     * @param newVaultBalance Updated user vualt balance after withdraw in wei.
     * @param newtotalDeposits Updated global total after withdraw in wei.
     */
    event SuccessWithdraw(
        address indexed user,
        uint256 withdrawAmount,
        uint256 newVaultBalance,
        uint256 newtotalDeposits
    );

    /*
     * @notice Emit on a failed deposit
     * @param user Address from user.
     * @param reason Reason for error.
     * @param amount Attempted amountin wei.
     */
    event FailedDeposit (
        address indexed user,
        string reason,
        uint256 amount
    );

    /*
     * @notice Emit on a failed withdraw
     * @param user Address from user.
     * @param reason Reason for error.
     * @param amount Attempted amountin wei.
     */
    event FailedWithdrawl(
        address indexed user,
        string reason,
        uint256 amout
    );


    // ============== CONSTRUCTOR ==============
    /*
     * @notice Initialize contract with bank cap and threshold withdrawl. 
     * @param _bankCap Max total in wei for the contract.
     * @param _thresholdWithdrawl Max in wei a user can withdraw in one transaction.
     * @custom:error ZeroAmountNotAllowed
     * @custom:error InvalidThreshold
     */
    constructor(uint256 _bankCap, uint256 _thresholdWithdrawl) {
        if (_bankCap == 0 || _thresholdWithdrawl == 0 ) revert ZeroAmountNotAllowed();
        if (_bankCap < _thresholdWithdrawl) revert InvalidThreshold();
        bankCap = _bankCap;
        thresholdWithdrawl = _thresholdWithdrawl;
    }

    // ============== MODDIFIERS ==============
    /*
     * @notice Check that a deposit don't exceed global bank cap.
     * @dev revert with ExceedsBankCap.
     * @param amount The deposit amount (in wei) to check against remaining capacity.
     * @custom:event FailedDeposit
     * @custom:error ExceedsBankCap
     */ 
    modifier checkBankCap(uint256 amount){
        if (totalDeposits + amount > bankCap){
            emit FailedDeposit (
                msg.sender, 
                "ExceedsBankCap", 
                amount
            );
            revert ExceedsBankCap(amount, bankCap - totalDeposits);
        }  
        _;
    }


    // ============== FUNCTIONS ==============

     /*
     * @notice Deposit ETH in the user vault 
     * @dev Check for the a valid amount and global bank cap before process
     * @custom:event FailedDeposit.
     * @custom:event SuccessDeposit.
     * @custom:modifier checkBankCap for the global total bank cap
     * @custom:error ZeroAmountNotAllowed.
     */
    function deposit() external payable checkBankCap(msg.value) {
        if (msg.value == 0){
            emit FailedDeposit(msg.sender, "ZeroAmountNotAll", 0);
            revert ZeroAmountNotAllowed();
        }
        _processDeposit(msg.sender, msg.value);
        emit SuccessDeposit(
            msg.sender,
            msg.value,
            vaults[msg.sender],
            totalDeposits
        );
    }

    /*
     * @notice Withdraw ETH from the user's vault
     * @dev Check for a valid amount, max threshold for each withdraw and
        vault balance before pocressing.
     * @param Desire mmount in wei to withdraw from user vault
     * @custom:event FailedWithdrawal
     * @custom:event SuccessWithdrawal
     * @custom:error ZeroAmountNotAllowed
     * @custom:error ExceedsWithdrawalThreshold
     * @custom:error InsufficientVaultBalance
     */
    function withdraw(uint256 amount) external {
        if (amount == 0){
            emit FailedWithdrawl(msg.sender, "ZeroAmountNotAll", 0);
            revert ZeroAmountNotAllowed();
        }
        if (amount > thresholdWithdrawl) {
            emit FailedWithdrawl(
                msg.sender,
                "ExceedsWithdrawlThreshold",
                amount
            );
            revert ExceedsWithdrawlThreshold(amount, thresholdWithdrawl); 
        }
        if (amount > vaults[msg.sender]){
            emit FailedWithdrawl(
                msg.sender,
                "InsufficientVaultBalance",
                amount
            );
            revert InsufficientVaultBalance(msg.sender, amount, vaults[msg.sender]);
        }
        _processWithdraw(msg.sender, amount);
        emit SuccessWithdraw(
            msg.sender,
            amount,
            vaults[msg.sender],
            totalDeposits
        );
    }

    /*
     * @notice Process the interal logic from a deposit
     * @dev Update balances and counters. Only call from `deposit()`
     * @param user Address from user
     * @param amount in Wei to deposit in user vault
     */
    function _processDeposit(address _user, uint256 _amount) private {
        vaults[_user] += _amount;
        totalDeposits += _amount;
        depositCount++;
    } 

    /*
     * @notice Process the interal logic from a widthdraw
     * @dev Update balances and counters. Only call from `withdraw()`
     * @param user Address from user
     * @param Widthdraw amount in Wei
     */
    function _processWithdraw(address _user, uint256 _amount) private {
        vaults[_user] -= _amount;
        totalDeposits -= _amount;
        withdrawalCount++;
    }

    // ============== AUX FUNCTIONS ==============
    /*
     * @notice View vault balance from user
     * @dev View function
     * @param Address from the user
     * @return Vault balance in wei
     */
    function getVaultBalance(address _user) external view returns (uint256) {
        return vaults[_user];
    }
}