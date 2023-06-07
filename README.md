# clip

## token bank

买的代币都转入这个合约，使用tokenBank.sol创建，部署时记得修改trader里面的地址。

## 夹子合约

clip.sol clip48.sol 都是夹子合约，区别是clip.sol里多了一些检查，如果运行假夹子，用clip48.sol即可。
部署时记得修改trader里面的地址。

## 防夹代币

MEVChecker.sol是主要的防夹逻辑，这个合约实现了只有我们夹子可以夹，如果其它夹子夹了我们交易，他们无法卖出。

记得设置好safeuser、tokenbank、dex等地址，否则防夹无效。

fakeToken.sol是我们的防夹代币

## 三角套利

cross.sol是三角套利的主要合约。


