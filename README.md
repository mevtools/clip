# clip
antiSpam Address: 0x085C0d0dF430C4e1cCaeDDFdfA7D2143ec2c9ADB

trader Contract Address 1: 0x9E69f5A54BaC73234F08339dC6C84906BDcc6273 (cross)

trader Contract Address 2: 0x48D4D1a7F03439D5411Bd5b9a766BCc8709bE46a

buyer bank: 0x8f5c50d478eCcd4DF9F83bE7293d8e4D37dD46d5

seller bank: 0x357D5EdF29aDFa6937933BD99E4Ed12b676098dB

test honey: 0x6AddB842C153bc0D3b2fe5e8CAb8A9Bb22c63A0f

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