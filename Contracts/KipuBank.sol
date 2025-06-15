// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/** 
 * @title KIPU bank contract
 */
contract KipuBank {
    // ============== STATE VARS ==============
    // ---- Immutable ---- 
    uint256 public immutable thresholdWithdrawl;
    uint256 public immutable bankCap; // Deposit global cap

    // ---- Storage ---- 
    uint256 public totalDeposits;
    uint256 public depositCount;
    uint256 public withdrawalCount;

    // ============== Mappings ==============
    mapping(address => uint256) public vaults;

    // ============== ERRORS ==============
    error ExceedsBankCap(uint256 amount, uint256 remainBankCap); 
    error ExceedsWithdrawlThreshold(uint256 amount, uint256 thresholdWithdrawl);
    error InsufficientVaultBalance(address user, uint256 amount, uint256 vaultBalance);
    error InvalidThreshold();
    error ZeroAmountNotAllowed();

    // ============== EVENTS ==============
    event NewDeposit(
        address indexed user,
        uint256 depositAmount,
        uint256 newVaultBalance,
        uint256 newtotalDeposits
    );
    event NewWithdraw(
        address indexed user,
        uint256 withdrawAmount,
        uint256 newVaultBalance,
        uint256 newtotalDeposits
    );

    // ============== CONSTRUCTOR ==============
    constructor(uint256 _bankCap, uint256 _thresholdWithdrawl) {
        // Init Checks
        if (_bankCap == 0 || _thresholdWithdrawl == 0 ) revert ZeroAmountNotAllowed();
        if (_bankCap < _thresholdWithdrawl) revert InvalidThreshold();
        // Init 
        bankCap = _bankCap;
        thresholdWithdrawl = _thresholdWithdrawl;
    }

    // ============== MODDIFIERS ==============
    modifier checkBankCap(uint256 amount){
        if (totalDeposits + amount > bankCap){
            revert ExceedsBankCap(amount, bankCap - totalDeposits);
        }  
        _;
    }

    modifier validAmount(uint256 amount){
        if (amount == 0) revert ZeroAmountNotAllowed();
        _;
    }

    // ============== FUNCTIONS ==============
    // ---- Main ----
     /*
     * @notice Deposit ETH in the user vault 
     * @dev Check for the a valid amount and global bank cap before process
     * @custom modifier validAmount for deposits of 0 ETH
     * @custom modifier checkBankCap for the global total bank cap
     */
    function deposit() external payable validAmount(msg.value) checkBankCap(msg.value) {
        _processDeposit(msg.sender, msg.value);
        emit NewDeposit(
            msg.sender,
            msg.value,
            vaults[msg.sender],
            totalDeposits
        );
    }

    /*
     * @notice Withdraw ETH from the user vault
     * @dev Check for a valid amount, max threshold for each withdraw and
        vault balance before pocress
     * @param amount Desire wei to withdraw from user vault
     */
    function withdraw(uint256 amount) external validAmount(amount) {
        if (amount > thresholdWithdrawl) revert ExceedsWithdrawlThreshold(amount, thresholdWithdrawl); 
        if (amount > vaults[msg.sender]) revert InsufficientVaultBalance(msg.sender, amount, vaults[msg.sender]);
        _processWithdraw(msg.sender, amount);
        emit NewWithdraw(
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

    // ---- Aux ----
    /*
     * @notice 
     * @dev 
     * @param
     * @return
     */
    function getVaultBalance(address _user) external view returns (uint256) {
        return vaults[_user];
    }
}