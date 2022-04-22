 <template>
  <div id="Blindbox">
    <!-- 当前账户余额 -->
    <div class="blind_Box">
      <p>代币地址:{{abiConObj.CztTokenAddr}}</p>
      <p>质押合约地址:{{abiConObj.PledgeEarnAddr}}</p>
    </div>
    <div class="blind_Box">
      <p>用户余额:
        <span style="color: green">
            {{UserTokenBan}}
        </span>
      </p>
      <p>质押合约地址代币余额:
        <span style="color: green">
            {{PledTokenBan}}
        </span>
      </p>
    </div>

    <div class="blind_Box blind_Box_span">
      <span>质押代币总量:</span>
      <el-input placeholder="质押总数" v-model="PledgeEarnNum"> </el-input>
    </div>

    <!-- 存 -->
    <div class="blind_Box blind_Box_span" style="margin-left: 14rem;">
      <el-button type="primary" @click="approve" :disabled="isdisA">批准</el-button>
      <el-button type="primary" @click="pledge" :disabled="isdisP">质押</el-button>
    </div>

    <!-- 取 -->
    <div class="blind_Box blind_Box_span">
      <el-input placeholder="赎回金额" v-model="redemptionNum"></el-input>
      <el-button type="primary" @click="redemption">赎回</el-button>
    </div>

  </div>
</template>

<script>
import {abiContract,ethers} from "../../contracts/abi.js";
export default {
  name: "Blindbox",
  // 模板引入
  components: {},
  // 数据
  data() {
    return {
      abiConObj:{},
      isdisA:false,
      isdisP:true,
      UserTokenBan: "", //个人代币余额
      PledTokenBan: "", //质押代币余额
      PledgeEarnNum: "", //质押金额
      redemptionNum:""
    };
  },
  // 方法
  methods: {
    // 初始化
    async init() {
      this.abiConObj = await new abiContract();
      // 用户代币余额
      await this.abiConObj.CztTokenContract.balanceOf(this.abiConObj.UserAddr).then((res) => {
        this.UserTokenBan = ethers.utils.formatEther(res);
      });
      // 质押合约代币余额
      await this.abiConObj.CztTokenContract.balanceOf(this.abiConObj.PledgeEarnAddr).then((res) => {
        this.PledTokenBan = ethers.utils.formatEther(res);
      });
    },
    // 批准
    async approve() {      
      // 改变状态
      if(this.PledgeEarnNum <= 0){
        return;
      }
      const price = ethers.utils.parseUnits(
        this.PledgeEarnNum.toString(),
        "ether"
      );
      let transaction = await this.abiConObj.CztTokenContract.approve(this.abiConObj.PledgeEarnAddr,price);
      await transaction.wait().then((res) => {
        console.log(res);
        this.isdisA = true;
        this.isdisP = false;
        this.$message("批准成功 请点击质押");
      });
    },
    // 质押
    async pledge() {      
      const price = ethers.utils.parseUnits(
        this.PledgeEarnNum.toString(),
        "ether"
      );
      // 质押
      let transaction = await this.abiConObj.PledgeEarnContract.transTestMtgToken(this.abiConObj.UserAddr,price);
      await transaction.wait().then((res) => {
        console.log(res);
        this.$message("质押 成功");
        this.init();
        this.isdisA = false;
        this.isdisP = true;
      });
    },
    // 赎回
    async redemption() {      
      //  转换价格单位
      const price = ethers.utils.parseUnits(
        this.redemptionNum.toString(),
        "ether"
      );
      console.log(price);
      // 连接NFT合约，进行铸币
      let transaction = await this.abiConObj.PledgeEarnContract.transFormTestMtg(this.abiConObj.UserAddr,price);
      await transaction.wait().then((res) => {
        console.log(res);
        this.$message("赎回 成功");
        this.init();
      });
    },
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
    p{
      width: 40rem;
    }
    .el-input {
      width: 20rem;
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