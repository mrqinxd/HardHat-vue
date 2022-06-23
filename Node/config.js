// NFT MetaData 配置
const namePrefix = "MTW  aaaa";
const description = "MTW Token-G20";
const baseUri = "ipfs://bafybeiawifosciidjgwkoec3hpaxmftujuepqcgyloijmqwdjhs26f6xpu";
const compiler = "NFT Art Engine";
const MaxNFTLength = 15;

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