# clip

trader Contract Address: 0x000000000002573962CFce0145E137E1e827d376 (buy and sell)

token bank: 0xd84bb4523573eec28f0df1c5ecf7ed4d650af31c

trader cross: 0x83fA4E9f7914336b810ACC082BD007ec73a91d6D

token bank: 0x0A83f62407d74228E0E106f009638750Fb555DE0

test honey: 0x78A78E931421a16893e879D4660a074A3D926daA

test token fee: 0x231dB44485b11ee14CfDeC3b207dC5114a049D6a

test buyer: 0xA7f4Bd3A2bFBf9Db4dE6E5A0dCE4720be4F2bDD2

factory: 0x00000000002882B2B808CeEA1D33C90a275eaA8e

Salt: 0x9e2c7bd948053fb4c94baf814ab68a84ade175c2b567d0436265e8d75d4bf3db

# Fake clip2023

trader Contract Address: 0x75512dad7C1AFf92267170e1B19F2ABb6157fBBE

trader account:

0xbe93E335B694c6Fdcb39167E5c67335f7b80039e

0xa79131662ADcCA5b09aB927eF690a2C4deE23dC5

0x6c3B7F6F177fFb38c06685A393f5f9128ECC0e99

# API

https://api.infstones.com/bsc/mainnet/994a9feb02fa4fba969063012db2f51d

wss://api.infstones.com/ws/bsc/mainnet/994a9feb02fa4fba969063012db2f51d

# 假帐户

0xcdCb34374661da619629BE3D8A7b942f022356a3

0xeb1FF93aa8CB9cee408b8eacA1439465A84422E2

0x8C4a5E540b3d6D4A56B7eEb169821995A433F673

0x20F1fEe0ac3785FD5754efDDb0610893Ff047AAE

0xA7E0D6616FCC702B5879Df9BdcC6d84a02eE7983

0x55e0ECE78d964918531CA3b7cbf33b3C56A59F7D

0xCf11DC3d0731c45D57395289e187143f7C30c793

0x62217A40d395E9BA0F06304a023DC712c1a111eA

0x806c7Ca602272aa0c8c6476B9C313Ed291152fE7

0xab1c3FF36724B3F6c8ec13411290DDD3D5bDd58A

# MEV minner

https://bscscan.com/address/0x5cc05fde1d231a840061c1a2d7e913cedc8eabaf#readContract

0x72b61c6014342d914470ec7ac2975be345796c2b (Validator: BNB48 Club) 

0xb218c5d6af1f979ac42bc68d98a5a0d796c6ab01 (Validator: Alan Turing)

0xa6f79b60359f141df90a0c745125b131caaffd12 (Validator: Avengers)

0x0bac492386862ad3df4b666bc096b0505bb694da (Validator: Claude Shannon)

0xd1d6bf74282782b0b3eb1413c901d6ecf02e8e28

0x9bb832254baf4e8b4cc26bd2b52b31389b56e98b (Validator: Stake2me)

-----------------
0x9F8cCdaFCc39F3c7D6EBf637c9151673CBc36b88 (Validator: Ankr )

# Router

0x10ED43C718714eb63d5aA57B78B54704E256024E

# CHECKER

checker1: 0x625f5077d3B5a16dFe66A0576447267d6D36DfA7
checker2: 0x626468742c4978fE1d4Bf92f19feeE950CcD3f6D
checker3: 0xCeEcf581Ce79721f3C2eA99a2b1B5A293D3d12Cd

# 假数据

token: 0xb49CC9BB6C46F047b44c36348a1095e893157340

checker: 0xa27B22a282e5F61E6Ed6aa767cC5184f3e4Ee5c5

pool: 0x670505a2f7ed545f6b9BA3DAFa2B8A8751BdAD1B

--------------------------------------------------------

token: 0x4f5140b8d9258483cDCb4fC322d414cf5bf5e6CE

checker: 0xa27B22a282e5F61E6Ed6aa767cC5184f3e4Ee5c5

pool: 0xa2F6AF5aAa6867F9e6b653F63D115bF917b8f738

-------------------------------------------------------

token: 0x9EFCb478f96EB3C883AE5541f0Fdbe77a81590B0
pool: 0xD6f326654ae8d7F51E9e6E02d462f0491C713169

------------------------------------------------------

token: 0x7D19c422356BF2c7f96235866FE0F40c9e3eF8ab

pool: 0x147b014CF0df54CD09777F6824b5Ef0306A55EE9

------------------------------------------------

token: 0xB65301D6f4D9F8Dd4695a8C64F2E92aA9479E222

pool: 0x0123B967B387DB08CBAd4915672841cD73C49dA7

-----------------------------------------------
current:

token: 0xc6687913c9A75F8CdCD18fCA520e23298cA3adbB

pool: 0xa967b724C814daDe636DB88c336539F4ae375298


--------------------------------------------------
可疑交易：
https://bscscan.com/tx/0xed0f900b92d93f061360abb178e756aeff4a7c6e80ddf49765e60a7fb3ded868

## 三角套利流程

1. 判断是否有套利空间 （TODO：BNB的套利比较时应加上价格）
2. 判断第一个pair是否是BerkeleySwap MarsSwap，如果是调用plainCross，如果不是则调用zeroCross
3. TODO：如何判断有没有竞争者，进行竞价

## 调用流程

1. 随机生成96位的随机数跟160位pair address放在一起组成256位的requestId
2. 选择seller的账户，比如账户 A
2. 账户A 调用Seller的trySellToken方法卖出
3. 账户B 调用Buyer的tryBuyToken买入（较高gas price）

传入的参数有加密，加解密方法见合约代码

如果买入成功，但是卖出不成功，记录下该requestId，使用该requestId进行重卖（使用固定账户）。

