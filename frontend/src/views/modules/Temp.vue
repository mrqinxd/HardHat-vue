 <template>
  <div id="Blindbox">
    <!-- 当前账户拥有盲盒个数 -->
    <div class="blind_Box">
      <span>盲盒单价:</span>
      <el-button @click="eventFilter">合约事件过滤器</el-button>
    </div>
  </div>
</template>

<script>
import axios from "axios";
// import { ethers } from "ethers";
import {abiContract,ethers} from "../../contracts/abi_temp.js";
export default {
  name: "Blindbox",
  // 模板引入
  components: {},
  // 数据
  data() {
    return {
      abiConObj:{},
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
    async init() {
      this.abiConObj = await new abiContract();
    },
    async eventFilter() {      
      //事件筛选器
      const transferEvents = await this.abiConObj.TempContract.queryFilter("Transfer", 0, "latest");
      let tokens = [];
      let owners = [];
      for (let i = 0; i < transferEvents.length; i++) {
          console.log(event);
          const event = transferEvents[i];          
          const tokenId = event.args.tokenId.toNumber();
          if (!tokens.includes(tokenId)) {
              tokens.push(tokenId);
          }
          owners[tokenId] = event.args.to;
      }

      // Order tokens by id
      tokens.sort((a, b) => a - b);

      // Write the results to a file
      let res = "";
      for (let i = 0; i < tokens.length; i++) {
          res += tokens[i] + " " + owners[tokens[i]] + "\n";
      }
      console.log(res);      
    }
  },
  // 创建后
  created() {
    this.init();
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