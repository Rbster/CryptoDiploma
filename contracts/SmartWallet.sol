// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract SmartWallet {
    uint public unlockTime;
    address payable public owner;

    address[] guardians;
    mapping (address => bool) isGuardian;
    uint numGuardsReq;


    event GuardiansAssigned(address[] guardians, uint when);
    event GuardiansErased(uint when);
    event OwnershipChanged(address from, address to, uint when);

    constructor() payable {
        owner = payable(msg.sender);
        numGuardsReq = type(uint).max;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can do that");
        _;
    }

    modifier onlyGuardian() {
        require(isGuardian[msg.sender], "only guardian can do that");
        _;
    }

// Only owner
    function transferOwnership(address newOwner) external onlyOwner {
        eraseGuardians();
        address oldOwner = owner;
        owner = payable(newOwner);
        emit OwnershipChanged(oldOwner, owner, block.timestamp);
    }

    function setGuardians(address[] calldata newGuardians, uint newNumGuardsReq) external onlyOwner {
        require(newNumGuardsReq > 0, "numGuardsReq must be greater then 0");
        if (guardians.length != 0) {
            eraseGuardians();
        }
        numGuardsReq = newNumGuardsReq;
        setGuardians(newGuardians);
    }

    function eraseGuardians() internal onlyOwner {
        numGuardsReq = type(uint).max;
        for (uint i = 0; i < guardians.length; i++) {
            isGuardian[guardians[i]] = false;
        }
        delete guardians;
        emit GuardiansErased(block.timestamp);
    }

    function setGuardians(address[] calldata newGuardians) internal onlyOwner {
        for (uint i = 1; i <= newGuardians.length; i++) {
            guardians.push(newGuardians[newGuardians.length - i]);
            isGuardian[newGuardians[i]] = true;
        }
        emit GuardiansAssigned(newGuardians, block.timestamp);
    }

    // function withdraw() public {
    //     // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
    //     // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

    //     require(block.timestamp >= unlockTime, "You can't withdraw yet");
    //     require(msg.sender == owner, "You aren't the owner");

    //     emit Withdrawal(address(this).balance, block.timestamp);

    //     owner.transfer(address(this).balance);
    // }
}