coinbase地址列表：
```python
coinbases = [
    0xe9ae3261a475a27bb1028f140bc2a7c843318afd,
    0xea0a6e3c511bbd10f4519ece37dc24887e11b55d,
    0xee226379db83cffc681495730c11fdde79ba4c0c,
    0xef0274e31810c9df02f98fafde0f841f4e66a1cd,
    0x2465176c461afb316ebc773c61faee85a6515daa,
    0x295e26495cef6f69dfa69911d9d8e4f3bbadb89b,
    0x2b3a6c089311b478bf629c29d790a7a6db3fc1b9,
    0x2d4c407bbe49438ed859fe965b140dcf1aab71a9,
    0x3f349bbafec1551819b8be1efea2fc46ca749aa1,
    0x685b1ded8013785d6623cc18d214320b6bb64759,
    0x70f657164e5b75689b64b7fd1fa275f334f28e18,
    0x72b61c6014342d914470ec7ac2975be345796c2b,
    0x7ae2f5b9e386cd1b50a4550696d957cb4900f03a,
    0x8b6c8fd93d6f4cea42bbb345dbc6f0dfdb5bec73,
    0x9f8ccdafcc39f3c7d6ebf637c9151673cbc36b88,
    0xa6f79b60359f141df90a0c745125b131caaffd12,
    0xaacf6a8119f7e11623b5a43da638e91f669a130f,
    0xac0e15a038eedfc68ba3c35c73fed5be4a07afb5,
    0xbe807dddb074639cd9fa61b47676c064fc50d62c,
    0xce2fd7544e0b2cc94692d4a704debef7bcb61328,
    0xe2d3a739effcd3a99387d015e260eefac72ebea1,
]

coinbase = coinbases[blocknumber % 21]
```

0x72ab2ea73527d18b84185e00a0a0d89b7edb589eff9bffbfa17b134abaf95253
0x62891d007fb991a7e95af8198bb410b40ca91597a745e7204560db5cf2b2466a
0x62891d007fb991a7e95af819037dafea3fe7300661ecb8baf11deb2b071a558d
0x62891d007fb991a7e95af819037dafea3fe7300661edb680117e91e4bd23dc0c
0x62891d007fb991a7e95af819e9d3024ccdc97ea38c7a9134b6b57ae981b1bb6c
0x62891d007fb991a7e95af8196ac6e26479f2d30b7dcfb1448ca51613646f1bab
0X62891d007fb991a7e95af819037dafea3fe7300661ed813dbb01a0a9367cf857

0x08cafbbf4ab9c4a9dce600850b74ecf6d11ebee845a67a89a3d7385e7634b8bd
0x18e8c81800278485b1a4a69c53a46beedbd6fccab084cc38ed47da09e6dbd183
0x18e8c81800278485b1a4a69ca8a99b879022d670dbd471773b2bd191d8c5aedc
0x18e8c81800278485b1a4a69ca8a99b879022d670dbd02aff3965d4cca1e65a5d
0x18e8c81800278485b1a4a69c67b847ba9713122d8ce9564a444d67945069d52a
0x18e8c81800278485b1a4a69c51e9a180b93701a094e297892c1bbb6c3637016b
0x18e8c81800278485b1a4a69ca8a99b879022d670dbd007ebcbf1634df6d912b9

c1c9336cddd4e26cb666efeb25616de70443b6c58ab8a557613d8fd4dc041a5c
18e8c81800278485b1a4a69ca8a99b879022d670dbd004c3a5ca73ab2c5912b9
000000000000000000000000601cca38fc510dfbd926468d18d0db1dbb49cb64
00000000000000000000000000000000000000000000000028f1300b0427c103
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000080
0000000000000000000000000000000000000000000000000000000000000060
000000000000000000000000000000000000000000000000a29c72d8f8d2c323
000000000000000026f70001924e99929e6352c12e0437fe3a21eec4539e6390
000000000000000026f70001ab6da9b60e009dc6df71c63a2ae8cb42441763d1
000000000000013e701f00000000630cdc280000000000000000000000000000
000157bb8e92049cd3dcef94c129c27b3e848fe13d19

2022/06/26 05:59:30 log: hash  0x9281383350eea8a46416e96c9191f2e1c8bf8b233f2bfb340eb9a6a4b34956f0
2022/06/26 05:59:30 hash:  0x9281383350eea8a46416e96c9191f2e1c8bf8b233f2bfb340eb9a6a4b34956f0 amountIn:  9927142447418244389049 amountOut 23376105387416363857843606 log: decide buy&sell, gasPrice is  7891320000  minClipIn:  2990712195460850918979779 maxReserveIn:  2998130408798373648113848 path:  0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 path:  0x12BB890508c125661E03b09EC06E404bc9289040
2022/06/26 05:59:30 log: sendSellToProviders sent sell, 0x844ac2049c45447ab8aa3d169f201ee8045127c81b76584e6f0eee74cff9d66c  to  quicknode-private rpc
2022/06/26 05:59:30 log: sendSellToProviders sent sell, 0x844ac2049c45447ab8aa3d169f201ee8045127c81b76584e6f0eee74cff9d66c  to  localhost ipc
2022/06/26 05:59:30 log: sendSellToProviders sent sell, 0x844ac2049c45447ab8aa3d169f201ee8045127c81b76584e6f0eee74cff9d66c  to  ankr-private rpc
2022/06/26 05:59:30 log: sendSellToProviders sent sell, 0x844ac2049c45447ab8aa3d169f201ee8045127c81b76584e6f0eee74cff9d66c  to  ankr-public rpc
2022/06/26 05:59:30 log: generate random uint256:  107961163917920907597258798558227871050512814702843613692935445171763786262291
2022/06/26 05:59:31 set id hash:  0xcbd72f6d05db98882e0baffc76422f7b58dd660696d1c09c42f83adb639eb478 operating account:  0xEaAeadA6F22e4EA5ed9710C111d322566125433B
2022/06/26 05:59:31 buy hash:  0x0223df8b285555f9dd7bac34619a3a6c64d1b6b9bb7ea587a982ad161a33f64d operating account:  0x46e3702Fe8a5c5532e368D768418b3cacF1623eE
2022/06/26 05:59:31 sell hash:  0x844ac2049c45447ab8aa3d169f201ee8045127c81b76584e6f0eee74cff9d66c operating account:  0x859d2D5Cf3E02C667702B9098C389dB26559A671


curl  https://bold-floral-water.bsc.quiknode.pro/ed9a3a06f0786f8a0feed6cfbad56dd49d577698/ -X POST -H "Content-Type: application/json" --data '{"method":"debug_traceCall","params":[{"from":null "to":"0x9d33e4DaA217D0b8e0c4CB139C74F6e5994BC6b6","data":"0x975057e7"}, "latest"],"id":1,"jsonrpc":"2.0"}'

