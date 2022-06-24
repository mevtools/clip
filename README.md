# clip
antiSpam Address: 0x085C0d0dF430C4e1cCaeDDFdfA7D2143ec2c9ADB

trader Contract Address 1: 0x368930D3c3407A86dC68eC31bFb4ffDC25d6A535
trader Contract Address 2: 0xC49E923f2785bBA411FDB5A7A1fd5C3276a169fd

seller bank: 0x3A9d710F689241439c2Fa5bb702189682cee978f
buyer bank: 0xDbE3F612b0569d4fe43A5Db70C1f94004238a889

## 调用流程

1. 随机生成256位的requestId
2. 选择seller的账户，比如账户 A
2. 账户A 调用Seller的trySellToken方法卖出
3. 账户B 调用Buyer的tryBuyToken买入（较高gas price）
4. 账户C 调用antiSpam合约的updateRequestId()方法更新requestId（加密） （更高的gas price）

传入的参数有加密，加解密方法见合约代码

只有账户A需要加锁（即只能待上一个卖出后才能作为新的seller），其它账户B、C不需要加锁