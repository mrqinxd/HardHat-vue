 <template>
  <div id="Upload">
    <div class="Upload_box">
      <!-- 文件夹 -->
      <input
        class="Upload_box_input"
        ref="file"
        type="file"
        name="file"
        webkitdirectory
        @change.stop="changesData"
      />
      <!-- 按钮 -->
      <el-button size="medium" type="danger" @click="upIpfs"
        >上传至IPFS</el-button
      >
    </div>
    <p class="ipfsNum">
      <span
        >上传成功:
        <el-link :href="infs" target="_blank"
          >{{infs}}</el-link
        ></span
      >
    </p>
  </div>
</template>

<script>
//ipfs上传
import { Web3Storage } from "web3.storage/dist/bundle.esm.min.js";
export default {
  name: "Upload",
  // 模板引入
  components: {},
  // 数据
  data() {
    return {
      infs: "", //上传成功返回的hash
    };
  },
  // 方法
  methods: {
    changesData() {
      // change事件，监听上传的文件夹
      // console.log(this.$refs.file.files);
      this.fileList = this.$refs.file.files;
    },
    //上传至ipfs
    async upIpfs(fileList) {
      const client = new Web3Storage({
        token:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDE5N2VEYTQ5QjQyRmVjRjI2QzBhNWM4OThmNUYzNzVGNDU1Y2U2MWEiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NDU1ODEwMDQ4NjAsIm5hbWUiOiJkZXYyMjAyIn0.s9DZmDbB1VasuMmI50RzfFavxwIachm0XuELGz5RZY4",
      });
      // Pack files into a CAR and send to web3.storage
      const rootCid = await client.put(this.fileList, {
        name: "files",
        maxRetries: 3,
      });
      let url = `https://ipfs.io/ipfs/${rootCid}`;
      console.log(url);
      this.infs = url;
    },
  },
  // 创建后
  created() {},
  // 挂载后
  mounted() {},
  // 更新后
  updated() {},
};
</script>

<style lang="less" scoped>
.Upload_box {
  display: flex;
  border: 2px dashed #409eff;
  border-radius: 10px;
  padding: 1rem;
  width: 20rem;
  flex-direction: column;
  .el-button {
    width: 10rem;
    margin: 2rem 0 0;
  }
}
.ipfsNum {
  line-height: 3rem;
}
</style> 