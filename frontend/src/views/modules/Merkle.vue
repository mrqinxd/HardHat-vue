<template>
  <div id="Blindbox">
    <!-- 当前账户拥有盲盒个数 -->
     <div class="blind_Box"> 
      <span>测试钱包地址</span>      
    </div>
    <div class="blind_Box" style="display:block">
      <div v-for="obj in whitelistAddresses">
        {{obj}}
      </div>
    </div>
    <div class="blind_Box">
      <span>白名单采用：merklePoof</span>
      <el-button class="el-button el-button--primary" @click="merkleTree">生成merkle-hash-root</el-button>
      <span>Root : {{hashRoot}}</span>
    </div>
    <div class="blind_Box" style="display:block"> 
      <el-input placeholder="" v-model="addr"> </el-input>
      <el-button class="el-button el-button--primary" @click="getAddr">获取单个地址证明</el-button>      
      <div style="display:block">
      <span>Root : {{addrHash}}</span>
      </div>      
    </div>
  </div>
</template>

<script>
import { keccak256 } from "@ethersproject/keccak256";
import merkletreejs from "merkletreejs";

export default {
  name: "Merkle",
  // 模板引入
  components: {},
  // 数据
  data() {
    return {
      time: "", //时间获取
      whitelistAddresses:[
        '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4',
        '0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2',
        '0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db',
        '0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB',
        '0x617F2E2fD72FD9D5503197092aC168c91465E7f2',
      ],
      tree:{},
      hashRoot:"",
      addr:'',
      addrHash:[],
    };
  },
  // 方法
  methods: {
    creaRoot(){
      let leafNodes = this.whitelistAddresses.map(address => keccak256(address));
      this.tree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
      console.log(this.tree);
    },
    //merklePoof
    merkleTree(){
      let tree = this.tree;      
      console.log('Tree: ', tree.toString());
      console.log('root: ',tree.getRoot().toString('hex'));
      this.hashRoot = tree.getRoot().toString('hex');
     
    },
    getAddr(){
      if(this.addr == "") return;
      let leaf = keccak256(this.addr);
      this.addrHash = this.tree.getHexProof(leaf);
      console.log('Proof of '+this.addr+': ',  this.addrHash );
    }

  },
  // 创建后
  created() {
    this.creaRoot();
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
      width: 30rem;
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
