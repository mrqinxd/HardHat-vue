<template>
  <div id="Home">
    <!-- 面包屑 -->
    <div class="breadcrumb">
      <el-breadcrumb separator-class="el-icon-arrow-right">
        <el-breadcrumb-item :to="{ path: '/' }">Home</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div>
      
    </div>
    <div class="adminBox">
      <p v-if="time">当前时间：{{ time }}</p>
    </div>
  </div>
</template>

<script>
import {abiContract,ethers} from "../../contracts/abi.js";

export default {
  name: "Home",
  // 模板引入
  components: {},
  // 数据
  data() {
    return {
      time: "", //时间获取
    };
  },
  // 方法
  methods: {
    // 是指定时器
    setTime() {
      let _this = this;
      this.timer = setInterval(() => {
        _this.time = new Date().toLocaleString();
      }, 1000);
    },
    //清除定时器
    clearTime() {
      clearInterval(this.timer);
    },
  },
  // 创建后
  created() {
    this.setTime();
  },
  // 挂载后
  mounted() {},

  // 更新后
  updated() {},
  // 销毁
  beforeDestroy() {
    //页面关闭时清除定时器
    clearInterval(this.timer);
  },
};
</script>

<style lang="less" scoped>
#Home {
  .breadcrumb {
    margin: 1rem;
  }
  .adminBox {
    display: flex;
    line-height: 6rem;
    justify-content: space-between;
    :nth-child(1) {
      font-size: 1.4rem;
    }
  }
}
</style>
