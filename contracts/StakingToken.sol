// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



/**
* @notice Implements a basic ERC20 staking token with incentive distribution.
*/
contract StakingToken is ERC20, Ownable {
   using SafeMath for uint256;

  uint256 private _totalSupply;
  string private _name;
  string private _symbol;

   constructor (uint256 initialSupply) public ERC20("ginger", "GNG") {
        _mint(msg.sender, initialSupply);
        _totalSupply = initialSupply;
    }

       

    address[] internal stakeholders;


    // variable to store the token buy price
    uint256 tokenBuyPrice;


    // function to modify the token buy price
    function modifyTokenBuyPrice(uint256 _price) public onlyOwner {
        tokenBuyPrice = _price;
    }


    // function to buy/mint new tokens
    function buyToken(uint256 _amount) public payable {
        require(msg.value >= tokenBuyPrice.mul(_amount));
        _mint(msg.sender, _amount);
    }

 

    // function to check wether an address is a stakeholder 
    function isStakeholder(address _address) public view returns (bool, uint256) {

        for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);

    }

    // function to add a stakeholder 
    function addStakeholder(address _stakeholder) public {

        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    // function to remove a stakeholder 
    function removeStakeholder(address _stakeholder) public {

        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
       if(_isStakeholder){
           stakeholders[s] = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
    }

    // mapping data type to keep track of stakes
    mapping(address => uint256) internal stakes;

    
    // function to check the stakes of an address
    function stakeOf(address _stakeholder) public view returns(uint256) {

        return stakes[_stakeholder];
    }


    function totalStakes() public view returns(uint256) {

        uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
       }
       return _totalStakes;
    }


    // mapping data type to keep track of the time a stake was made
    mapping(address => uint256) internal stakeTimes;


    function createStake(uint256 _stake)
       public
   {
       _burn(msg.sender, _stake);
       if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
       stakes[msg.sender] = stakes[msg.sender].add(_stake);
       stakeTimes[msg.sender] = block.timestamp;
   }


    // function to remove a stake by an address
    function removeStake(uint256 _stake)
       public
   {
       stakes[msg.sender] = stakes[msg.sender].sub(_stake);
       if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
       _mint(msg.sender, _stake);
   }


   // mapping data type to keep track of accumulatedrewards for each stakeholder
   mapping(address => uint256) internal rewards;

   // function that allows a stakeholder to check his rewards
   function rewardOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return rewards[_stakeholder];
   }


   // function to get the aggregated rewards from all stakeholders 
   function totalRewards() public view returns(uint256) {
       uint256 _totalRewards = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
       }
       return _totalRewards;
   }


   // function to calculate the rewards for each stakeholder 
   function calculateReward(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder] / 100;
   }


   // function to distribute rewards to all stakeholders
   function distributeRewards()
       public
       onlyOwner
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           address stakeholder = stakeholders[s];
           uint256 reward = calculateReward(stakeholder);
           rewards[stakeholder] = rewards[stakeholder].add(reward);
       }
   }


    // function that allows a stakeholder to withdraw their reward
    function withdrawReward()
       public
   {
       // require that the time of stake is up to a week
       require(stakeTimes[msg.sender].add(604800)  >= block.timestamp, "you need to stake for a week"  );

       uint256 reward = rewards[msg.sender];
       rewards[msg.sender] = 0;
       _mint(msg.sender, reward);
   }


}

