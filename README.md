# clip
Buyer Contract Address: 0xc9EAD7cAb0ce7167DA5df29DcE9b000B4b8b005E
Seller Contract Address: 0xdf156172cc94D65463F56F2276d6D4EeC24464C1

## 调用流程

1. 随机生成256位的requestId
2. 账户A 调用Seller的trySellToken方法卖出
3. 账户B 调用Buyer的tryBuyToken买入（较高gas price）
4. 账户A 先调用Seller合约的updateRequestId()方法更新requestId （更高的gas price）

传入的参数有加密，加解密方法见合约代码