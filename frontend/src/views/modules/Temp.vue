 <template>
  <div id="Blindbox">
    <!-- 当前账户拥有盲盒个数 -->
    <div class="blind_Box">
      <span>盲盒地址:{{ abiConObj.TempAddr }}</span>
      <el-button @click="eventFilter">合约事件过滤器</el-button>      
    </div>
    <div class="blind_Box"> 
      <el-table
        :data="FilterData"
        style="width: 100%">
        <el-table-column
          prop="tid"
          label="tokenID">
        </el-table-column>
        <el-table-column
          prop="addr"
          label="地址">
        </el-table-column>          
      </el-table>
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
      FilterData:[],
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
      for (let i = 0; i < tokens.length; i++) {
        let temp = {tid:0,addr:""};
        temp.tid = tokens[i];
        temp.addr = owners[tokens[i]];
        this.FilterData.push(temp);
      }
      console.log(this.FilterData);
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