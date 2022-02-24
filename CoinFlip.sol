// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IEscrow {
    function withdraw(address recipient, uint256 amount) external;
}

contract CoinFlip is Ownable {

    address escrow_address;

    bool lastBettingResult;

    // constructor 
    constructor(address _escrow_address) {
        escrow_address = _escrow_address;
    }

    function flip(uint256 betAmount) external {
        //TODO change to some real random generator on Ethereum network
        uint flipVal = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 2;
        if (flipVal == 0) {
            // win
            IEscrow(escrow_address).withdraw(address(msg.sender), betAmount * 2);
            lastBettingResult = true;
        } else {
            // lose
            lastBettingResult = false;
        }
    }

    function getLastBettingResult() external view returns (bool) {
        return lastBettingResult;
    }
}