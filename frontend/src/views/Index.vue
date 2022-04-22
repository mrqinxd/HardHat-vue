<template>
  <el-container>
    <!-- 左侧 -->
    <el-aside width="200px">
      <h1>HardHat-UI</h1>
      <el-menu
        background-color="#001529"
        text-color="#FFFFFF"
        active-text-color="#1890FF"
        unique-opened
        router
        :default-active="$route.path"
      >
        <div v-for="obj in treelist" :key="obj.index">
          <!-- 可展开的菜单 -->
          <el-submenu v-if="obj.children" :index="obj.index">
            <template slot="title">
              <i :class="obj.i"></i>
              <span>{{ obj.text }}</span>
            </template>

            <!-- 展开的菜单：应该循环当前数据的obj.children数组 -->
            <el-menu-item
              v-for="child in obj.children"
              :key="child.index"
              :index="child.index"
              >{{ child.text }}</el-menu-item
            >
          </el-submenu>
          <!-- 无法展开直接点击的菜单儿子 -->
          <el-menu-item v-else :index="obj.index">
            <i :class="obj.i"></i>
            <span slot="title">{{ obj.text }}</span>
          </el-menu-item>
        </div>
      </el-menu>
    </el-aside>

    <!-- 右侧 -->
    <el-container>
      <!-- 右-头 -->
      <el-header>
        <h1>HardHat-UI</h1>
      </el-header>
      <!-- 右-身 -->
      <el-main>
        <el-card>
          <router-view></router-view>
        </el-card>
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
export default {
  data() {
    return {
      treelist: [
        { index: "/index/Home", i: "el-icon-star-off", text: "Home" },
        { index: "/index/Blindbox", i: "el-icon-goods", text: "盲盒" },
        { index: "/index/Pledge", i: "el-icon-goods", text: "质押" },
        { index: "/index/Upload",i: "el-icon-warning-outline",text: "ipfs上传" },
        { index: "/index/Temp",i: "el-icon-warning-outline",text: "测试" }
      ],
    };
  },
  methods: {},
};
</script>

<style lang="less" scoped>
.el-menu {
  border: 0;
}
.el-container {
  width: 100%;
  height: 100%;
  .el-aside {
    background-color: #002140;
    h1 {
      line-height: 4.3rem;
      color: #fff;
      text-align: center;
    }
  }
  .el-header {
    background-color: #001529;
    h1 {
      line-height: 4.3rem;
      color: #fff;
      text-align: center;
    }
  }
}
</style>
