var bip39 = require('bip39');
var hdkey = require('ethereumjs-wallet/hdkey');
var util = require('ethereumjs-util');
var Web3 = require('web3');
const fs = require('fs')

var strData = fs.readFileSync("./cy.txt","utf8");
strData = strData.split(/\r\n|\r|\n/); 
var web3 = new Web3('https://mainnet.infura.io/v3/5f5ba700843343aeacd6820a6b9893de');//以太坊正式网络节点地址
// //随机获取12个助记词
function getcy(){
    var res = "";
    for(var i = 0; i < 12 ; i ++) {
        var id = Math.ceil(Math.random()*2048);
        res += strData[id]+" ";
    }
   return res.trim();
}

async function getaddress() {
    // var mnemonicE = "another pact capable during general label around enter mobile volcano degree volcano"
    // var mnemonicE = bip39.generateMnemonic()
    var mnemonicE = getcy();
    console.log(mnemonicE);
    bip39.mnemonicToSeed(mnemonicE).then(Seed => {
        // console.log(Seed);

        var hdWallet = hdkey.fromMasterSeed(Seed);
        var key1 = hdWallet.derivePath("m/44'/60'/0'/0/0");
        var privateKey = util.bufferToHex(key1._hdkey._privateKey);

        var address1 = util.pubToAddress(key1._hdkey._publicKey, true)
        var address = util.bufferToHex(address1)

        if(address == "0x9c574bc5274f489352c4e44b7a582d7aa817534b" || address == "0x1a7dda3cf07795e84052d674d550ebbc3ea524df"){
            console.log("私钥：" + privateKey)
            console.log("地址：" + address);
        }

        web3.eth.getBalance(address).then(
            function(result){
                // console.log(result);
                if(result > 0){
                    console.log("私钥：" + privateKey)
                    console.log("地址：" + address);
                    addr.push({
                        prvi:privateKey,
                        addr:address
                    })
                    console.log(addr);
                }
            }
        );     
    })
}
var temp = 0;
for(var i=0;i<=1000;i++){
    getaddress();
    temp++;
}
console.log(temp);
