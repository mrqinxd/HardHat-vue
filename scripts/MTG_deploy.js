// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

  let metaMaskAddr = "0xFD718B0d0322D484B8a5a78D88296db29996055f";

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  const CztToken = await hre.ethers.getContractFactory("CztToken");
  const cztToken = await CztToken.deploy();
  await cztToken.deployed();
  console.log("Greeter deployed to:", cztToken.address);
  
  //部署完成后 转移权限到metamask上|同时转代币
  await cztToken.transferOwnership(metaMaskAddr);
  console.log("cztToken owner:", (await cztToken.owner()));
  
  await cztToken.transfer(metaMaskAddr, ethers.utils.parseUnits("666","18"));
  console.log("cztToken balance:", (await cztToken.balanceOf(metaMaskAddr)));

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles('CztToken', cztToken.address);

  const PledgeEarn = await hre.ethers.getContractFactory("PledgeEarn");
  const pledgeEarn = await PledgeEarn.deploy();
  await pledgeEarn.deployed();
  console.log("Greeter deployed to:", pledgeEarn.address);
  //部署完成后 设置cztToken代币地址
  await pledgeEarn.setTknAdr(cztToken.address);

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles('PledgeEarn', pledgeEarn.address);

}

function saveFrontendFiles(name, tokenAddr) {
  const fs = require("fs");
  const contractsDir = __dirname + "/../frontend/src/contracts";

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  let data = fs.readFileSync(contractsDir + "/contract-address.json");
  let addressObj = JSON.parse(data);
  addressObj[name] = tokenAddr;

  fs.writeFileSync(
    contractsDir + "/contract-address.json",
    JSON.stringify(addressObj, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync(name);

  fs.writeFileSync(
    contractsDir + "/" + name + ".json",
    JSON.stringify(TokenArtifact, null, 2)
  );
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
