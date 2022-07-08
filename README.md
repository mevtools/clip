# clip
antiSpam Address: 0x085C0d0dF430C4e1cCaeDDFdfA7D2143ec2c9ADB

trader Contract Address 1: 0xDbE39ebAe25C48c1DA536ddc456DfB4C81f456f5 // only buy

trader Contract Address 2: 0x80254A9B30443C0Dffbc5E9A5d7ECC208bf1d413 // only sell

buyer bank: 0x8f5c50d478eCcd4DF9F83bE7293d8e4D37dD46d5

seller bank: 0x357D5EdF29aDFa6937933BD99E4Ed12b676098dB

## 调用流程

1. 随机生成256位的requestId
2. 选择seller的账户，比如账户 A
2. 账户A 调用Seller的trySellToken方法卖出
3. 账户B 调用Buyer的tryBuyToken买入（较高gas price）
4. 账户C 调用antiSpam合约的updateRequestId()方法更新requestId（加密） （更高的gas price）

传入的参数有加密，加解密方法见合约代码

只有账户A需要加锁（即只能待上一个卖出后才能作为新的seller），其它账户B、C不需要加锁

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


  bsc/build/bin/geth --config ./config.toml --datadir /data/bsc/ --datadir.ancient /root/chaindata/ancient --pipecommit --cache 65536 -http --http.api=eth,debug,net,web3,txpool --rpc.allow-unprotected-txs --txlookuplimit 0 --networkid 56 --datadir.minfreedisk 4096 --txpool.locals '0x6994Cb5F2baF25BFE8Ca2E49fD1Cec5D8559a16c, 0x46e3702Fe8a5c5532e368D768418b3cacF1623eE, 0x0c9Fc86153c0219BD9EA432A05A20F280a3a7c8f, 0x0CA7C62D2b0abF4B64f04686d0E7cF52Da9a9D11, 0x859d2D5Cf3E02C667702B9098C389dB26559A671,0xEaAeadA6F22e4EA5ed9710C111d322566125433B, 0xCb0b64205c3A03a6D19895862f00706d16f11fF4, 0x78385cbCF1c3143Eb206f5Dd084D30697d85b9b7, 0x43f8FE4F62C9bD35665baB792bb7f8e1A8546f3d,0xCf11DC3d0731c45D57395289e187143f7C30c793' --ws --ws.origins all

  bsc/build/bin/geth --config ./config.toml --datadir node --pipecommit --cache 65536 -http --http.api=eth,debug,net,web3,txpool --rpc.allow-unprotected-txs --txlookuplimit 0 --networkid 56 --datadir.minfreedisk 4096 --txpool.locals '0x6994Cb5F2baF25BFE8Ca2E49fD1Cec5D8559a16c, 0x46e3702Fe8a5c5532e368D768418b3cacF1623eE, 0x0c9Fc86153c0219BD9EA432A05A20F280a3a7c8f, 0x0CA7C62D2b0abF4B64f04686d0E7cF52Da9a9D11, 0x859d2D5Cf3E02C667702B9098C389dB26559A671,0xEaAeadA6F22e4EA5ed9710C111d322566125433B, 0xCb0b64205c3A03a6D19895862f00706d16f11fF4, 0x78385cbCF1c3143Eb206f5Dd084D30697d85b9b7, 0x43f8FE4F62C9bD35665baB792bb7f8e1A8546f3d,0xCf11DC3d0731c45D57395289e187143f7C30c793' --ws --ws.origins all