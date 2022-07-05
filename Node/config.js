// NFT MetaData 配置
const namePrefix = "MTW  aaaa";
const description = "MTW Token-G20";
const baseUri = "ipfs://bafybeiek4v2qozcqkh72bu7nyc667asjdkxheupvtat6v32litfuz3gxxm";
const compiler = "NFT Art Engine";
const MaxNFTLength = 2;

//盲盒配置参数
const unpack = {
    namePrefix:"MTW",
    description:"MTW BindBox",
    baseUri:"ipfs://QmZK64zsqQq2kLsPujVUsQgxUk5xFUf9jxBFQJ6yP5TELN",
    jsonName:"unpack",
};

module.exports = {    
    baseUri,
    description,
    namePrefix,    
    compiler,
    MaxNFTLength,
    unpack
};