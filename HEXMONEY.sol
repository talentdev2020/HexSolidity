//HEXMONEY.sol
//
//

pragma solidity 0.6.4;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./HEX.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

//Uniswap factory interface
interface UniswapFactoryInterface {
    // Create Exchange
    function createExchange(address token) external returns (address exchange);
    // Get Exchange and Token Info
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
    // Never use
    function initializeFactory(address template) external;
}

//Uniswap Interface
interface UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
}

////////////////////////////////////////////////
////////////////////EVENTS/////////////////////
//////////////////////////////////////////////

contract TokenEvents {

    //when a user freezes tokens
    event TokenFreeze(
        address indexed user,
        uint value
    );

    //when a user unfreezes tokens
    event TokenUnfreeze(
        address indexed user,
        uint value
    );

    //when a user transforms HEX to HXY
    event Transform (
        uint hexAmt,
        uint hxyAmt,
        address indexed transformer
    );

    //when founder tokens are locked
    event FounderLock (
        uint hxyAmt,
        uint timestamp
    );

    //when founder tokens are unlocked
    event FounderUnlock (
        uint hxyAmt,
        uint timestamp
    );
}

//////////////////////////////////////
//////////HEXMONEY TOKEN CONTRACT////////
////////////////////////////////////
contract HEXMONEY is IERC20, TokenEvents {

    using SafeMath for uint256;
    using SafeERC20 for HEXMONEY;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    //uniswap setup
    address internal uniFactory = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address internal uniETHHEX = 0x05cDe89cCfa0adA8C88D5A23caaa79Ef129E7883;
    address public uniETHHXY = address(0);
    UniswapExchangeInterface internal uniHEXInterface = UniswapExchangeInterface(uniETHHEX);
    UniswapExchangeInterface internal uniHXYInterface;
    UniswapFactoryInterface internal uniFactoryInterface = UniswapFactoryInterface(uniFactory);
    //hex contract setup
    address internal hexAddress = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;
    HEX internal hexInterface = HEX(hexAddress);
    //transform room
    bool public roomActive;
    uint public roundCap = 0;
    uint public roundTransformed = 0;
    uint public totalHeartsTransformed = 0;
    uint public totalHXYTransformed = 0;
    uint public distributable = 0;
    //mint / freeze
    uint public unlockLvl = 0;
    uint public lockStartTimestamp = 0;
    uint public lockDayLength = 1825;//5 years (10% released every 6 months)
    uint public lockedTokens = 0;
    uint private allLocked = 0;

    bool public mintBlock;//disables any more tokens ever being minted once _totalSupply reaches _maxSupply
    uint public mintRatio = 1000; //1000 for 0.1% (1 HXY for every 1000 HEX)
    uint public minFreezeDayLength = 7; // min days to freeze
    uint internal daySeconds = 86400; // seconds in a day
    uint public totalFrozen = 0;
    mapping (address => uint) public tokenFrozenBalances;//balance of HXY frozen mapped by user

    //tokenomics
    uint256 public _maxSupply = 6000000000000000;// max supply @ 60M
    uint256 internal _totalSupply;
    string public constant name = "HEX Money";
    string public constant symbol = "HXY";
    uint public constant decimals = 8;

    //multisig
    address payable internal MULTISIG = 0x35C7a87EbC3E9fBfd2a31579c70f0A2A8D4De4c5;
    //admin
    address payable internal FOUNDER = 0xc61f905832aE9FB6Ef5BaD8CF6e5b8B5aE1DF026;
    address payable internal KYLE = 0xD30BC4859A79852157211E6db19dE159673a67E2;
    address payable internal MICHAEL = 0xe551072153c02fa33d4903CAb0435Fb86F1a80cb;
    address payable internal SWIFT = 0x7251FFB72C77221D16e6e04c9CD309EfFd0F940D;
    address payable internal MARCO = 0xbf1984B12878c6A25f0921535c76C05a60bdEf39;
    uint public donationGasLimit = 21000;
    bool private locked;
    //team
    address payable internal MARK = 0x35e9034f47cc00b8A9b555fC1FDB9598b2c245fD;
    address payable internal JARED = 0x5eCb4D3B4b451b838242c3CF8404ef18f5C486aB;
    address payable internal LOUIS = 0x454f203260a74C0A8B5c0a78fbA5B4e8B31dCC63;
    address payable internal DONATOR = 0x723e82Eb1A1b419Fb36e9bD65E50A979cd13d341;
    address payable internal KEVIN = 0x3487b398546C9b757921df6dE78EC308203f5830;
    address payable internal AMIRIS = 0x406D1fC98D231aD69807Cd41d4D6F8273401354f;
    //investor
    address payable internal ANGEL = 0xF80A891c1A7600dDd84b1F9d54E0b092610Ed804;
    //minters
    address[] public minterAddresses;// future contracts to enable minting of HXY relative to HEX 1000:1

    mapping(address => bool) admins;
    mapping(address => bool) minters;
    mapping (address => Frozen) public frozen;

    struct Frozen{
        uint freezeStartTimestamp;
    }
    
    modifier onlyMultisig(){
        require(msg.sender == MULTISIG, "not authorized");
        _;
    }

    modifier onlyAdmins(){
        require(admins[msg.sender], "not an admin");
        _;
    }

    modifier onlyMinters(){
        require(minters[msg.sender], "not a minter");
        _;
    }
    
    //protects against potential reentrancy
    modifier synchronized {
        require(!locked, "Sync lock");
        locked = true;
        _;
        locked = false;
    }

    constructor() public {
        admins[FOUNDER] = true;
        admins[KYLE] = true;
        admins[MARCO] = true;
        admins[SWIFT] = true;
        admins[MICHAEL] = true;
        admins[msg.sender] = true;
        //mint founder tokens
        mintFounderTokens(_maxSupply.mul(20).div(100));//20% of max supply
        //create uni exchange
        uniETHHXY = uniFactoryInterface.createExchange(address(this));
        uniHXYInterface = UniswapExchangeInterface(uniETHHXY);
    }

    //fallback for eth sent to contract - auto distribute as donation
    receive() external payable{
        donate();
    }

    function _initialLiquidity()
        public
        payable
        onlyAdmins
        synchronized
    {
        require(msg.value >= 0.001 ether, "eth value too low");
        //add liquidity
        uint heartsForEth = uniHEXInterface.getEthToTokenInputPrice(msg.value);//price of eth value in hex
        uint hxy = heartsForEth / mintRatio;
        _mint(address(this), hxy);//mint tokens to this contract
        this.safeApprove(uniETHHXY, hxy);//approve uni exchange contract
        uniHXYInterface.addLiquidity{value:msg.value}(0, hxy, (now + 15 minutes)); //send tokens and eth to uni as liquidity*/
    }
    
    
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply unless mintBLock is true
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        uint256 amt = amount;
        require(account != address(0), "ERC20: mint to the zero address");
        if(!mintBlock){
            if(_totalSupply < _maxSupply){
                if(_totalSupply.add(amt) > _maxSupply){
                    amt = _maxSupply.sub(_totalSupply);
                    _totalSupply = _maxSupply;
                    mintBlock = true;
                }
                else{
                    _totalSupply = _totalSupply.add(amt);
                }
                _balances[account] = _balances[account].add(amt);
                emit Transfer(address(0), account, amt);
            }
        }
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);//from address(0) for minting

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //mint HXY to founders (only ever called in constructor)
    function mintFounderTokens(uint tokens)
        internal
        synchronized
        returns(bool)
    {
        require(tokens <= _maxSupply.mul(20).div(100), "founder tokens cannot be over 20%");
        address minter = FOUNDER;

        _mint(minter, tokens/2);//mint HXY
        _mint(address(this), tokens/2);//mint HXY to be locked for 5 years, 10% unlocked every 6 months
        lock(tokens/2);
        return true;
    }

    function lock(uint tokens)
        internal
    {
        lockStartTimestamp = now;
        lockedTokens = tokens;
        allLocked = tokens;
        emit FounderLock(tokens, lockStartTimestamp);
    }

    function unlock()
        public
        onlyAdmins
        synchronized
    {
        uint sixMonths = lockDayLength/10;
        require(unlockLvl < 10, "token unlock complete");
        require(lockStartTimestamp.add(sixMonths.mul(daySeconds)) <= now, "tokens cannot be unlocked yet");//must be at least over 6 months
        uint value = allLocked/10;
        if(lockStartTimestamp.add((sixMonths).mul(daySeconds)) <= now && unlockLvl == 0){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 2).mul(daySeconds)) <= now && unlockLvl == 1){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 3).mul(daySeconds)) <= now && unlockLvl == 2){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 4).mul(daySeconds)) <= now && unlockLvl == 3){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value); 
        }
        else if(lockStartTimestamp.add((sixMonths * 5).mul(daySeconds)) <= now && unlockLvl == 4){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 6).mul(daySeconds)) <= now && unlockLvl == 5){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value); 
        }
        else if(lockStartTimestamp.add((sixMonths * 7).mul(daySeconds)) <= now && unlockLvl == 6){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 8).mul(daySeconds)) <= now && unlockLvl == 7)
        {
            unlockLvl++;     
            lockedTokens = lockedTokens.sub(value);      
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 9).mul(daySeconds)) <= now && unlockLvl == 8){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 10).mul(daySeconds)) <= now && unlockLvl == 9){
            unlockLvl++;
            if(lockedTokens >= value){
                lockedTokens = lockedTokens.sub(value);
            }
            else{
                value = lockedTokens;
                lockedTokens = 0;
            }
            transfer(FOUNDER, value);
        }
        else{
            revert();
        }
        emit FounderUnlock(value, now);
    }
    ////////////////////////////////////////////////////////
    /////////////////PUBLIC FACING - HXY CONTROL//////////
    //////////////////////////////////////////////////////

    //freeze HXY tokens to contract - resets freeze time , if re-freezing before minFreezeDayLength any profit from already frozen tokens is lost along with resetting the freezeStartTimestamp, incentivizing freezing larger amounts for longer.
    function FreezeTokens(uint amt)
        public
    {
        require(amt > 0, "zero input");
        require(tokenBalance() >= amt, "Error: insufficient balance");//ensure user has enough funds
        if(isFreezeFinished()){
            UnfreezeTokens();//unfreezes all currently froze tokens + profit
        }
        //update balances
        tokenFrozenBalances[msg.sender] = tokenFrozenBalances[msg.sender].add(amt);
        totalFrozen = totalFrozen.add(amt);
        frozen[msg.sender].freezeStartTimestamp = now;
        _transfer(msg.sender, address(this), amt);//make transfer
        emit TokenFreeze(msg.sender, amt);
    }

    //unfreeze HXY tokens from contract
    function UnfreezeTokens()
        public
        synchronized
    {
        require(tokenFrozenBalances[msg.sender] > 0,"Error: unsufficient frozen balance");//ensure user has enough locked funds
        require(isFreezeFinished(), "tokens cannot be unlocked yet. min 7 day freeze");
        uint amt = tokenFrozenBalances[msg.sender];
        _mint(msg.sender, calcFreezingRewards());//mint HXY - total unfrozen / 1000 * minFreezeDayLength + days past
        tokenFrozenBalances[msg.sender] = 0;
        frozen[msg.sender].freezeStartTimestamp = 0;
        totalFrozen = totalFrozen.sub(amt);
        _transfer(address(this), msg.sender, amt);//make transfer
        emit TokenUnfreeze(msg.sender, amt);
    }

    //returns freezing reward in hxy
    function calcFreezingRewards()
        public
        view
        returns(uint)
    {
        return (tokenFrozenBalances[msg.sender].div(mintRatio) * minFreezeDayLength + daysPastMinFreezeLength());
    }
    
    //returns amount of days frozen past min freeze length of 7 days
    function daysPastMinFreezeLength()
        public
        view
        returns(uint)
    {
        uint daysPast = now.sub(frozen[msg.sender].freezeStartTimestamp).div(daySeconds);
        if(daysPast >= minFreezeDayLength){
            return daysPast - minFreezeDayLength;// returns 0 if under 1 day passed
        }
        else{
            return 0;
        }
    }

    //transforms HEX to HXY @ 1000:1
    function transformHEX(uint hearts, address ref)//Approval needed
        public
        synchronized
    {
        require(roomActive, "transform room not active");
        require(hexInterface.transferFrom(msg.sender, address(this), hearts), "Transfer failed");//send hex from user to contract
        //transform
        uint HXY = hearts / mintRatio;//HXY tokens to mint
        if(ref != address(0))//ref
        {
            require(roundCap >= roundTransformed.add(HXY.add(HXY.div(10))), "round supply cap reached");
            require(roundCap < _maxSupply.sub(totalSupply()), "round cap exeeds remaining maxSupply, reduce roundCap");
            roundTransformed += HXY.add(HXY.div(10));
            totalHXYTransformed += HXY.add(HXY.div(10));
            totalHeartsTransformed += hearts;
            _mint(ref, HXY.div(10));
        }
        else{//no ref
            require(roundCap >= roundTransformed.add(HXY), "round supply cap reached");
            require(roundCap < _maxSupply.sub(totalSupply()), "round cap exeeds remaining maxSupply, reduce roundCap");
            roundTransformed += HXY;
            totalHXYTransformed += HXY;
            totalHeartsTransformed += hearts;
        }
        _mint(msg.sender, HXY);//mint HXY - 0.1% of total heart value @ 1 HXY for 1000 HEX
        distributable += hearts;
        emit Transform(hearts, HXY, msg.sender);
    }
    
    //mint HXY to address ( for use in external contracts within the eco-system)
    function mintHXY(uint hearts, address receiver)
        public
        onlyMinters
        returns(bool)
    {
        uint amt = hearts.div(mintRatio);
        address minter = receiver;
        _mint(minter, amt);//mint HXY - 0.1% of total heart value @ 1 HXY for 1000 HEX
        return true;
    }

    ///////////////////////////////
    ////////ADMIN ONLY//////////////
    ///////////////////////////////

    //allows addition of contract addresses that can call this contracts mint function.
    function addMinter(address minter)
        public
        onlyMultisig
        returns (bool)
    {        
        minters[minter] = true;
        minterAddresses.push(minter);
        return true;
    }

    //toggle transform room on/off. specify percantage of maxSupply available to transform
    function toggleRoundActive(uint percentSupplyCap)
        public
        onlyAdmins
    {
        require(percentSupplyCap < (100 - (_totalSupply.mul(100).div(_maxSupply))), "percentage supplied to high");
        if(!roomActive){
            roomActive = true;
            roundCap = _maxSupply.mul(percentSupplyCap).div(100);
            roundTransformed = 0;
        }
        else{
            roomActive = false;
        }
    }

    ///////////////////////////////
    ////////VIEW ONLY//////////////
    ///////////////////////////////

    //total HXY frozen in contract
    function totalFrozenTokenBalance()
        public
        view
        returns (uint256)
    {
        return totalFrozen;
    }

    //HXY balance of caller
    function tokenBalance()
        public
        view
        returns (uint256)
    {
        return balanceOf(msg.sender);
    }

    //
    function isFreezeFinished()
        public
        view
        returns(bool)
    {
        if(frozen[msg.sender].freezeStartTimestamp == 0){
            return false;
        }
        else{
           return frozen[msg.sender].freezeStartTimestamp.add((minFreezeDayLength).mul(daySeconds)) <= now;               
        }

    }
    
    
    function distributeTransformedHex () public {
        //get balance    
        require(distributable > 99, "balance too low to distribute");
        //distribute
        uint256 percent = distributable.div(100);
        uint teamPercent = percent.mul(20);
        //
        hexInterface.transfer(LOUIS, teamPercent.div(7));
        hexInterface.transfer(AMIRIS, teamPercent.div(7));
        hexInterface.transfer(MARK, teamPercent.div(7));
        hexInterface.transfer(KEVIN, teamPercent.div(7));
        hexInterface.transfer(DONATOR, teamPercent.div(7));
        hexInterface.transfer(JARED, teamPercent.div(7));
        hexInterface.transfer(KYLE, teamPercent.div(7));
        //
        hexInterface.transfer(MARCO, percent.mul(15));
        hexInterface.transfer(SWIFT, percent.mul(10));
        hexInterface.transfer(ANGEL, percent.mul(20));
        hexInterface.transfer(MICHAEL, percent.mul(15));
        hexInterface.transfer(FOUNDER, percent.mul(20));//10% HXY liquidity allocation + 10% overflow
        distributable = 0;
    }
    
    function donate() public payable {
        require(msg.value > 0);
        bool success = false;
        uint256 balance = msg.value;
        //distribute
        uint256 percent = balance.div(100);
        uint teamPercent = percent.mul(20);
        (success, ) =  LOUIS.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  AMIRIS.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  MARK.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  KEVIN.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  DONATOR.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  JARED.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  KYLE.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        //
        (success, ) =  MARCO.call{value:percent.mul(15)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  SWIFT.call{value:percent.mul(10)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  ANGEL.call{value:percent.mul(20)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  MICHAEL.call{value:percent.mul(15)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  FOUNDER.call{value:percent.mul(20)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
    }

    function setDonateGasLimit(uint gasLimit)
        public
        onlyAdmins
    {
        donationGasLimit = gasLimit;
    }
}
