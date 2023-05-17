// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// TODO: Delete
// import "hardhat/console.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SmartWallet is ReentrancyGuard {
    address payable public owner;

    address[] guardians;
    mapping (address => bool) isGuardian;
    uint numGuardsReq;

    address ownerCRTarget;
    mapping (address => bool) acceptanceCR;

    
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
        _transferOwnership(newOwner);
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

    function eraseGuardians() private {
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

    function _transferOwnership(address newOwner) private {
        numGuardsReq = type(uint).max;
        eraseGuardians();
        // address oldOwner = owner;
        owner = payable(newOwner);
    }

// Only Guardians

    function submitOwnershipCR(address _to) external onlyGuardian {
        require(_to != address(0) && !isGuardian[_to], "owner can't be null or guardian");
        ownerCRTarget = _to;
    }

    function acceptOwnershipCR() external onlyGuardian {
        require(ownerCRTarget != address(0), "ownership change request must exist");
        acceptanceCR[msg.sender] = true;
    }

    function revokeAcceptionOwnershipCR() external onlyGuardian {
        require(ownerCRTarget != address(0), "ownership change request must exist");
        acceptanceCR[msg.sender] = false;
    }

    function revokeOwnershipCR() external onlyGuardian { 
        for (uint i = 0; i < guardians.length; i++) {
            acceptanceCR[guardians[i]] = false;
        }
        ownerCRTarget = address(0);
    }

    function executeOwnershipCR() external onlyGuardian {
        require(ownerCRTarget != address(0), "ownership change request must exist");
        uint numGuardsAccepted = 0;
        for (uint i = 0; i < guardians.length; i++) {
            if (acceptanceCR[guardians[i]] == true) {
                numGuardsAccepted++;
            }
        }
        require(numGuardsAccepted >= numGuardsReq, "ownership change request must exist");
        _transferOwnership(ownerCRTarget);
        ownerCRTarget = address(0);
    }


    function testIsGuardian(address someAddress) external view returns (bool) {
        return isGuardian[someAddress];
    }
        
// For ERC-20    
    function getBalance(IERC20 tokenAddress) public view returns(uint256) {
       return tokenAddress.balanceOf(address(this));
   }

   function getBalance() public view returns(uint256) {
       return address(this).balance;
   }
   
   function withdraw(IERC20 tokenAddress, uint256 amount) public nonReentrant {
        require(amount <= tokenAddress.balanceOf(address(this)), "Insufficient token balance");
        tokenAddress.transfer(msg.sender, amount);
    }

    function withdraw(uint256 amount) public payable onlyOwner nonReentrant {
        require(amount <= address(this).balance, "Insufficient token balance");

        (bool sent, ) = payable(msg.sender).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    // function withdraw() public {
    //     // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
    //     // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

    //     require(block.timestamp >= unlockTime, "You can't withdraw yet");
    //     require(msg.sender == owner, "You aren't the owner");

    //     emit Withdrawal(address(this).balance, block.timestamp);

    //     owner.transfer(address(this).balance);
    // }

// technical to recieve eth
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
