import { ethers } from "ethers";
import Web3Modal from "web3modal";
import address from "./contract-address.json"; // address

//不同合约 不同json
import CztToken from "./CztToken.json";
import PledgeEarn from "./PledgeEarn.json";
import MTW from "./MTW.json";


export async function abiContract() {
  //连接钱包，获取签名
  const web3Modal = new Web3Modal({
    network: "mainnet",
    cacheProvider: true,
  });
  const connection = await web3Modal.connect();  
  const provider = new ethers.providers.Web3Provider(connection);
  const signer = provider.getSigner();
  return {
    UserAddr:connection.selectedAddress,
    CztTokenAddr:address.CztToken,
    PledgeEarnAddr:address.PledgeEarn,
    MTWTokenAddr:address.MTWToken,
    CztTokenContract: new ethers.Contract(address.CztToken, CztToken.abi, signer),
    PledgeEarnContract: new ethers.Contract(address.PledgeEarn, PledgeEarn.abi, signer),
    MTWContract: new ethers.Contract(address.MTWToken, MTW.abi, signer),
  }
}

export {ethers};