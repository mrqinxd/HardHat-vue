# HardHat-vue

## 项目介绍

合约项目【集成框架】
提供：本地测试，合约编写，可视化界面调试

HardHat+vue控制一套流程框架。

`环境 Node 建议使用（CNPM）`

前端UI相关在 frontend 目录下
Node下 用于NFT自动生成MetaData Json

## HardHat(常用命令)
启动本地节点
```
npx hardhat node
```

使用Test目录下自建测试案例测试
```
npx hardhat test
```

根据xxxxxx.js来部署合约
```
npx hardhat run ./scripts/xxxxxx.js
```

根据xxxxxx.js来本地部署合约
```
npx hardhat run --network localhost ./scripts/xxxxxx.js
```

 ## HardHat(本地节点)
  * RPC URL：Localhost 8545
  * 链ID：31337
  * 货币符号：ETH
 
 ## HardHat(文档地址)
https://learnblockchain.cn/docs/hardhat/getting-started/