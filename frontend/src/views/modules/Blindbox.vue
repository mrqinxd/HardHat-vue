 <template>
  <div id="Blindbox">
    <!-- 当前账户拥有盲盒个数 -->
    <div class="blind_Box">
      <span>盲盒单价:</span>
      <el-input placeholder="个数" v-model="money" :disabled="true"> </el-input>
      <span>单次铸造最多个数:</span>
      <el-input placeholder="个数" v-model="maxMintNum" :disabled="true">
      </el-input>
      <span>当前账户最多拥有盲盒个数:</span>
      <el-input placeholder="个数" v-model="accountNum" :disabled="true">
      </el-input>
      <span>池子盲盒总量:</span>
      <el-input placeholder="个数" v-model="blindNum" :disabled="true">
      </el-input>
      <span>剩余盲盒总量:</span>
      <el-input placeholder="个数" v-model="remainBlindNum" :disabled="true">
      </el-input>
    </div>
    <!-- 开启盲盒 -->
    <div class="blind_Box">
      <span> 注意:更换操作只有智能合约拥有者有权限,否则会失败！！！</span>
    </div>
    <!-- 开启盲盒 -->
    <div class="blind_Box blind_Box_span">
      <span>当前盲盒状态:</span>
      <el-input placeholder="" v-model="state" :disabled="true"> </el-input>
      <el-button type="primary" @click="onState">更换状态</el-button>
    </div>
    <!-- 设置单价 -->
    <div class="blind_Box blind_Box_span">
      <span>设置单价:</span>
      <el-input placeholder="" v-model="changemoney"> </el-input>
      <el-button type="primary" @click="onchangemoney">更换价格</el-button>
    </div>
    <!-- 设置单次铸造个数 -->
    <div class="blind_Box blind_Box_span">
      <span>设置单次铸造个数:</span>
      <el-input placeholder="" v-model="changemaxMintNum"> </el-input>
      <el-button type="primary" @click="onchangemaxMintNum">更换个数</el-button>
    </div>
    <!-- 设置账户最多拥有个数 -->
    <div class="blind_Box blind_Box_span">
      <span>设置账户最多拥有个数:</span>
      <el-input placeholder="" v-model="changeaccountNum"> </el-input>
      <el-button type="primary" @click="onchangeaccountNum">更换个数</el-button>
    </div>
    <!-- mint -->
    <div class="blind_Box">
      <span>价格:</span>
      <el-input placeholder="单价" v-model="money" :disabled="true"> </el-input>
      <span>个数:</span>
      <el-input placeholder="个数" v-model="mintNum"> </el-input>
      <el-button type="primary" @click="onMint">Mint</el-button>
      <el-button type="primary" @click="goOpenSea">OpenSea</el-button>
    </div>
    <!-- img展示 -->
    <div class="imgBox" v-if="this.ipfsurl">
      <p>盲盒图片:</p>
      <el-image :src="ipfsurl"></el-image>
    </div>
  </div>
</template>

