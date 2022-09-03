# clip
antiSpam Address: 0x085C0d0dF430C4e1cCaeDDFdfA7D2143ec2c9ADB

trader Contract Address 1: 0xAA75Eada2F91811527F2D77eB63Ae8a32349681C (buy, cross)

trader Contract Address 2: 0x2c0fc53C64FE109FD546A8Af1C47394F5436e93b (sell, cross)

buyer bank: 0x8f5c50d478eCcd4DF9F83bE7293d8e4D37dD46d5

seller bank: 0x357D5EdF29aDFa6937933BD99E4Ed12b676098dB

test honey: 0x78A78E931421a16893e879D4660a074A3D926daA

test token fee: 0x231dB44485b11ee14CfDeC3b207dC5114a049D6a

test buyer: 0xA7f4Bd3A2bFBf9Db4dE6E5A0dCE4720be4F2bDD2

trader cross: 0x04F616A35667c447a2B5f093D632bBbCfD36eeE4

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