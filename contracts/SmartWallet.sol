// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// TODO: Delete
// import "hardhat/console.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract SmartWallet {
    address payable public owner;

    address[] guardians;
    mapping (address => bool) isGuardian;
    uint numGuardsReq;



    event GuardiansAssigned(address[] guardians, uint when);
    event GuardiansErased(uint when);
    event OwnershipChanged(address from, address to, uint when);

    constructor(
        address[] memory newGuardians, 
        uint newNumGuardsReq
        
    ) payable {
        if (newGuardians.length > 0 && newNumGuardsReq > 0 && newNumGuardsReq <= newGuardians.length) {
            for (uint i = 0; i < newGuardians.length; i++) {
                address guardian = newGuardians[i];
                require(guardian != address(0) && !isGuardian[guardian], "illigal list of guardians");
                isGuardian[guardian] = true;
                guardians.push(guardian);
                
            }
            numGuardsReq = newNumGuardsReq;
        }
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
        numGuardsReq = type(uint).max;
        eraseGuardians();
        // address oldOwner = owner;
        owner = payable(newOwner);
        // emit OwnershipChanged(oldOwner, owner, block.timestamp);
    }

    function setGuardians(address[] calldata newGuardians, uint newNumGuardsReq) external onlyOwner {
        require(newGuardians.length > 0, "numGuardsReq must be greater then 0");
        require(
            newNumGuardsReq > 0 && newNumGuardsReq <= newGuardians.length,
            "invalid number of required acceptions"
        );
        eraseGuardians();
        setGuardians(newGuardians);
        numGuardsReq = newNumGuardsReq;
    }

    function eraseGuardians() internal onlyOwner {
        if (guardians.length != 0) {
            for (uint i = 0; i < guardians.length; i++) {
                isGuardian[guardians[i]] = false;
            }
            delete guardians;
            // emit GuardiansErased(block.timestamp);
        }
    }

    function setGuardians(address[] calldata newGuardians) internal onlyOwner {
        for (uint i = 1; i <= newGuardians.length; i++) {
            address guardian = newGuardians[i - 1];
            require(guardian != address(0), "invalid guardian");
            require(!isGuardian[guardian], "guardian not unique");
            isGuardian[guardian] = true;
            guardians.push(guardian);
        }
    }

    function testIsGuardian(address someAddress) external view returns (bool) {
        return isGuardian[someAddress];
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