<script>
import axios from "axios";
// import { ethers } from "ethers";
import {abiContract,ethers} from "../../contracts/abi.js";
export default {
  name: "Blindbox",
  // 模板引入
  components: {},
  // 数据
  data() {
    return {
      state: "", //盲盒状态
      maxMintNum: "", //单次最多个数
      accountNum: "", //账户最多拥有个数
      blindNum: "", //盲盒总量
      remainBlindNum: "", //剩余盲盒数量
      money: "", //价格
      mintNum: "", //数量
      ipfsurl: "", //ipfs地址
      changemoney: "", //更换价格
      changemaxMintNum: "", //更换单次最多个数
      changeaccountNum: "", //更换账户最多拥有个数
    };
  },
  // 方法
  methods: {
    // 获取盲盒详情
    async blindboxnum() {
      let contract = await new abiContract();
      // 获取当前是否开启盲盒的状态
      await contract.tokenContract._revealed().then((res) => {
        console.log(res);
        if (res == false) {
          this.state = "未开启";
        } else if (res == true) {
          this.state = "已开启";
        } else {
          this.state = "错误";
        }
      });
      // 单次购买个数
      await contract.tokenContract.maxMint().then((res) => {
        console.log(res);
        this.maxMintNum = res.toNumber();
      });
      // 单账户最大拥有
      await contract.tokenContract.maxBalance().then((res) => {
        console.log(res);
        this.accountNum = res.toNumber();
      });
      // 盲盒总量
      await contract.tokenContract.MAX_SUPPLY().then((res) => {
        console.log(res);
        this.blindNum = res.toNumber();
      });
      // 剩余盲盒数
      await contract.tokenContract.remainNum().then((res) => {
        console.log(res);
        this.remainBlindNum = res.toNumber();
      });
      // 盲盒单价
      await contract.tokenContract.mintPrice().then((res) => {        
        this.money = ethers.utils.formatUnits(res.toString(), "ether");
      });
      // 盲盒ipfs地址
      await contract.tokenContract.notRevealedUri().then(async (res) => {
        console.log(res);
        let url = `https://ipfs.io/ipfs/${res.substring(
          res.lastIndexOf("://") + 3
        )}`;
        // console.log(url);
        const meta = await axios.get(url);
        // console.log(meta);
        let m = meta.data.image;
        // console.log(m);
        this.ipfsurl = `https://ipfs.io/ipfs/${m.substring(
          m.lastIndexOf("://") + 3
        )}`;
        // console.log(this.ipfsurl);
      });
      // tokenURI
         await contract.tokenContract.tokenURI(1).then((res) => {
        console.log(res);
      });
    },
    // 改变盲盒状态
    async onState() {
      let contract = await new abiContract();
      // 改变状态
      let transaction = await contract.nftContract.flipReveal();
      await transaction.wait().then((res) => {
        console.log(res);
        this.blindboxnum();
        this.$message("改变盲盒成功");
      });
    },
    //mint
    async onMint() {
      let contract = await new abiContract();
      //  转换价格单位
      const price = ethers.utils.parseUnits(
        (this.money * this.mintNum).toString(),
        "ether"
      );
      console.log(price);
      // 连接NFT合约，进行铸币
      let transaction = await contract.nftContract.mintNicMeta(this.mintNum, {
        value: price,
      });
      console.log(transaction);
      await transaction.wait().then((res) => {
        console.log(res);
        this.$message("mint 成功");
      });
    },
    // 更换价格
    async onchangemoney() {
      if (this.changemoney > 0) {
        let contract = await new abiContract();
        const price1 = ethers.utils.parseUnits(
          this.changemoney.toString(),
          "ether"
        );
        let transaction = await contract.nftContract.setMintPrice(price1);
        await transaction.wait().then((res) => {
          console.log(res);
          this.blindboxnum();
          this.$message("改变单价成功");
        });
      } else {
        this.$message("请设置正确价格");
      }
    },
    // 更换单次最多mint个数
    async onchangemaxMintNum() {
      if (this.changemaxMintNum > 0) {
        let contract = await new abiContract();
        let transaction = await contract.nftContract.setMaxMint(
          this.changemaxMintNum
        );
        await transaction.wait().then((res) => {
          console.log(res);
          this.blindboxnum();
          this.$message("改变单次mint最多个数成功");
        });
      } else {
        this.$message("请设置正确个数");
      }
    },

    // 更换单个账户最多拥有个数
    async onchangeaccountNum() {
      if (this.changeaccountNum > 0) {
        let contract = await new abiContract();
        let transaction = await contract.nftContract.setMaxMint(
          this.changeaccountNum
        );
        await transaction.wait().then((res) => {
          console.log(res);
          this.blindboxnum();
          this.$message("改变单个账户最多拥有个数成功");
        });
      } else {
        this.$message("请设置正确个数");
      }
    },
    // 跳转
    goOpenSea() {
      window.open("https://testnets.opensea.io/collection/bbq-meta", "_blank");
    },
  },
  // 创建后
  created() {
    this.blindboxnum();
  },
  // 挂载后
  mounted() {},
  // 更新后
  updated() {},
};
</script>

<style lang="less" scoped>
#Blindbox {
  .blind_Box {
    display: flex;
    line-height: 3rem;
    margin: 1rem 0;
    :nth-child(n) {
      margin: 0 0.5rem;
    }
    .el-input {
      width: 6rem;
    }
  }
  .blind_Box_span {
    span {
      width: 12rem;
    }
  }
  .imgBox {
    .el-image {
      width: 20rem;
      height: 20rem;
      // border: 5px solid red;
      border-radius: 10%;
      background-color: #d9ecff;
      margin: 1rem;
    }
  }
}
</style> 