import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("SmartWallet", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const [owner, otherAccount, secondOtherAccount] = await ethers.getSigners();
    const Lock = await ethers.getContractFactory("SmartWallet");
    const smartWallet = Lock.deploy(
      // [], 0
      );
    return { smartWallet, owner, otherAccount, secondOtherAccount };
  }

  describe("Deployment", function () {
    // it("Should set the right unlockTime", async function () {
    //   const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

    //   expect(await lock.unlockTime()).to.equal(unlockTime);
    // });

    it("Should set the right owner", async function () {
      const { smartWallet, owner } = await loadFixture(deployOneYearLockFixture);

      expect(await smartWallet.owner()).to.equal(owner.address);
    });

  });

  describe("Transfer ownership", function () {
        it("Should transfer ownership", async function () {
          const { smartWallet, owner, otherAccount } = await loadFixture(deployOneYearLockFixture);
          // console.log("Initial accaunt: %s", owner.address);
          // console.log("Other accaunt: %s", otherAccount.address);
          await smartWallet.transferOwnership(otherAccount.address);
          // console.log(await smartWallet.owner());
          await expect(await smartWallet.owner()).to.equal(otherAccount.address);
        });
  });

  describe("Guardians", function () {
    async function deployAndSetGuardianFixture() {
      const { smartWallet, owner, otherAccount, secondOtherAccount } = await loadFixture(deployOneYearLockFixture);
      await smartWallet.setGuardians([otherAccount.address], 1);
      return { smartWallet, owner, otherAccount, secondOtherAccount };
    }

    it("Should set guardian", async function () {
      const { smartWallet, owner, otherAccount } = await loadFixture(deployAndSetGuardianFixture);
      const isGuardian = await smartWallet.testIsGuardian(otherAccount.address);
      await expect(isGuardian).to.equal(true);
    });

    it("Should erase guardians after transfering ownership", async function () {
      const { smartWallet, owner, otherAccount, secondOtherAccount } = await loadFixture(deployAndSetGuardianFixture);
      await smartWallet.transferOwnership(secondOtherAccount.address);
      const isGuardian = await smartWallet.testIsGuardian(otherAccount.address);
      await expect(isGuardian).to.equal(false);
      // console.log(await smartWallet.owner(), " ", secondOtherAccount.address);
    });
});
   

  //   it("Should receive and store the funds to lock", async function () {
  //     const { lock, lockedAmount } = await loadFixture(
  //       deployOneYearLockFixture
  //     );

  //     expect(await ethers.provider.getBalance(lock.address)).to.equal(
  //       lockedAmount
  //     );
  //   });

  //   it("Should fail if the unlockTime is not in the future", async function () {
  //     // We don't use the fixture here because we want a different deployment
  //     const latestTime = await time.latest();
  //     const Lock = await ethers.getContractFactory("Lock");
  //     await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
  //       "Unlock time should be in the future"
  //     );
  //   });
  // });

  // describe("Withdrawals", function () {
  //   describe("Validations", function () {
  //     it("Should revert with the right error if called too soon", async function () {
  //       const { lock } = await loadFixture(deployOneYearLockFixture);

  //       await expect(lock.withdraw()).to.be.revertedWith(
  //         "You can't withdraw yet"
  //       );
  //     });

  //     it("Should revert with the right error if called from another account", async function () {
  //       const { lock, unlockTime, otherAccount } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       // We can increase the time in Hardhat Network
  //       await time.increaseTo(unlockTime);

  //       // We use lock.connect() to send a transaction from another account
  //       await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
  //         "You aren't the owner"
  //       );
  //     });

  //     it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
  //       const { lock, unlockTime } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       // Transactions are sent using the first signer by default
  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw()).not.to.be.reverted;
  //     });
  //   });

  //   describe("Events", function () {
  //     it("Should emit an event on withdrawals", async function () {
  //       const { lock, unlockTime, lockedAmount } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw())
  //         .to.emit(lock, "Withdrawal")
  //         .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
  //     });
  //   });

  //   describe("Transfers", function () {
  //     it("Should transfer the funds to the owner", async function () {
  //       const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw()).to.changeEtherBalances(
  //         [owner, lock],
  //         [lockedAmount, -lockedAmount]
  //       );
  //     });
  //   });
  
});