curl  https://bold-floral-water.bsc.quiknode.pro/ed9a3a06f0786f8a0feed6cfbad56dd49d577698/ \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{"method":"debug_traceCall","params":[{"from":null,"to":"0x9d33e4DaA217D0b8e0c4CB139C74F6e5994BC6b6","data":"0x975057e7"}, "pending"],"id":1,"jsonrpc":"2.0"}'


  bsc/build/bin/geth --config ./config.toml --datadir /data/bsc/ --datadir.ancient /root/chaindata/ancient --pipecommit --cache 65536 -http --http.api=eth,debug,net,web3,txpool --rpc.allow-unprotected-txs --txlookuplimit 0 --networkid 56 --datadir.minfreedisk 4096 --ws --ws.origins all

  bsc/build/bin/geth --config ./config.toml --datadir node --pipecommit --cache 65536 -http --http.api=eth,debug,net,web3,txpool --rpc.allow-unprotected-txs --txlookuplimit 0 --networkid 56 --datadir.minfreedisk 4096 --txpool.locals '0x6994Cb5F2baF25BFE8Ca2E49fD1Cec5D8559a16c, 0x46e3702Fe8a5c5532e368D768418b3cacF1623eE, 0x0c9Fc86153c0219BD9EA432A05A20F280a3a7c8f, 0x0CA7C62D2b0abF4B64f04686d0E7cF52Da9a9D11, 0x859d2D5Cf3E02C667702B9098C389dB26559A671,0xEaAeadA6F22e4EA5ed9710C111d322566125433B, 0xCb0b64205c3A03a6D19895862f00706d16f11fF4, 0x78385cbCF1c3143Eb206f5Dd084D30697d85b9b7, 0x43f8FE4F62C9bD35665baB792bb7f8e1A8546f3d,0xCf11DC3d0731c45D57395289e187143f7C30c793' --ws --ws.origins all


bsc/build/bin/geth --config ./config.toml --datadir /data/bsc/ --pipecommit --cache 65536 -http --http.api=eth,debug,net,web3,txpool --rpc.allow-unprotected-txs --txlookuplimit 0 --networkid 56 --datadir.minfreedisk 4096 --ws --ws.origins all



root@sing:~/frontrun# ./frontrun cross --database ./pairs.db --account 0x6c3B7F6F177fFb38c06685A393f5f9128ECC0e99 --amount 97232133 --pairs 0xec3cd47382A95aD30E0C618a926Cf51D20f16B84,0x6d2Cc2E3882379CCDcca52CfaD5069217fC1F49B,0x4d5e9dc1f268DA07beBa6F1B071cEd8AE7Dfd064,0x304d7FE6227E8D2544C9271fe76d57A38a8882Ef,0x1021079E1639d1A47AEfB3C16293Ecf884008eF5 --outid 1,1,0,1,0
[+] found  5 in database.
[+] pair:  0xec3cd47382A95aD30E0C618a926Cf51D20f16B84 fee:  35 isBakery:  ZooSwap outId:  1 token0:  0x55d398326f99059fF775485246999027B3197955 token1:  0x67Fa70a0B61c8390D0BE5c7370BFbC6126412F01 reserve0:  2991763995894108751347 reserve1:  134833010176600701450665661719324
[+] pair:  0x6d2Cc2E3882379CCDcca52CfaD5069217fC1F49B fee:  35 isBakery:  ZooSwap outId:  1 token0:  0x67Fa70a0B61c8390D0BE5c7370BFbC6126412F01 token1:  0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51 reserve0:  316324247 reserve1:  1
[+] pair:  0x4d5e9dc1f268DA07beBa6F1B071cEd8AE7Dfd064 fee:  30 isBakery:  PandaSwap outId:  0 token0:  0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c token1:  0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51 reserve0:  1852683707938757 reserve1:  952841027471648506
[+] pair:  0x304d7FE6227E8D2544C9271fe76d57A38a8882Ef fee:  25 isBakery:  PancakeSwap outId:  1 token0:  0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c token1:  0xD41F0597F7E90cA3750d86A3823fD2a0947B964A reserve0:  518313631 reserve1:  8000000003193
[+] pair:  0x1021079E1639d1A47AEfB3C16293Ecf884008eF5 fee:  25 isBakery:  PancakeSwap outId:  0 token0:  0x55d398326f99059fF775485246999027B3197955 token1:  
0xD41F0597F7E90cA3750d86A3823fD2a0947B964A reserve0:  5432934189900624990 reserve1:  25


root@sing:~/frontrun# ./frontrun cross --database ./pairs.db --account 0x6c3B7F6F177fFb38c06685A393f5f9128ECC0e99 --amount 167038393766388908 --pairs 0x8133908cdaB85F035145097AAcD0d0206784f747,0x7123431162c1efF257578D1574014e5305Eb7bd4,0x33FcB84f5e79082f62BA7de8285C9b37a68f1a02,0x4394Ab6678fd7bc6ce658558072CcE6a371B7de0,0x0e78474c19732108640bA7810fB91aAfc156103D --outid 0,0,1,0,1
[+] found  5 in database.
[+] pair:  0x8133908cdaB85F035145097AAcD0d0206784f747 fee:  9977 isBakery:  DonkSwap outId:  0 token0:  0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c token1:  0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 reserve0:  1202166914663553 reserve1:  442087036969686461
[+] pair:  0x7123431162c1efF257578D1574014e5305Eb7bd4 fee:  9977 isBakery:  DonkSwap outId:  0 token0:  0x3969Fe107bAe2537cb58047159a83C33dfbD73f9 token1:  0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c reserve0:  27052163246610316808309 reserve1:  52083955018711283856
[+] pair:  0x33FcB84f5e79082f62BA7de8285C9b37a68f1a02 fee:  9977 isBakery:  DonkSwap outId:  1 token0:  0x3969Fe107bAe2537cb58047159a83C33dfbD73f9 token1:  0x7c1608C004F20c3520f70b924E2BfeF092dA0043 reserve0:  699876745208334605568 reserve1:  1659987327414561293408373035
[+] pair:  0x4394Ab6678fd7bc6ce658558072CcE6a371B7de0 fee:  9980 isBakery:  BabySwap outId:  0 token0:  0x0E52d24c87A5ca4F37E3eE5E16EF5913fb0cCEEB token1:  0x7c1608C004F20c3520f70b924E2BfeF092dA0043 reserve0:  22546572610954539381090 reserve1:  14580425527907278858672486
[+] pair:  0x0e78474c19732108640bA7810fB91aAfc156103D fee:  9980 isBakery:  BabySwap outId:  1 token0:  0x0E52d24c87A5ca4F37E3eE5E16EF5913fb0cCEEB token1:  0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 reserve0:  1346758191217369731642 reserve1:  1102255512069502617
transaction hash:  0x98134df842bb518ea6c935857399c9ff4c58c06a6172b9d733a583e5c0e20b35



