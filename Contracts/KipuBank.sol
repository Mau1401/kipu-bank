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
    mapping(address => uint256) public vault;

    // ============== ERRORS ==============
    error ExceedsBankCap(); 
    error ExceedsThresholdWithdrawl();
    error InsufficientVaultBalance();
    error InvalidThreshold();
    error ZeroAmountNotAllowed();

    // ============== EVENTS ==============
    event NewDeposit();
    event NewWithdrawal();

    // ============== CONSTRUCTOR ==============
    constructor(uint256 _bankCap, uint256 _thresholdWithdrawl) {
        // Init 
        bankCap = _bankCap;
        thresholdWithdrawl = _thresholdWithdrawl;
    }

    // ============== MODDIFIERS ==============
    modifier checkBankCap(){
        _;
    }

    modifier validAmount(){
        _;
    }

    // ============== FUNCTIONS ==============
    // ---- Main ----
     /*
     * @notice 
     * @dev 
     * @param
     * @return
     */
    function deposit() external payable validAmount checkBankCap {
        // ... deposit logic ...
        emit NewDeposit();
    }

    /*
     * @notice 
     * @dev 
     * @param
     * @return
     */
    function withdraw() external validAmount {
         // ... whitdraw logic ...
        _updateTotalAfterWithdraw();
        emit NewWithdrawal();
    }

    /*
     * @notice 
     * @dev 
     * @param
     * @return
     */
    function _updateTotalAfterWithdraw() private {
    
    } 

    // ---- Aux ----
    /*
     * @notice 
     * @dev 
     * @param
     * @return
     */
    function getVaultBalance() external view returns (uint256) {

    }
}