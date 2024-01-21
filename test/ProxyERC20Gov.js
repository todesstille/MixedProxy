const hre = require("hardhat");
const { expect } = require("chai");

describe("ProxyERC20Gov", function () {

  before(async () => {
    [admin, alice, bob] = await hre.ethers.getSigners();
  })

  beforeEach(async () => {

    const MockERC20Gov = await hre.ethers.getContractFactory("MockERC20Gov");
    const UpgradeableBeacon = await hre.ethers.getContractFactory("UpgradeableBeacon");
    const ProxyERC20Gov = await hre.ethers.getContractFactory("ProxyERC20Gov");

    logic = await MockERC20Gov.deploy();
    beacon = await UpgradeableBeacon.deploy(logic.address);
    proxy = await ProxyERC20Gov.deploy(beacon.address, "0x");
    
    govToken = await hre.ethers.getContractAt("MockERC20Gov", proxy.address);
    govTokenAdmin = await hre.ethers.getContractAt("IMixedProxy", proxy.address);
  });

  describe("Deployment", function () {
    it("Could deploy with beacon", async function () {
      expect(await govToken.itWorks()).to.equal(true);
    });

    it("Could initialize", async function () {
      await govToken.__ERC20Gov_init(admin.address, "1")
      expect(await govToken.govAddress()).to.equal(admin.address);
      expect(await govToken.version()).to.equal("1");
    });

    it("Cant initialize twice", async function () {
      await govToken.__ERC20Gov_init(admin.address, "1");
      await expect(govToken.__ERC20Gov_init(admin.address, "1"))
        .to.be.revertedWith("Initializable: contract is already initialized");
      
    });

    it("Proxy admin view functions", async function () {
      // Before initialization
      expect(await govTokenAdmin.admin()).to.equal(hre.ethers.constants.AddressZero);
      expect(await govTokenAdmin.implementation()).to.equal(logic.address);
      
      // Neet initialize to set admin
      await expect(govToken.__ERC20Gov_init(admin.address, "1"))
      expect(await govTokenAdmin.admin()).to.equal(admin.address);
    });
  });

  describe("Beacon Upgrade", function () {

    beforeEach(async () => {
      await expect(govToken.__ERC20Gov_init(admin.address, "1"));
      const MockERC20GovV2 = await hre.ethers.getContractFactory("MockERC20GovV2");
  
      logic2 = await MockERC20GovV2.deploy();
      govToken2 = await hre.ethers.getContractAt("MockERC20GovV2", proxy.address);
    });

    it("Not owner cant upgrade beacon", async function () {
      await expect(beacon.connect(alice).upgradeTo(logic2.address))
        .to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Could upgrade beacon", async function () {
      await expect(govToken2.itWorks2())
        .to.be.reverted;
      
      await beacon.upgradeTo(logic2.address);
      expect(await govToken2.itWorks2()).to.equal(true);
      expect(await govToken2.version()).to.equal("1");
    });

    it("Implementation address changes", async function () {
      expect(await govTokenAdmin.implementation()).to.equal(logic.address);
      await beacon.upgradeTo(logic2.address);
      expect(await govTokenAdmin.implementation()).to.equal(logic2.address);
    });

    it("Governer address not changes", async function () {
      expect(await govTokenAdmin.admin()).to.equal(admin.address);
      await beacon.upgradeTo(logic2.address);
      expect(await govTokenAdmin.admin()).to.equal(admin.address);
    });  
  });

});