test error: ( execution reverted: E001 ) path => amountIn:  1864911505261149 reward:  3631823153184690697
    pair: 0x3000f4e6c0d608B506190B58C2E12ff2bdB70706 [0x05375EcAc19DE6F5d02983061918fd2338bAAD32 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] [3978324891619538481 59654556681801845538] 0 9975
    pair: 0xE5560C99193F88Bea6468AC1BBFD8080F531BF9e [0x05375EcAc19DE6F5d02983061918fd2338bAAD32 0x55d398326f99059fF775485246999027B3197955] [6195498985020010551 103307939634576363685] 1 9975
    pair: 0x14F630bF0a37A71fd6f7131Cc19F901059449785 [0x55d398326f99059fF775485246999027B3197955 0xC808592e5b4585F982bc728d63b227634bc007a4] [78007408409775 22468058681717596898] 1   9970
    pair: 0xC16E65bd4AD5f0Cc47e0FE28E3f37de1290a4665 [0x7661C7714A2AE18Bd224d2bFa7619d6aB7b8f640 0xC808592e5b4585F982bc728d63b227634bc007a4] [66038937414143638270705 1865541059699016022] 0 9980
    pair: 0xA5bd1E1429dFc8784EbFF2f2fe75fd5283eFdF29 [0x7661C7714A2AE18Bd224d2bFa7619d6aB7b8f640 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] [13209663991458687185479 4423149315511083786] 1 9970


0x19c6ca1b
0xef9a50e3
f045b2b78d1d331adac225e665a1ac349712f37b22c698e94adcf302eb182ed0
00000000000000000000000000000026f7000000000000000000000000000000
c49964ea1709aedd4f02d09cdc908db7d9513ed15cfc6124eeedce81b4ede539
000000000000000007676ca918cd38e2ffe04104e9a66c4c39e53e7a8bb5be4d
1662fdcf62c652bf811f689d14fd7e50e8fee49cae26d1d25e1db4db7574ebaa
0000000000000000013433ab8e9507a99914d02c206ab3818013cdf4feee9a26
000000000000000000000000fd1ad21d2b834104e9a66b2457c9e365a9c13b71

6617239c467dce74c813da504afd8d5dd0848b334bb9e565fc22b8052582db6e
000000000000000b047ccbd063a6f1e3bf034104e9ad6f6f0ac329bddeadff57
0026f701c8bda9808497fedf83ee5fbec54d6e951baf10798c2ffb94dd9f64e6
0000000000000000013437b401cbc8f60aa5159c9c31496a3aa83a354c34d658
000000000000000000000000fd1ad21d1f9e4104e9aec3007405b53f104896fc


下面这个套利交易中，共涉及三个交易所。
https://bscscan.com/tx/0x1cf7d3a96b1c97d2050de3c9bc11f44098d4ce6b5305addb6fd15b433c4a6d8d

1、PancakeSwap(fee:25) 0x9d3ce421fce1e8d9d9ed9869cf58536260231edc：WBNB -> QAA
2、SushiSwap(fee:30)   0x94336dae271e08feff9bade7df246691605ef8a3：QAA -> STR
3、SushiSwap(fee:30)   0x92668470f7d8cad51c101fd896af2a6f8354f2c8：STR -> WBNB

在这笔交易之前，这三个交易的余额分别是
1、0x9d3ce421fce1e8d9d9ed9869cf58536260231edc：WBNB (824088280168738919) -> QAA (59693444465507608)
2、0x94336dae271e08feff9bade7df246691605ef8a3：QAA (233121354645793410) -> STR (121779730023920454)
3、0x92668470f7d8cad51c101fd896af2a6f8354f2c8：STR (379671196363402517)-> WBNB (2075109038689358143)

