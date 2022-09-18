// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20, Ownable {

    /////////////////////
    // State Variables //
    /////////////////////
    uint256 private constant MAX_SUPPLY = 69420420420; // 69,420,420,420
    uint256 private immutable INITIAL_SUPPLY; 
    //uint256 private currentSupply; //this may actually be available in ERC20.sol as _totalSupply
    uint256 private circulatingSupply; //right now I have nothing updating this
    //maybe create updateCirculatingSupply function which is then added to mint function to auto-update each time new tokens minted

    uint256 private initialStakingAPR = 69; //not sure if this is even something I need - it's going to vary based on proportion of staked tokens

    address public stakingAddress; 

    constructor(uint256 _initialSupply) ERC20("MockToken", "MOCK") {
        INITIAL_SUPPLY = _initialSupply;
        
        //probably not doing the airdrop at this point, so I need to figure out what i'm going to actually do with this initial supply
        _mint(address(this), INITIAL_SUPPLY); //mints initial supply. Currently have set to mint tokens to the address of the contract, but may change that. Could potentially use a separate contract to hold tokens and handle airdrop, but not sure yet
        //I might just send this initial mint to the deployer, I don't know what exactly I'd do with them sitting in here
        circulatingSupply = totalSupply() - balanceOf(address(this)); //should be zero at time of deployment unless I change where the initial mint goes
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount); 
        updateCirculatingSupply();
    }

    function updateCirculatingSupply() public {
        circulatingSupply = getCurrentSupply() - balanceOf(stakingAddress);
    }

    function setStakingAddress(address _stakingAddress) public onlyOwner {
        stakingAddress = _stakingAddress;
    } //this will only be called once - directly BEFORE ownership is transferred to the staking address;


    //////////////////////
    // Getter Funcitons //
    //////////////////////

    function getMaxSupply() public pure returns (uint256) {
        return MAX_SUPPLY;
    }

    function getInitialSupply() public view returns (uint256) {
        return INITIAL_SUPPLY;
    }

    function getCurrentSupply() public view returns (uint256) {
        return totalSupply();
    }

    function getCirculatingSupply() public view returns (uint256) { 
        return circulatingSupply;
    }

    function getStakedSupply() public view returns (uint256) {
        return balanceOf(stakingAddress);
    }

    function getOwner() public view returns (address) {
        return owner();
    } /* 
       * I want to have the deployer transfer ownership to the staking contract
       * at deployment so that the only way for new tokens to be minted is for
       * the staking contract to call mint() when disbursing staking rewards 
       * 
       * This function can be used to verify that ownership has been transferred
       */
    
    function getBalance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }
}