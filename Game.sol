// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./RewardToken.sol";
import "./Consumable.sol";
import "./Swords.sol";

contract Game {

    Gold public gold;

    Swords public swords;

    Consumable public consumable;

    struct Warrior {
        uint maxHealth;
        uint health;
        uint attackPower;
        bool isRegistered;
        uint money;
        uint sleepingTime;
        uint swordID;
    }

    struct Monster {
        uint maxHealth;
        uint health;
        uint attackPower;
        uint reward;
    }

    struct Item {
        string name;
        uint ID;
        uint price;
        uint power;
    }

    constructor(address _consumableAddress, address _swordAddress) {
        consumable = Consumable(_consumableAddress);
        swords = Swords(_swordAddress);

        addItem("kucukcan", 0, 50, 50);
        addItem("ortacan", 1, 100, 150);
        addItem("buyukcan", 2, 200, 400);

        addMonster(100, 10, 100);
        addMonster(200, 20, 300);
        addMonster(400, 40, 900);
    }

    mapping(address => Warrior) public warriors;
    mapping(uint => Item) public idToItems;

    Monster[] public monsters;

    function startGame() public {
        require(warriors[msg.sender].isRegistered == false);
        Warrior memory warrior;
        warrior.maxHealth = 100;
        warrior.health = 100;
        warrior.attackPower = 20;
        warrior.isRegistered = true;
        warriors[msg.sender] = warrior;
    }

    function attack(uint _index) public mustBeAwake {
        uint8 swordPower = swords.viewSword(warriors[msg.sender].swordID).power;
        if( warriors[msg.sender].attackPower + swordPower >= monsters[_index].health ) {
            uint8 possibility = rand(10);
            warriors[msg.sender].health -= monsters[_index].attackPower;
            monsters[_index].health = monsters[_index].maxHealth;
            warriors[msg.sender].money += monsters[_index].reward;
            if( possibility <= 9 ) {
                swords.safeMint(msg.sender);
            }
        } else {
            warriors[msg.sender].health -= monsters[_index].attackPower;
            monsters[_index].health -= (warriors[msg.sender].attackPower + swordPower );
        }
    }

    function equipSword(uint _id) public {
        require( swords.ownerOf(_id) == msg.sender );
        warriors[msg.sender].swordID = _id;
    }

    function usePotion(uint _id) public mustBeAwake {
        consumable.burn(msg.sender, _id, 1);
        if( (warriors[msg.sender].health + idToItems[_id].power) >=  warriors[msg.sender].health ) {
            warriors[msg.sender].health = warriors[msg.sender].maxHealth;
        } else {
            warriors[msg.sender].health += idToItems[_id].power;
        }
    }

    function buyPotion(uint _id, uint _amount) public mustBeAwake {
        require(warriors[msg.sender].money >= idToItems[_id].price * _amount);
        warriors[msg.sender].money -= idToItems[_id].price * _amount;
        consumable.mint(msg.sender, _id, _amount,"");
    }

    function addItem(string memory _name, uint _id, uint _price, uint _power) private {
        Item memory item;
        item.name = _name;
        item.ID= _id;
        item.price = _price;
        item.power = _power;
        idToItems[_id] = item;
    }

    function sleep() public {
        require( block.timestamp >= warriors[msg.sender].sleepingTime + 10 );
        if( warriors[msg.sender].sleepingTime == 0 ) {
            warriors[msg.sender].sleepingTime = block.timestamp;
        } else {
            warriors[msg.sender].sleepingTime = 0;
            warriors[msg.sender].health = warriors[msg.sender].maxHealth;
        }
    }

    function upgradeSword(uint _id) public {
        require( swords.ownerOf(_id) == msg.sender);
        uint8 possibility = rand(9);
        if( possibility + 1 >= swords.viewSword(_id).plus ) {
            uint8 extraPower = rand(21);
            swords.setSwordMap(_id, swords.viewSword(_id).power += extraPower,swords.viewSword(_id).plus +1 );
        } else {
            warriors[msg.sender].swordID = 0;
            swords.burn(_id);
        }
    }

    function addMonster(uint _maxHealth, uint _attackPower, uint _reward) private {
        Monster memory monster;
        monster.maxHealth = _maxHealth;
        monster.health = _maxHealth;
        monster.attackPower = _attackPower;
        monster.reward = _reward;
        monsters.push(monster);
    }

    modifier mustBeAwake() {
        require( block.timestamp >= warriors[msg.sender].sleepingTime + 10 );
        _;
    }

    function rand(uint8 range) private view returns(uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)))) % range ;
    }





}