在这笔交易之后，这三个交易的余额分别是
1、0x9d3ce421fce1e8d9d9ed9869cf58536260231edc：WBNB (1008522949827224899) -> QAA (48799255070577118)
2、0x94336dae271e08feff9bade7df246691605ef8a3：QAA (24401554404p0723900) -> STR (45757254106199324)
3、0x92668470f[](https://codeantenna.com/a/w7yx0O2aKZ)7d8cad51c101fd896af2a6f8354f2c8：STR (455693672281123647)-> WBNB (1729788425093782365)

[+] create token graph cost  1m26.384861699s
find best:  17942657255536212777 21538637807362040700
     0x804678fa97d91B974ec2af3c843270886528a9E6 [1693552837911121381897606 6861596712904115924058540] 0
     0x57Bb8e92049cD3DCeF94C129C27B3e848Fe13d19 [3674228808825140236 52473089174] 1
     0xa141E5A9C005Cf57774eff62Caf3fF16550FC1d6 [247956691235685268899 55382404926795] 0
     0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16 [301218850937976481396213 93345152435781827961380503] 1
[+] BUSD-WBNB find best time cost  668.834006ms
find best:  82430494063279216213 16383096986081912029
     0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE [82726617258871554647319775 266886446916205685060816] 1
     0x1642bAf29eFcF0d5d30c350fB11CB4A849B63cc6 [60402250468622160545 1411556235833449970] 0
     0x2432011D5F2C0F827Ed4E61610bE0205c7BABf4C [999985574817706332624 10487606709940090194860] 1
[+] USDT-WBNB find best time cost  1.00312802s
PASS
ok      github.com/mevtools/frontrun/utils      91.789s

[+] create token graph cost  1m27.522948906s
find best:  300026300822950272356883 92443126048734447234815896
     0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16 [301218850937976481396213 93345152435781827961380503] 0
     0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16 [301218850937976481396213 93345152435781827961380503] 1

https://medium.com/@t.tak/how-to-reduce-gas-cost-in-solidity-f2e5321e0395#8a0a


0x0000000000000000000000008394eccd5637cad3b4615af6dbe6f6d3b4305a0f0000000000000000000000008394eccd5637cad3b4615af6dbe6f6d3b4305a0f0000000000000000000000008394eccd5637cad3b4615af6dbe6f6d3b4305a0f0000000000000000000000008394eccd5637cad3b4615af6dbe6f6d3b4305a0f0000000000000000000000008394eccd5637cad3b4615af6dbe6f6d3b4305a0f

[751198929639273921894512153403534839782038329871,751198929639273921894512153403534839782038329871,751198929639273921894512153403534839782038329871,751198929639273921894512153403534839782038329871,751198929639273921894512153403534839782038329871]


返回结果这样：

INFO [08-26|06:38:57.703] found space for cycle arbitrage          during=25.657353ms amountIn=643848028244175196282752  reward=1885292811939391529995961
INFO [08-26|06:38:57.704] [+]                                      pair=0xD59F2D2428A590627579BA87F6582235963d3840 fee=9970
INFO [08-26|06:38:57.704] [+]                                      token0=0x04fA9Eb295266d9d4650EDCB879da204887Dc3Da token1=0x55d398326f99059fF775485246999027B3197955 outId=0
INFO [08-26|06:38:57.704] [+]                                      reserve0=1606621048405967435962940         reserve1=11575181119684986302530652
INFO [08-26|06:38:57.704] [+]                                      pair=0xD59F2D2428A590627579BA87F6582235963d3840 fee=9970
INFO [08-26|06:38:57.704] [+]                                      token0=0x04fA9Eb295266d9d4650EDCB879da204887Dc3Da token1=0x55d398326f99059fF775485246999027B3197955 outId=1
INFO [08-26|06:38:57.704] [+]                                      reserve0=1606621048405967435962940         reserve1=11575181119684986302530652
INFO [08-26|06:38:57.704] [+]                                      pair=0xA39Af17CE4a8eb807E076805Da1e2B8EA7D0755b fee=9975
INFO [08-26|06:38:57.704] [+]                                      token0=0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82 token1=0x55d398326f99059fF775485246999027B3197955 outId=0
INFO [08-26|06:38:57.704] [+]                                      reserve0=1119337994664986100838391         reserve1=4421219152105880621503928
INFO [08-26|06:38:57.704] [+]                                      pair=0xA39Af17CE4a8eb807E076805Da1e2B8EA7D0755b fee=9975
INFO [08-26|06:38:57.704] [+]                                      token0=0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82 token1=0x55d398326f99059fF775485246999027B3197955 outId=1
INFO [08-26|06:38:57.704] [+]                                      reserve0=1119337994664986100838391         reserve1=4421219152105880621503928
WARN [08-26|06:38:57.705] this cross can not pass simulation       err="execution reverted: E001"


INFO [08-26|07:32:07.593] found space for cycle arbitrage          during=1.607555ms  amountIn=2267353657837            reward=51339878988970632870241
INFO [08-26|07:32:07.593] [+]                                      pair=0xED933Ba0B104fe93f3297ACd085B1ED66D06992B fee=9970
INFO [08-26|07:32:07.593] [+]                                      token0=0x2AA504586d6CaB3C59Fa629f74c586d78b93A025 token1=0x55d398326f99059fF775485246999027B3197955 outId=0
INFO [08-26|07:32:07.593] [+]                                      reserve0=16225205361801853109         reserve1=10312321474235240381
INFO [08-26|07:32:07.593] [+]                                      pair=0x3DE032D5D11c94d2d79dBa0c34D7851FFAA05DD8 fee=9975
INFO [08-26|07:32:07.593] [+]                                      token0=0x2AA504586d6CaB3C59Fa629f74c586d78b93A025 token1=0x55d398326f99059fF775485246999027B3197955 outId=1
INFO [08-26|07:32:07.593] [+]                                      reserve0=4156192058004437052192572    reserve1=2651363364660796268702790
INFO [08-26|07:32:07.593] [+]                                      pair=0x2c5d15eD83e7465B55845c6B245B0d40d173e8aD fee=9975
INFO [08-26|07:32:07.593] [+]                                      token0=0x55d398326f99059fF775485246999027B3197955 token1=0xe8670901E86818745b28C8b30B17986958fCe8Cc outId=1
INFO [08-26|07:32:07.593] [+]                                      reserve0=51218059081865680164058      reserve1=2265004402137
INFO [08-26|07:32:07.593] [+]                                      pair=0x2c5d15eD83e7465B55845c6B245B0d40d173e8aD fee=9975
INFO [08-26|07:32:07.593] [+]                                      token0=0x55d398326f99059fF775485246999027B3197955 token1=0xe8670901E86818745b28C8b30B17986958fCe8Cc outId=0
INFO [08-26|07:32:07.593] [+]                                      reserve0=51218059081865680164058      reserve1=2265004402137
WARN [08-26|07:32:07.595] this cross can not pass simulation       err="execution reverted: Pancake: K"


INFO [08-26|09:30:01.789] found space for cycle arbitrage          during="140.473µs" amountIn=457335438680732330172018       reward=3432773069525646578672418
INFO [08-26|09:30:01.789] [0]                                      pair=0xD59F2D2428A590627579BA87F6582235963d3840 fee=9970
INFO [08-26|09:30:01.789] [+]                                      token0=0x04fA9Eb295266d9d4650EDCB879da204887Dc3Da token1=0x55d398326f99059fF775485246999027B3197955 outId=0
INFO [08-26|09:30:01.789] [+]                                      reserve0=1624014252855293376892506         reserve1=11616405108551985782000081
INFO [08-26|09:30:01.789] [1]                                      pair=0xD59F2D2428A590627579BA87F6582235963d3840 fee=9970
INFO [08-26|09:30:01.789] [+]                                      token0=0x04fA9Eb295266d9d4650EDCB879da204887Dc3Da token1=0x55d398326f99059fF775485246999027B3197955 outId=1
INFO [08-26|09:30:01.789] [+]                                      reserve0=1624014252855293376892506         reserve1=11616405108551985782000081
INFO [08-26|09:30:01.789] [2]                                      pair=0x4088e197c97d0188EFBF77B316100Ac456aB4eca fee=9975
INFO [08-26|09:30:01.789] [+]                                      token0=0x55d398326f99059fF775485246999027B3197955 token1=0xC544D8aB2b5ED395B96E3Ec87462801ECa579aE1 outId=1
INFO [08-26|09:30:01.789] [+]                                      reserve0=581912592452221665799965          reserve1=4977014300984279614466975
INFO [08-26|09:30:01.789] [3]                                      pair=0x4088e197c97d0188EFBF77B316100Ac456aB4eca fee=9975
INFO [08-26|09:30:01.789] [+]                                      token0=0x55d398326f99059fF775485246999027B3197955 token1=0xC544D8aB2b5ED395B96E3Ec87462801ECa579aE1 outId=0
INFO [08-26|09:30:01.789] [+]                                      reserve0=581912592452221665799965          reserve1=4977014300984279614466975
WARN [08-26|09:30:01.790] this cross can not pass simulation       err="execution reverted: E001"



INFO [08-31|11:51:23.424] out                                      amountIn=1315987016577997058   reward=1175336752851022157
INFO [08-31|11:51:23.424] [0]                                      pair=0x66c888BF565e258e24ba296f852081ffD4849BA6 fee=9970
INFO [08-31|11:51:23.424] [+]                                      token0=0x55d398326f99059fF775485246999027B3197955 token1=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 outId=0
INFO [08-31|11:51:23.424] [+]                                      reserve0=548742013535134533160              reserve1=551509862382792015907
INFO [08-31|11:51:23.424] [1]                                      pair=0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE fee=9975
INFO [08-31|11:51:23.424] [+]                                      token0=0x55d398326f99059fF775485246999027B3197955 token1=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c outId=1
INFO [08-31|11:51:23.424] [+]                                      reserve0=82294740448238519751304914         reserve1=286852996072196313682995
INFO [08-31|11:51:23.424] [2]                                      pair=0x33D8B50fb223Cf3803e3c72FA9f8Df92e0139Cee fee=9980
INFO [08-31|11:51:23.424] [+]                                      token0=0x44ed71E77D487D78E3E68FA91a971bFD53B66cC7 token1=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c outId=0
INFO [08-31|11:51:23.424] [+]                                      reserve0=46367644073290738320000            reserve1=61520718209108524
INFO [08-31|11:51:23.424] [3]                                      pair=0x318801526964eBccbCC47951bE813D546bA8AD58 fee=9980
INFO [08-31|11:51:23.424] [+]                                      token0=0x44ed71E77D487D78E3E68FA91a971bFD53B66cC7 token1=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 outId=1
INFO [08-31|11:51:23.424] [+]                                      reserve0=4170000000000000000000             reserve1=5772024564814567488
WARN [08-31|11:51:23.424] this cross can not pass simulation       err="execution reverted: Pancake: TRANSFER_FAILED"
----------------------------------------------------
INFO [08-31|11:51:20.422] out                                      amountIn=3136140776836207058   reward=2463874106814654204
INFO [08-31|11:51:20.422] [0]                                      pair=0x69758726b04e527238B261ab00236AFE9F34929D fee=9975
INFO [08-31|11:51:20.422] [+]                                      token0=0x7dEb9906BD1d77B410a56E5C23c36340Bd60C983 token1=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 outId=0
INFO [08-31|11:51:20.422] [+]                                      reserve0=110448612392215490924709           reserve1=15298761302914450430571
INFO [08-31|11:51:20.422] [1]                                      pair=0xF93423685D8C48c37E0B8fBc2b5514De46e9d42B fee=9975
INFO [08-31|11:51:20.422] [+]                                      token0=0x2170Ed0880ac9A755fd29B2688956BD959F933F8 token1=0x7dEb9906BD1d77B410a56E5C23c36340Bd60C983 outId=0
INFO [08-31|11:51:20.422] [+]                                      reserve0=8733857772391228                   reserve1=31099356632034523680
INFO [08-31|11:51:20.423] [2]                                      pair=0x531FEbfeb9a61D948c384ACFBe6dCc51057AEa7e fee=9975
INFO [08-31|11:51:20.423] [+]                                      token0=0x2170Ed0880ac9A755fd29B2688956BD959F933F8 token1=0x55d398326f99059fF775485246999027B3197955 outId=1
INFO [08-31|11:51:20.423] [+]                                      reserve0=270947395807408140274              reserve1=431417249542367962825262
INFO [08-31|11:51:20.423] [3]                                      pair=0x6eAEC629B9CFa7acd507c50887C4851507Da67E6 fee=9970
INFO [08-31|11:51:20.423] [+]                                      token0=0x55d398326f99059fF775485246999027B3197955 token1=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 outId=1
INFO [08-31|11:51:20.423] [+]                                      reserve0=164186879649433670680              reserve1=163877983438811503139
WARN [08-31|11:51:20.423] this cross can not pass simulation       err="execution reverted: Pancake: INSUFFICIENT_INPUT_AMOUNT"

--------------------------------------------------------

INFO [08-31|14:17:39.497] out                                      amountIn=2714653884363665308   reward=2137555090332213731
INFO [08-31|14:17:39.497] [0]                                      pair=0x69758726b04e527238B261ab00236AFE9F34929D fee=9975
INFO [08-31|14:17:39.497] [+]                                      token0=0x7dEb9906BD1d77B410a56E5C23c36340Bd60C983 token1=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 outId=0
INFO [08-31|14:17:39.497] [+]                                      reserve0=110700251787601547561173     reserve1=15333617069420144687753
INFO [08-31|14:17:39.497] [1]                                      pair=0xF93423685D8C48c37E0B8fBc2b5514De46e9d42B fee=9975
INFO [08-31|14:17:39.497] [+]                                      token0=0x2170Ed0880ac9A755fd29B2688956BD959F933F8 token1=0x7dEb9906BD1d77B410a56E5C23c36340Bd60C983 outId=0
INFO [08-31|14:17:39.497] [+]                                      reserve0=8733857772391228             reserve1=31099356632034523680
INFO [08-31|14:17:39.497] [2]                                      pair=0x4FAa3322eEDD73425f9BAa34CBC479631A7ea9EF fee=9980
INFO [08-31|14:17:39.497] [+]                                      token0=0x2170Ed0880ac9A755fd29B2688956BD959F933F8 token1=0xBf5140A22578168FD562DCcF235E5D43A02ce9B1 outId=1
INFO [08-31|14:17:39.497] [+]                                      reserve0=34120055216830218            reserve1=8526952314630421153
INFO [08-31|14:17:39.497] [3]                                      pair=0x72F1d53B2E4bDE565fE54AF13697857e71193dDf fee=9970
INFO [08-31|14:17:39.497] [+]                                      token0=0xBf5140A22578168FD562DCcF235E5D43A02ce9B1 token1=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 outId=1
INFO [08-31|14:17:39.497] [+]                                      reserve0=84647261202946783857682      reserve1=539099154151998569172418
WARN [08-31|14:17:39.498] this cross can not pass simulation       err="execution reverted: Pancake: INSUFFICIENT_INPUT_AMOUNT"


{
	"linkReferences": {},
	"object": "6080604052348015600f57600080fd5b50603f80601d6000396000f3006080604052348015600f57600080fd5b5033ff00a165627a7a723058200cc3bfb695c70a7c80ed07d1a753a1f6cd622d5a9eaf87bf58889f9d33ad98f80029",
	"opcodes": "PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH1 0xF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH1 0x3F DUP1 PUSH1 0x1D PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN STOP PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH1 0xF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP CALLER SELFDESTRUCT STOP LOG1 PUSH6 0x627A7A723058 KECCAK256 0xc 0xc3 0xbf 0xb6 SWAP6 0xc7 EXP PUSH29 0x80ED07D1A753A1F6CD622D5A9EAF87BF58889F9D33AD98F80029000000 ",
	"sourceMap": "0:83:0:-;;;;8:9:-1;5:2;;;30:1;27;20:12;5:2;0:83:0;;;;;;;"
}

0x0000000000b3f879cb30fe243b4dfee438691c04

{
	"linkReferences": {},
	"object": "6080604052348015600f57600080fd5b50605980601d6000396000f3006080604052348015600f57600080fd5b506eb3f879cb30fe243b4dfee438691c043314602a57600080fd5b33ff00a165627a7a723058204d396a7a76a8deaa6f8133021239425137592de12bbf82c8d3658ea4c1b094120029",
	"opcodes": "PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH1 0xF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH1 0x59 DUP1 PUSH1 0x1D PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN STOP PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH1 0xF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH15 0xB3F879CB30FE243B4DFEE438691C04 CALLER EQ PUSH1 0x2A JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST CALLER SELFDESTRUCT STOP LOG1 PUSH6 0x627A7A723058 KECCAK256 0x4d CODECOPY PUSH11 0x7A76A8DEAA6F8133021239 TIMESTAMP MLOAD CALLDATACOPY MSIZE 0x2d 0xe1 0x2b 0xbf DUP3 0xc8 0xd3 PUSH6 0x8EA4C1B09412 STOP 0x29 ",
	"sourceMap": "0:1889:0:-;;;;8:9:-1;5:2;;;30:1;27;20:12;5:2;0:1889:0;;;;;;;"
}
6eb3f879cb30fe243b4dfee438691c043318585833ff
3360701c654e4e4e4e4e4e18585733ff
756eb3f879cb30fe243b4dfee438691c043318585733ff6000526016600af3
6133ff60005260026010f3
3360701c604e18585733ff
3360701c604e18585733ff
0000000000000000000000000000000000000000006133ff6000526002600af3
6f3360701c654e4e4e4e4e4e18585733ff60005260106010f3
63600035ff6000526004601cf3


nohup ./gokey > r00.txt &
nohup ./gokey > r01.txt &
nohup ./gokey > r02.txt &
nohup ./gokey > r03.txt &
nohup ./gokey > r04.txt &
nohup ./gokey > r05.txt &
nohup ./gokey > r06.txt &
nohup ./gokey > r07.txt &
nohup ./gokey > r10.txt &
nohup ./gokey > r11.txt &
nohup ./gokey > r12.txt &
nohup ./gokey > r13.txt &
nohup ./gokey > r14.txt &
nohup ./gokey > r15.txt &
nohup ./gokey > r16.txt &
nohup ./gokey > r17.txt &
nohup ./gokey > r20.txt &
nohup ./gokey > r21.txt &
nohup ./gokey > r22.txt &
nohup ./gokey > r23.txt &
nohup ./gokey > r24.txt &
nohup ./gokey > r25.txt &
nohup ./gokey > r26.txt &
nohup ./gokey > r27.txt &
nohup ./gokey > r30.txt &
nohup ./gokey > r31.txt &
nohup ./gokey > r32.txt &
nohup ./gokey > r33.txt &
nohup ./gokey > r34.txt &
nohup ./gokey > r35.txt &
nohup ./gokey > r36.txt &
nohup ./gokey > r37.txt &
nohup ./gokey > r40.txt &
nohup ./gokey > r41.txt &
nohup ./gokey > r42.txt &
nohup ./gokey > r43.txt &
nohup ./gokey > r44.txt &
nohup ./gokey > r45.txt &
nohup ./gokey > r46.txt &
nohup ./gokey > r47.txt &
nohup ./gokey > r50.txt &
nohup ./gokey > r51.txt &
nohup ./gokey > r52.txt &
nohup ./gokey > r53.txt &
nohup ./gokey > r54.txt &
nohup ./gokey > r55.txt &
nohup ./gokey > r56.txt &
nohup ./gokey > r57.txt &
nohup ./gokey > r60.txt &
nohup ./gokey > r61.txt &
nohup ./gokey > r62.txt &
nohup ./gokey > r63.txt &
nohup ./gokey > r64.txt &
nohup ./gokey > r65.txt &
nohup ./gokey > r66.txt &
nohup ./gokey > r67.txt &
nohup ./gokey > r70.txt &
nohup ./gokey > r71.txt &
nohup ./gokey > r72.txt &
nohup ./gokey > r73.txt &
nohup ./gokey > r74.txt &
nohup ./gokey > r75.txt &
nohup ./gokey > r76.txt &
nohup ./gokey > r77.txt &
nohup ./gokey > r80.txt &
nohup ./gokey > r81.txt &
nohup ./gokey > r82.txt &
nohup ./gokey > r83.txt &
nohup ./gokey > r84.txt &
nohup ./gokey > r85.txt &
nohup ./gokey > r86.txt &
nohup ./gokey > r87.txt &
nohup ./gokey > r90.txt &
nohup ./gokey > r91.txt &
nohup ./gokey > r92.txt &
nohup ./gokey > r93.txt &
nohup ./gokey > r94.txt &
nohup ./gokey > r95.txt &
nohup ./gokey > r96.txt &
nohup ./gokey > r97.txt &
nohup ./gokey > ra0.txt &
nohup ./gokey > ra1.txt &
nohup ./gokey > ra2.txt &
nohup ./gokey > ra3.txt &
nohup ./gokey > ra4.txt &
nohup ./gokey > ra5.txt &
nohup ./gokey > ra6.txt &
nohup ./gokey > ra7.txt &
nohup ./gokey > rb0.txt &
nohup ./gokey > rb1.txt &
nohup ./gokey > rb2.txt &
nohup ./gokey > rb3.txt &
nohup ./gokey > rb4.txt &
nohup ./gokey > rb5.txt &
nohup ./gokey > rb6.txt &
nohup ./gokey > rb7.txt &
nohup ./gokey > rc0.txt &
nohup ./gokey > rc1.txt &
nohup ./gokey > rc2.txt &
nohup ./gokey > rc3.txt &
nohup ./gokey > rc4.txt &
nohup ./gokey > rc5.txt &
nohup ./gokey > rc6.txt &
nohup ./gokey > rc7.txt &



{"code":1,"message":"OK","result":{"0xf29ac0cc7611155595c40890c3b6b3fbf85b5f1c":{"buy_tax":"0","can_take_back_ownership":"0","cannot_buy":"0","creator_address":"0xb9aafe776d70b432b53f7ce0f3aa5d194c6b6005","creator_balance":"393139280.249366095677970556","creator_percent":"0.393139","dex":[{"name":"PancakeV2","liquidity":"28.67292092","pair":"0xc2d94E0F00B3deCB22DC98962B7274a2F05f2DED"},{"name":"PancakeV2","liquidity":"0.03186784","pair":"0x76F342Cb651b44CdB6E6A4350B5BF63a346350Ac"}],"external_call":"0","hidden_owner":"1","holder_count":"402","holders":[{"address":"0x1a1d6e38c2bf676c19e6dfc9a02a3e27b8f4c946","tag":"","is_contract":0,"balance":"479666347.202","percent":"0.479666344803668275","is_locked":0},{"address":"0xb9aafe776d70b432b53f7ce0f3aa5d194c6b6005","tag":"","is_contract":0,"balance":"393139280.24937","percent":"0.393139278283673608","is_locked":0},{"address":"0x1a705bf5a327bad29bca0ca8002039bdea9c06dc","tag":"","is_contract":0,"balance":"35344902.084231","percent":"0.035344901907506490","is_locked":0},{"address":"0x59d7d59577def4fa5199877821d31b6107649397","tag":"","is_contract":0,"balance":"31757025.680572","percent":"0.031757025521786872","is_locked":0},{"address":"0x357d5edf29adfa6937933bd99e4ed12b676098db","tag":"","is_contract":1,"balance":"14051538.126683","percent":"0.014051538056425309","is_locked":0},{"address":"0x904edb6f206e2fafaf4183fb4117320752a398e4","tag":"","is_contract":0,"balance":"7498370.5009874","percent":"0.007498370463495547","is_locked":0},{"address":"0x5eb80dbdaa76fac25615575af2afc77313788307","tag":"","is_contract":0,"balance":"3250120.280366","percent":"0.003250120264115398","is_locked":0},{"address":"0x4a054c66fbeb4b2ca40036db0ee383c34a89473f","tag":"","is_contract":0,"balance":"2424656.4177604","percent":"0.002424656405637117","is_locked":0},{"address":"0xa2930602482351fc6ff19ae49dc6527f933a8810","tag":"","is_contract":0,"balance":"1904936.4214282","percent":"0.001904936411903517","is_locked":0},{"address":"0x47cca9666d547558cb79777fc18abe42bacdbb77","tag":"","is_contract":0,"balance":"1641713.425759","percent":"0.001641713417550432","is_locked":0}],"is_anti_whale":"0","is_blacklisted":"1","is_honeypot":"0","is_in_dex":"1","is_mintable":"0","is_open_source":"1","is_proxy":"0","is_whitelisted":"1","lp_holder_count":"2","lp_holders":[{"address":"0x0ed943ce24baebf257488771759f9bf482c39706","tag":"","is_contract":1,"balance":"2019.8428206881","percent":"1.000000000000022463","is_locked":0},{"address":"0x0000000000000000000000000000000000000000","tag":"","is_contract":0,"balance":"0.000000000000001000","percent":"0.000000000000000000","is_locked":1}],"lp_total_supply":"2019.842820688054627331","owner_address":"0xb9aafe776d70b432b53f7ce0f3aa5d194c6b6005","owner_balance":"393139280.249366095677970556","owner_change_balance":"0","owner_percent":"0.393139","personal_slippage_modifiable":"0","selfdestruct":"0","sell_tax":"1","slippage_modifiable":"0","total_supply":"1000000005.000000000000000000","trading_cooldown":"0","transfer_pausable":"1","token_name":"TNK","token_symbol":"TNK"}}}


./build/bin/geth --config ./config.toml --datadir /data/bsc/ --datadir.ancient /root/bscdata/ancient --pipecommit --cache 24576 -http --http.api=eth,debug,net,web3,txpool --rpc.allow-unprotected-txs --networkid 56 --datadir.minfreedisk 4096 --ws --ws.origins all --log.debug --txlookuplimit=0 --diffsync=true --syncmode=full --tries-verify-mode=none --pruneancient=true --diffblock=5000


5860208158601c335a63aaf10f428752fa158151803b80938091923cf3

0acbbd5840e7afc64af133e2390863be199ca4092156714bc95c6e522857906f


addr:  0x8894E0a0c962CB723c1976a4421c95949bE2D4E3
 diff.Nonce:  map[*:map[from:0xc6c597 to:0xc6c598]]
 diff.Balance:  =
 diff.Storage:  map[]
addr:  0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
 diff.Nonce:  =
 diff.Balance:  =
 diff.Storage:  map[0x14d9da768efe529d9c993e4e49395180712dad9a9d245338030cf7e64f04a8ec:map[*:map[from:0x000000000000000000000000000000000000000000000035ff3d3d77e0cfe071 to:0x00000000000000000000000000000000000000000000006bfe7a7aefc19fc0e2]] 0x2a1e20cfdc0a1a03b0a1a44fdd9fd5fa930358e5b8221476467d529192e1b4b4:map[*:map[from:0x000000000000000000000000000000000000000000bdac0faf1eb19d57d18736 to:0x000000000000000000000000000000000000000000bdabd9afe174257701a6c5]]]

