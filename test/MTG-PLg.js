const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MtgToken-test", function () {
    let Token;
    let hardhatToken;
    let PlgToken;
    let owner;
    let addr1;
    let addr2;
    let addr3;
    let addr4;
    let addr5;
    let addrs;

    beforeEach(async function () {
        // 临时地址
        [owner, addr1, addr2, addr3, addr4, addr5, ...addrs] = await ethers.getSigners();

        //代币对象
        Token = await ethers.getContractFactory("CztToken");
        hardhatToken = await Token.deploy();

        //质押对象
        PlgTokenObj = await ethers.getContractFactory("PledgeEarn");
        PlgToken = await PlgTokenObj.deploy();

        await PlgToken.setTknAdr(hardhatToken.address);
        await hardhatToken.transfer(addr1.address,200);
    });

    describe("Deployment", function () {
        // If the callback function is async, Mocha will `await` it.
        it("判定owner:", async function () {
            expect(await hardhatToken.owner()).to.equal(owner.address);
        });
    });

    describe("测试", function () {       
        // If the callback function is async, Mocha will `await` it.
        it("授权:", async function () {
            await hardhatToken.connect(addr1).approve(PlgToken.address,200);

            let vale = await hardhatToken.allowance(addr1.address,PlgToken.address);
            expect(vale).to.equal(200);
        });

        it("授权+质押", async function () {
            await hardhatToken.connect(addr1).approve(PlgToken.address,200);
            await PlgToken.transTestMtgToken(addr1.address,200);

            expect(await hardhatToken.balanceOf(PlgToken.address)).to.equal(200);
        });

        it("授权+质押+取回", async function () {
            await hardhatToken.connect(addr1).approve(PlgToken.address,200);
            let plg = await PlgToken.transTestMtgToken(addr1.address,200);
            // console.log(hardhatToken.balanceOf(PlgToken.address));
            let qh = await PlgToken.transFormTestMtg(addr1.address,200);
            // console.log(hardhatToken.balanceOf(PlgToken.address));
            
            expect(await hardhatToken.balanceOf(addr1.address)).to.equal(200);
        });

    });

});
