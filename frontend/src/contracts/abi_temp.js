import { ethers } from "ethers";
import Web3Modal from "web3modal";
import address from "./contract-address.json"; // address

//不同合约 不同json
import Temp from "./mh.json";

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
    TempAddr:address.Temp,
    TempContract: new ethers.Contract(address.Temp, Temp.abi, provider),    
  }
}

export {ethers};