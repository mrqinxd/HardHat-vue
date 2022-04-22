const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MtgToken-test", function () {
  return;
  let Token;
  let hardhatToken;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addr4;
  let addr5;
  let addrs;

  beforeEach(async function () {
    // 临时地址
    [owner, addr1, addr2,addr3,addr4,addr5, ...addrs] = await ethers.getSigners();

    //代币对象
    Token = await ethers.getContractFactory("MtgToken");
    hardhatToken = await Token.deploy();
  });

  describe("Deployment", function () {
    // If the callback function is async, Mocha will `await` it.
    it("判定owner:", async function () {
      expect(await hardhatToken.owner()).to.equal(owner.address);
    });

    it("owner拥有所以代币", async function () {
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("授权", function () {  
    it("授权技术账号:", async function () {

      //owner账户才允许授权
      await hardhatToken.setTechnologyAddr(addr1.address);
      const TechnologyAddr1 = await hardhatToken.technologyAddr();
      expect(TechnologyAddr1).to.equal(addr1.address);

      //owner删除技术部账户
      await hardhatToken.delTechnologyAddr();
      const delTechnologyAddr = await hardhatToken.technologyAddr();
      expect(delTechnologyAddr).to.equal("0x0000000000000000000000000000000000000000");

      //非owner账户 不允许授权 报错
      // await hardhatToken.connect(addr1).setTechnologyAddr(addr2.address);
      // const TechnologyAddr2 = await hardhatToken.technologyAddr();
      // expect(TechnologyAddr2).to.not.equals(addr2.address);
    });

    it("改变用户状态", async function () {     

      //owner账户允许改变type
      await hardhatToken.setUserType(addr2.address,true);
      //所以取出来是true
      const type2 = await hardhatToken.getUserType(addr2.address);
      expect(type2).to.equals(true);

      //技术账户也允许改变type
      await hardhatToken.setTechnologyAddr(addr1.address);

      await hardhatToken.connect(addr1).setUserType(addr2.address,false);
      //所以取出来是true
      const type3 = await hardhatToken.getUserType(addr2.address);
      expect(type3).to.equals(false);

      //其他账户不能改变type  报错
      // await hardhatToken.connect(addr2).setUserType(addr2.address,true);
      // //所以取出来的结果 应该是false
      // const type1 = await hardhatToken.getUserType(addr2.address);
      // expect(type1).to.equals(false);
    });

    it("改变所有用户状态", async function () {
      //owner账户允许改变type
      await hardhatToken.changeAllUserType();
      //任何账户、、取出来是true
      const type = await hardhatToken.getUserType(addr4.address);
      expect(type).to.equals(true);

      //技术部账户也允许改变所有状态
      await hardhatToken.setTechnologyAddr(addr1.address);

      await hardhatToken.connect(addr1).changeAllUserType();
      //所以取出来是true
      const type3 = await hardhatToken.getUserType(addr4.address);
      expect(type3).to.equals(false);
    });
    
  });

  describe("Transactions", function () {
    it("owner转账addr1:", async function () {
      // owner 转账不受限制
      await hardhatToken.transfer(addr1.address, 666);
      const Balance1 = await hardhatToken.balanceOf(addr1.address);
      console.log('owner转账addr1',Balance1);
      expect(Balance1).to.equal(666);      

      //向address3转账|先授权给addr1 为技术权限
      await hardhatToken.setTechnologyAddr(addr1.address);

      await hardhatToken.connect(addr1).transfer(addr3.address, 500);      
      const Balance2 = await hardhatToken.balanceOf(addr3.address);
      console.log('addr1(技术)转账addr3',Balance2);
      expect(Balance2).to.equal(500);

      //向address2转账
      await hardhatToken.connect(addr3).transfer(addr2.address, 500);
      // 因为没开权限 所以不可成功 所以结果为0
      const Balance3 = await hardhatToken.balanceOf(addr2.address);
      console.log('addr3(普通)转账',Balance3);
      expect(Balance3).to.equal(0);
    });

  });

});
