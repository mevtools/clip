package main

import (
        "bufio"
        "bytes"
        "context"
        "crypto/ecdsa"
        "fmt"
        "github.com/ethereum/go-ethereum/accounts/abi/bind"
        "github.com/ethereum/go-ethereum/common"
        "github.com/ethereum/go-ethereum/core/types"
        "github.com/ethereum/go-ethereum/crypto"
        "github.com/ethereum/go-ethereum/ethclient"
        "github.com/ethereum/go-ethereum/ethclient/gethclient"
        "github.com/ethereum/go-ethereum/rpc"
        decoder "github.com/mingjingc/abi-decoder"
        "github.com/spf13/cobra"
        "github.com/spf13/viper"
        "gorm.io/driver/mysql"
        "gorm.io/gorm"
        "io/ioutil"
        "log"
        "main/contract"
        "math"
        "math/big"
        "math/rand"
        "os"
        "strings"
        "sync"
        "sync/atomic"
        "time"
)

type TradeAccounts struct {
        count       int
        addresses   []common.Address
        privateKeys []*ecdsa.PrivateKey
        nextNonce   []uint64
        balances    []*big.Int
        isBusy      []bool
        blockNumber *big.Int
        chainId     *big.Int

        lock *sync.Mutex
}

func (m *TradeAccounts) insertAccount(address common.Address, privateKey *ecdsa.PrivateKey) {
        ctx := context.Background()
        balance, err := conChain[0].EthClient.BalanceAt(ctx, address, m.blockNumber)
        if err != nil {
                log.Println("error: can not get balance at: ", address)
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        if err != nil {
                log.Println("error: can not get next nonce at: ", address)
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        m.addresses = append(m.addresses, address)
        m.privateKeys = append(m.privateKeys, privateKey)
        m.balances = append(m.balances, balance)
        m.isBusy = append(m.isBusy, false)
        m.count += 1
}

func (m *TradeAccounts) updateAllBalance() {
        ctx := context.Background()
        blockNumber, err := conChain[0].EthClient.BlockNumber(ctx)
        if err != nil {
                log.Println("error: can not get blockNumber from client, check network.")
                log.Println("error: ", err)
                os.Exit(1)
        }
        m.blockNumber.SetUint64(blockNumber)
        for i := 0; i < m.count; i++ {
                balance, err := conChain[0].EthClient.BalanceAt(ctx, m.addresses[i], m.blockNumber)
                if err != nil {
                        log.Println("warn: can not get balance at: ", m.addresses[i])
                        log.Println("warn: ", err)
                }
                m.balances[i] = balance
        }
}

func (m TradeAccounts) getCount() int {
        return m.count
}

func (m TradeAccounts) getAddressAt(idx int) common.Address {
        return m.addresses[idx]
}

func (m TradeAccounts) getBalanceAt(idx int) *big.Int {
        res := new(big.Int)
        res.SetBytes(m.balances[idx].Bytes())
        return res
}

// 参数withLock表示是否对账户加锁，不加的锁的是共享账户，可以执行买和设置id的操作，加锁账户用于执行卖出操作。
func (m *TradeAccounts) getFreeAccount(withLock bool) (*ecdsa.PrivateKey, int) {
        m.lock.Lock()
        defer m.lock.Unlock()

        var res *ecdsa.PrivateKey
        var idx int
        res = nil

        cnt := 1

        for {
                idx = rand.Int() % m.count
                if m.isBusy[idx] == false && m.balances[idx].Cmp(bn1e16) == 1 {
                        if withLock == true {
                                m.isBusy[idx] = true
                        }
                        res = m.privateKeys[idx]
                        break
                }
                cnt += 1
                // 尝试了m.count次，没有找到空闲的账户，则遍历循环，取第一个空闲的。
                if cnt > m.count/2 {
                        for i := 0; i < m.count; i++ {
                                if m.isBusy[idx] == false && m.balances[idx].Cmp(bn1e16) == 1 {
                                        if withLock == true {
                                                m.isBusy[idx] = true
                                        }
                                        res = m.privateKeys[idx]
                                        break
                                }
                        }
                        break
                }
        }
        return res, idx
}

func (m *TradeAccounts) freeThisAccount(idx int) {
        m.lock.Lock()
        m.isBusy[idx] = false
        m.lock.Unlock()
}

func (m TradeAccounts) sendSellToProviders(txOptsExecSell *bind.TransactOpts,
        pairEnc *big.Int, tokenInId int, minSellIn *big.Int) (bool, *types.Transaction) {
        waitG := sync.WaitGroup{}
        waitG.Add(len(conChain))

        exitsSellSentSuccess := int32(0)

        var sellTxRes *types.Transaction

        for i, con := range conChain {
                go func(idx int, con *ChainConnection) {
                        var err error
                        var sellTx *types.Transaction
                        if tokenInId == 1 {
                                sellTx, err = con.ClipSellContract.TrySellToken1(txOptsExecSell, pairEnc, minSellIn)
                        } else {
                                sellTx, err = con.ClipSellContract.TrySellToken0(txOptsExecSell, pairEnc, minSellIn)
                        }
                        if err == nil && sellTx != nil {
                                atomic.StoreInt32(&exitsSellSentSuccess, 1)
                                sellTxRes = sellTx
                                log.Println("log: sendSellToProviders sent sell,", sellTx.Hash(), " to ", con.ProviderName)
                        } else {
                                log.Println("error: sendSellToProviders ", con.ProviderName, err)
                        }
                        waitG.Done()
                }(i, con)
        }
        waitG.Wait()

        return exitsSellSentSuccess == 1, sellTxRes
}

func (m *TradeAccounts) SendTxTryBuyAndSellToken(tokenInId int, amountIn *big.Int, userFrom common.Address,
        pair common.Address, maxReserveIn *big.Int, minReserveIn *big.Int, buyGasPrice *big.Int, userTx *types.Transaction) {

        // 该函数可能同时有多个routine在执行，因此应该考虑数据同步的问题。
        ctx := context.Background()

        // 随机获得一个空闲的账户，注意这里可能存在条件竞争，需要加锁。
        privateKeySell, accountIdxSell := m.getFreeAccount(true)
        privateKeyBuy, accountIdxBuy := m.getFreeAccount(false)
        privateKeySetId, accountIdxSetId := m.getFreeAccount(false)
        defer m.freeThisAccount(accountIdxSell)

        if privateKeyBuy == nil || privateKeySell == nil || privateKeySetId == nil {
                log.Println("warn: sendTxTryBuyToken all account is busy now, can not send transaction")
                writeAuditLog("warn: can not get trade account, may be the flowing reason: \n" +
                        "1. all account is busy now, please add more account in ./data/config.toml and restart program.\n" +
                        "2. some account has insufficient balance, please transfer bnb to these account.")
                return
        }

        // 负责卖出账户的Id，同一时间该账户只能负责一笔交易，否则会发生覆写问题，十分严重。
        sellerAddress := m.getAddressAt(accountIdxSell)

        // 设置ID的交易，与ClipAntiSpamContract进行交互，privateKeySetId账户负责操作。
        // 注意要把本交易的gasPrice设置的比买入的gasPrice高一点儿。
        txOptsSetSellId, err := bind.NewKeyedTransactorWithChainID(privateKeySetId, m.chainId)
        if err != nil {
                log.Println("warn: sendTxTryBuyToken NewKeyedTransactorWithChainID error, txOptsSetSellId")
                log.Println("warn: ", err.Error())
                return
        }
        txOptsSetSellId.GasLimit = 220000
        txOptsSetSellId.GasPrice = new(big.Int)
        txOptsSetSellId.GasPrice.Add(buyGasPrice, bn1e6)

        // 卖出的交易，与ClipSellContract进行交互，privateKeySell账户负责操作。
        // 卖的交易无需设置gasPrice和用户的一样即可。
        sellAccountNonce, err := conChain[0].EthClient.PendingNonceAt(ctx, m.getAddressAt(accountIdxSell))
        if err != nil {
                log.Println("error: can not get sell account current nonce, ", m.getAddressAt(accountIdxSell))
                return
        }
        txOptsExecSell, err := bind.NewKeyedTransactorWithChainID(privateKeySell, m.chainId)
        if err != nil {
                log.Println("warn: sendTxTryBuyToken NewKeyedTransactorWithChainID error, txOptsExecSell")
                log.Println("warn: ", err.Error())
                return
        }
        txOptsExecSell.GasLimit = 220000
        txOptsExecSell.GasPrice = new(big.Int)
        txOptsExecSell.GasPrice.SetBytes(userTx.GasPrice().Bytes())
        txOptsExecSell.Nonce = big.NewInt(int64(sellAccountNonce))

        // 买入的交易，与ClipBuyContract进行交互，privateKeyBuy账户负责操作。
        // 注意设置gasPrice比用户的高，这里是buyGasPrice，因为涉及到成本计算，因此在本函数外设置。
        txOptsExecBuy, err := bind.NewKeyedTransactorWithChainID(privateKeyBuy, m.chainId)
        txOptsExecBuy.GasLimit = 220000
        txOptsExecBuy.GasPrice = buyGasPrice

        // 设置卖出的界限，用于判断是否在用户前面。
        minSellIn := new(big.Int)
        minSellIn.Div(amountIn, bn50)
        minSellIn.Add(maxReserveIn, minSellIn)
		tmpSellIn := new(big.Int)
		tmpSellIn.Div(amountIn, bn50)
		bn9e20 := new(big.Int)
        bn9e20.SetString("900000000000000000000", 10)
		tmpSellIn.Add(minReserveIn, tmpSellIn)
		tmpSellIn.Add(tmpSellIn, bn9e20)
		if minSellIn.Cmp(tmpSellIn) > 0 {
			minSellIn = tmpSellIn
		}

        // 为了卖交易更快的打包，并行的向所有provider节点发送请求。
        pairEnc, pairInt := new(big.Int), new(big.Int)
        pairInt.SetBytes(pair.Bytes())
        pairEnc.Xor(pairInt, encPairXor)
        sentSuccess, sellTx := m.sendSellToProviders(txOptsExecSell, pairEnc, tokenInId, minSellIn)

        // 如果向多个Provider发送卖出交易都失败了，肯定是发生了某种错误，直接返回，不要再买了。
        if sentSuccess == false || sellTx == nil {
                log.Println("error: sent sell transaction to all provider error,", sellTx, ", return, please check log")
                return
        }

        // 随机生成32字节长度的ID，并且按照AntiSpam中密钥异或负责卖出的账户地址。
        randRequestIdBytes := make([]byte, 256/8)
        _, err = rand.Read(randRequestIdBytes)
        if err != nil {
                log.Println("error: generate random uint256 error, return, please check log")
                return
        }
        randRequestIdInt := new(big.Int)
        randRequestIdInt.SetBytes(randRequestIdBytes)
        log.Println("log: generate random uint256: ", randRequestIdInt)

        // 使用requestId加密这些参数，第一行初始化的是big.int类型，第二行初始化的是address类型
        pairXorReqId, maxReserveInXorReqId, minReserveInXorReqId, amountInXorReqId :=
                new(big.Int), new(big.Int), new(big.Int), new(big.Int)
        sellerXorReqId, victimXorReqId := new(big.Int), new(big.Int)
        pairXorReqId.Xor(pairInt, randRequestIdInt)
        maxReserveInXorReqId.Xor(maxReserveIn, randRequestIdInt)
        minReserveInXorReqId.Xor(minReserveIn, randRequestIdInt)
        amountInXorReqId.Xor(amountIn, randRequestIdInt)

        sellerInt := new(big.Int)
        sellerInt.SetBytes(sellerAddress.Bytes())
        sellerXorReqId.Xor(sellerInt, randRequestIdInt)

        victimInt := new(big.Int)
        victimInt.SetBytes(userFrom.Bytes())
        victimXorReqId.Xor(victimInt, randRequestIdInt)

        // 接着发送买入交易，注意发送加密后的requestId。
        encRequestIdInt := new(big.Int)
        encRequestIdInt.Xor(randRequestIdInt, encReqIdXor)

        var buyTx *types.Transaction
        if tokenInId == 1 {
                buyTx, err = conChain[0].ClipBuyContract.TryBuyToken1WithCheck(txOptsExecBuy,
                        encRequestIdInt, pairXorReqId, maxReserveInXorReqId, minReserveInXorReqId,
                        sellerXorReqId, victimXorReqId, amountInXorReqId)
        } else {
                buyTx, err = conChain[0].ClipBuyContract.TryBuyToken0WithCheck(txOptsExecBuy,
                        encRequestIdInt, pairXorReqId, maxReserveInXorReqId, minReserveInXorReqId,
                        sellerXorReqId, victimXorReqId, amountInXorReqId)
        }

        if err != nil || buyTx == nil {
                log.Println("error: sent buy transaction failed, return, please check log, ", err)
                return
        }

        // 设置ID的交易、买的交易，都通过本地节点发送，先休眠一小会儿。
        addrSellIntEnc := new(big.Int)
        addrSellIntEnc.SetBytes(sellerAddress.Bytes())
        addrSellIntEnc.Xor(addrSellIntEnc, encSellAccountXor)
        time.Sleep(300 * time.Millisecond)
        setIdTx, err := conChain[0].ClipAntiSpamContract.UpdateRequestId(txOptsSetSellId, addrSellIntEnc, randRequestIdInt)
        if err != nil || setIdTx == nil {
                log.Println("error: sent set sell id transaction failed, return, please check log")
                return
        }

        // 经过上面的判断，下面三个都不为空
        log.Println("set id hash: ", setIdTx.Hash(), "operating account: ", m.getAddressAt(accountIdxSetId))
        log.Println("buy hash: ", buyTx.Hash(), "operating account: ", m.getAddressAt(accountIdxBuy))
        log.Println("sell hash: ", sellTx.Hash(), "operating account: ", m.getAddressAt(accountIdxSell))

        // 至此，从provider来看，三笔交易均发送成功。
        // 只需等待出块时间，确认三笔交易在链上的确认情况。
        time.Sleep(8 * time.Second)
        isBuyTxConfirmSuccess := false
        buyReceipt, err := conChain[0].EthClient.TransactionReceipt(ctx, buyTx.Hash())
        if err != nil {
                log.Println("warn: wait 8 seconds, still can not confirm buy transaction, ", err)
                // 接下来每隔2秒检查一次，最多检查3次，如果都没有则表明买入失败。
                for i := 0; i < 3; i++ {
                        time.Sleep(2 * time.Second)
                        buyReceipt, err = conChain[0].EthClient.TransactionReceipt(ctx, buyTx.Hash())
                        if err != nil {
                                break
                        }
                        log.Println("warn: retry to confirm buy transaction, ", i, "times, still error: ", err)
                }
                if err == nil && buyReceipt != nil && buyReceipt.Status == types.ReceiptStatusSuccessful {
                        isBuyTxConfirmSuccess = true
                }
        } else {
                isBuyTxConfirmSuccess = buyReceipt != nil && buyReceipt.Status == types.ReceiptStatusSuccessful
        }

        if isBuyTxConfirmSuccess == false {
                log.Println("error: buy transaction error, ", buyTx.Hash(), ", return, please check log")
                return
        }

        // 确认买入成功后，接着进一步确认卖出交易是否成功。因为上面已经等待了很长时间，这里不再等待，如果失败则直接发送一笔无限制卖出交易。
        isSellTxConfirmSuccess := false
        sellReceipt, err := conChain[0].EthClient.TransactionReceipt(ctx, sellTx.Hash())
        if err == nil && sellReceipt != nil && sellReceipt.Status == types.ReceiptStatusSuccessful {
                isSellTxConfirmSuccess = true
        }
        if isSellTxConfirmSuccess == false {
                var sellTxRetry *types.Transaction
                for i := 0; i < 3; i++ {
                        txOptsExecSellRetry, _ := bind.NewKeyedTransactorWithChainID(privateKeySell, m.chainId)
                        txOptsExecSellRetry.GasLimit = 220000
                        if tokenInId == 1 {
                                sellTxRetry, err = conChain[0].ClipSellContract.SellToken1(txOptsExecSellRetry, pair, sellerAddress)
                        } else {
                                sellTxRetry, err = conChain[0].ClipSellContract.SellToken0(txOptsExecSellRetry, pair, sellerAddress)
                        }
                        if err == nil && sellTxRetry != nil {
                                // 重试的卖出交易成功从provider发出，接下来还需要等待一段时间，在链上确认。
                                time.Sleep(6 * time.Second)
                                sellRetryReceipt, err := conChain[0].EthClient.TransactionReceipt(ctx, sellTxRetry.Hash())
                                if err == nil && sellRetryReceipt != nil && sellRetryReceipt.Status == types.ReceiptStatusSuccessful {
                                        log.Println("log: retry sell successful, hash: ", sellTxRetry.Hash())
                                        isSellTxConfirmSuccess = true
                                        break
                                }
                        }
                }
        }

        if isSellTxConfirmSuccess == false {
                msg := fmt.Sprint("error: buy transaction hash: ", buyTx.Hash(), " buy account: ", m.getAddressAt(accountIdxBuy),
                        " sell account: ", m.getAddressAt(accountIdxSell), " error: can not sell, please check it")
                log.Println(msg)
                writeAuditLog(msg)

        } else {
                log.Println("both buy and sell are success!")
        }

}

func createTradeAccounts(addresses []common.Address, privateKeys []*ecdsa.PrivateKey,
        blockNumber uint64, chainId uint64) *TradeAccounts {

        tradeAccounts := &TradeAccounts{}
        tradeAccounts.blockNumber = big.NewInt(int64(blockNumber))
        tradeAccounts.chainId = big.NewInt(int64(chainId))
        tradeAccounts.lock = new(sync.Mutex)

        n := len(addresses)
        for i := 0; i < n; i++ {
                tradeAccounts.insertAccount(addresses[i], privateKeys[i])
        }

        return tradeAccounts
}

type routerTxMethod struct {
        Tx     *types.Transaction
        From   *common.Address
        Method decoder.MethodData
}

func (m *routerTxMethod) getFrom() *common.Address {
        var fromAddress common.Address
        var err error
        fromAddress, err = types.Sender(types.NewEIP155Signer(m.Tx.ChainId()), m.Tx)
        if err != nil {
                fromAddress, err = types.Sender(types.HomesteadSigner{}, m.Tx)
        }
        m.From = &fromAddress
        return m.From
}

func createRouterTxMethod(tx *types.Transaction, method decoder.MethodData) routerTxMethod {
        return routerTxMethod{
                Tx:     tx,
                Method: method,
        }
}

func calculateRange(reserveIn *big.Int, reserveOut *big.Int, amountIn *big.Int, amountOut *big.Int,
        gasFee *big.Int) (*big.Int, *big.Int) {
        d := 1000000000000.0 //amountIn accuracy
        c := 0.9975          // fee rate
        rateIn := new(big.Int)
        rateOut := new(big.Int)
        BN10000 := big.NewInt(int64(d))
        limit := big.NewInt(398501300000000)
        rateIn.Mul(reserveIn, BN10000)
        rateIn.Div(rateIn, amountIn)
        if rateIn.Cmp(limit) > 0 {
                return nil, nil
        }
        rateOut.Mul(reserveOut, BN10000)
        rateOut.Div(rateOut, amountOut)
        //求用户能承受的上限
        rIn := float64(rateIn.Uint64())
        rOut := float64(rateOut.Uint64())
        sqt := math.Sqrt(c*(rIn*rOut) + math.Pow(d, 2)*math.Pow(c, 2)/4)
        rX := sqt - d*c/2
        maxReserveIn := big.NewInt(int64(rX))
        maxReserveIn.Mul(maxReserveIn, amountIn)
        maxReserveIn.Div(maxReserveIn, BN10000)
        //求极值
        a := rIn // reserveIn
        p1 := c * d * math.Sqrt((a*math.Pow(c, 4)-a*math.Pow(c, 3))*d+math.Pow(a, 2)*math.Pow(c, 4)-
                math.Pow(a, 2)*math.Pow(c, 3)+math.Pow(a, 2)*c)
        p2 := a*math.Pow(c, 2)*d + math.Pow(a, 2)*math.Pow(c, 2) - math.Pow(a, 2)
        p3 := (math.Pow(c, 3)-math.Pow(c, 2))*d - a*math.Pow(c, 2) + a
        x1 := (p2 - p1) / p3
        x2 := (p2 + p1) / p3
        x := math.Max(x1, x2)                                                              //amout we should Buy
        z := (math.Pow(c, 2)*x*(x+d+a)*(x+c*d+a))/(math.Pow(c, 2)*x*(x+c*d+a)+a*(x+a)) - x //reward

        amountX := big.NewInt(int64(x))
        amountX.Mul(amountX, amountIn)
        amountX.Div(amountX, BN10000)
        // 计算maxReserveIn
        tmp := new(big.Int)
        tmp.Add(amountX, reserveIn)
        if tmp.Cmp(maxReserveIn) < 0 {
                maxReserveIn.Set(tmp)
        }
        amountZ := big.NewInt(int64(z))
        amountZ.Mul(amountZ, amountIn)
        amountZ.Div(amountZ, BN10000)

        if amountZ.Cmp(gasFee) <= 0 {
                return nil, nil
        }

        // 近似计算获利时最小需买入的量
        // 近似计算获利时最小需买入的量
        r := d / a
        dy := 1 / (math.Pow(c, 3)*(r+math.Pow(r, 2)) + math.Pow(c, 2)*(1+r) - 1)
        minClipIn := big.NewInt(int64(dy * d))
        minClipIn.Mul(minClipIn, gasFee)
        minClipIn.Div(minClipIn, BN10000)

        tmp = new(big.Int)
        tmp.Add(reserveIn, minClipIn)
        if tmp.Cmp(maxReserveIn) >= 0 {
                return nil, nil
        }
        return minClipIn, maxReserveIn
}

func (m routerTxMethod) checkParaForSwapTokensFotTokens() bool {
        res := true
        if m.Method.Params[0].Type != "uint256" {
                log.Println("warn: swapExactTokensForTokens params[0] is not uint256, return")
                res = false
        }

        if m.Method.Params[1].Type != "uint256" {
                log.Println("warn: swapExactTokensForTokens params[1] is not uint256, return")
                res = false
        }

        if m.Method.Params[2].Type != "address[]" {
                log.Println("warn: swapExactTokensForTokens params[2] is not address[], return")
                res = false
        }

        if m.Method.Params[3].Type != "address" {
                log.Println("warn: swapExactTokensForTokens params[3] is not address, return")
                res = false
        }

        if m.Method.Params[4].Type != "uint256" {
                log.Println("warn: swapExactTokensForTokens params[4] is not uint256, return")
                res = false
        }
        return res
}

func (m routerTxMethod) swapTokensForTokens(client *ethclient.Client) {
        // 说明：swapTokensForTokens函数合并了下面两个函数
        // 1、swapExactTokensForTokens
        // 2、swapTokensForExactTokens

        if m.checkParaForSwapTokensFotTokens() == false {
                return
        }
        fromAddress := m.getFrom()
        amountIn, amountOut := new(big.Int), new(big.Int)

        if m.Method.Name == "swapExactTokensForTokens" {
                amountIn.SetString(m.Method.Params[0].Value, 10)
                amountOut.SetString(m.Method.Params[1].Value, 10)
        } else{
                amountOut.SetString(m.Method.Params[0].Value, 10)
                amountIn.SetString(m.Method.Params[1].Value, 10)
        }

        pathValueString := m.Method.Params[2].Value
        pathValueString = pathValueString[1 : len(m.Method.Params[2].Value)-1]
        splitPathValueString := strings.Fields(pathValueString)
        // 如果不是两种币交换的交易，就不做处理，此处之后可能做更新。
        if len(splitPathValueString) != 2 {
                return
        }
        path := make([]common.Address, 2)
        path[0] = common.HexToAddress(splitPathValueString[0])
        path[1] = common.HexToAddress(splitPathValueString[1])
        deadline := new(big.Int)
        deadline.SetString(m.Method.Params[4].Value, 10)

        // 查看是否是稳定币，如果不是稳定币，则不做操作。
        _, found := stableCoins[path[0]]
        if found == false {
                return
        }

        // 根据交易的币种在缓存中查找对应的pair，为了节省内存，默认token0的地址小于token1的地址。
        var token0, token1 common.Address
        firstBigger := bytes.Compare(path[0][:], path[1][:]) > 0
        if firstBigger {
                token0, token1 = path[1], path[0]
        } else {
                token0, token1 = path[0], path[1]
        }
        vmap, found := poolsCache[token0]
        if found == false {
                return
        }
        pairAddress, found := vmap[token1]
        if found == false {
                return
        }

        log.Println("log: hash ", m.Tx.Hash())

        // 获取交易池中两种币的剩余量，因为合约返回值是按照币地址排序的，地址小的在前面，因此需要对结果做一下交换。
        pairContract, err := contract.NewPairContract(pairAddress, client)
        if err != nil {
                log.Println("warn: swapExactTokensForTokens NewPairContract error, pair: ", pairAddress)
                return
        }
        callOpts := &bind.CallOpts{Pending: true}
        reserves, err := pairContract.GetReserves(callOpts)
        if err != nil {
                log.Println("warn: swapExactTokensForTokens getReserves error, pair: ", pairAddress)
                return
        }
        if firstBigger {
                reserves.Reserve0, reserves.Reserve1 = reserves.Reserve1, reserves.Reserve0
        }

        // 在swapExactTokensForTokens方法中，有些用户为了使自己的交易成功执行，会把amountOutMin设置成0， 这种情况需要做特殊处理。
        if amountOut.Cmp(bn0) == 0 {
                amountOut = big.NewInt(1)
        }

        // 接着是gas费策略部分，目前策略是设置成被抢跑交易的固定倍数，或者加上一个固定的值。
        // TODO: GasPrice机制修改为监控前4秒接收到的交易中，最大的gasPrice + 1e5。
        gasFee := new(big.Int)
        gasFee.SetString("200000", 10)
        gasPrice := new(big.Int)
        gasPrice.SetBytes(m.Tx.GasPrice().Bytes())
        gasPrice.Add(gasPrice, bn2e9)
        gasFee.Mul(gasFee, gasPrice)

        // 乘以2，因为一次设置ID，一次买入，接下来在SendTxTryBuyAndSellToken，要把设置ID交易的gas设的更高一点。
        gasFee.Mul(gasFee, bn2)

        // 获取bnb兑美元的价格，以计算gas费。
        wbnbPriceLock.Lock()
        gasFee.Mul(gasFee, wbnbPrice)
        wbnbPriceLock.Unlock()

        // 使用推导出的公式计算minClipIn与maxReserveIn。
        reserveIn, reserveOut := reserves.Reserve0, reserves.Reserve1
        minClipIn, maxReserveIn := calculateRange(reserveIn, reserveOut, amountIn, amountOut, gasFee)
        if minClipIn == nil || maxReserveIn == nil || gasPrice.Cmp(big.NewInt(9900000000)) > 0 {
                return
        }
        minClipIn.Add(reserveIn, bn10)

        var tokenInId int
        if firstBigger {
                tokenInId = 0
        } else {
                tokenInId = 1
        }

        log.Println("hash: ", m.Tx.Hash(), "amountIn: ", amountIn, "amountOut", amountOut,
                "log: decide buy&sell, gasPrice is ", gasPrice, " minClipIn: ", minClipIn,
                "maxReserveIn: ", maxReserveIn, "path: ", path[0], "path: ", path[1])

        // 等待交易确认是一件比较耗时的操作，需要启动一个Routine。
        go tradeHandler.SendTxTryBuyAndSellToken(tokenInId, amountIn, *fromAddress, pairAddress,
                maxReserveIn, minClipIn, gasPrice, m.Tx)
}

func makeDecisionRoutine(ipcClient *ethclient.Client, ch <-chan routerTxMethod) {
        for txMethod := range ch {
                txMethod.swapTokensForTokens(ipcClient)
        }
}

func filterTransactionRoutine(client *ethclient.Client,
        abiDecoder *decoder.ABIDecoder,
        chIn <-chan common.Hash,
        chOut chan<- routerTxMethod) {
        ctx := context.Background()
        for hash := range chIn {
                tx, isPending, err := client.TransactionByHash(ctx, hash)
                if err != nil {
                } else if isPending != true {
                        log.Println("warn: transaction has been confirmed, hash: ", hash)
                } else if tx.To() != nil && tx.To().String() == RouterAddressHex && len(tx.Data()) > 0 {
                        // 忽略GasPrice超过市场价格的交易，这些可能是诱饵交易。
                        if tx.GasPrice().Cmp(suggestGasPriceLimit) == 1 {
                                continue
                        }
                        // TODO: 此处还可以更快，这里为了快速开发，先把bytes十六进制编码成字符串，再由库 解码。接下来计划修改此处逻辑，直接在bytes上解码。
                        inputData := fmt.Sprintf("%x", tx.Data())
                        method, err := abiDecoder.DecodeMethod(inputData)
                        if err != nil {
                                log.Println("warn: filterTransactionRoutine abiDecoder.DecodeMethod error, hash: ", hash)
                        }
                        isIn, found := observeMethods[method.Name]
                        if isIn && found {
                                chOut <- createRouterTxMethod(tx, method)
                        }
                }
        }
}

func updateDataPeriodicRoutine(ipcClient *ethclient.Client, ctx context.Context) {
        // TODO: 该线程每隔一段时间同步新区块上的创建Pair的事件，检测新Pair是否合法（能够买入卖出），将其加入数据库。

        wbnb2usdPoolAddress := common.HexToAddress("0x58f876857a02d6762e0101bb5c46a8c1ed44dc16")
        pairContract, err := contract.NewPairContract(wbnb2usdPoolAddress, ipcClient)
        if err != nil {
                log.Println("warn: updateDataPeriodicRoutine NewPairContract error, pair: wbnb2usdPoolAddress ",
                        wbnb2usdPoolAddress)
                os.Exit(1)
        }

        wbnbPrice, suggestGasPrice = new(big.Int), new(big.Int)
        suggestGasPriceLimit = new(big.Int)
        callOpts := &bind.CallOpts{Pending: false}

        for {
                reserves, err := pairContract.GetReserves(callOpts)
                if err != nil {
                        log.Println("error: updateDataPeriodicRoutine getReserves error, pair: wbnb2usdPoolAddress",
                                wbnb2usdPoolAddress)
                        os.Exit(1)
                }
                // 通过wbnb兑换busd池子，大致算下wbnb的价格，以计算gas费用。
                wbnbReserve, busdReserve := reserves.Reserve0, reserves.Reserve1

                gasPrice, err := ipcClient.SuggestGasPrice(ctx)
                if err != nil {
                        log.Println("error: updateDataPeriodicRoutine SuggestGasPrice error")
                        os.Exit(1)
                }

                wbnbPriceLock.Lock()
                wbnbPrice.Div(busdReserve, wbnbReserve)
                suggestGasPrice.SetBytes(gasPrice.Bytes())
                suggestGasPriceLimit.SetBytes(gasPrice.Bytes())
                suggestGasPriceLimit.Div(suggestGasPriceLimit, bn10)
                suggestGasPriceLimit.Mul(suggestGasPriceLimit, bn11)
                log.Println("log: updateDataPeriodicRoutine get wbnb price: ", wbnbPrice)
                log.Println("log: updateDataPeriodicRoutine get gas price: ", suggestGasPrice)
                wbnbPriceLock.Unlock()

                // 每隔5分钟更新
                time.Sleep(5 * time.Minute)

                log.Println("log: updateDataPeriodicRoutine get all trade accounts' balance")
                tradeHandler.updateAllBalance()
                for i := 0; i < tradeHandler.count; i++ {
                        log.Println("log: ", tradeHandler.addresses[i], tradeHandler.balances[i])
                        if tradeHandler.balances[i].Cmp(bn1e16) != 1 {
                                msg := fmt.Sprint("warn: account ", tradeHandler.addresses[i], "balance lower than 0.01")
                                log.Println(msg)
                                writeAuditLog(msg)
                        }
                }

        }

}

func loadDbInMemory(pairsFile string) map[common.Address]map[common.Address]common.Address {
        f, e := os.Open(pairsFile)
        if e != nil {
                log.Println("error: open file error")
                log.Println("error: ", e.Error())
                os.Exit(1)
        }
        pairsCache := make(map[common.Address]map[common.Address]common.Address)
        bufScan := bufio.NewScanner(f)
        for {
                if !bufScan.Scan() {
                        break
                }
                line := bufScan.Text()
                strSet := strings.Fields(line)
                pairAddress := common.HexToAddress(strSet[0])
                token0Address := common.HexToAddress(strSet[1])
                token1Address := common.HexToAddress(strSet[2])
                if bytes.Compare(token0Address[:], token1Address[:]) > 0 {
                        token0Address, token1Address = token1Address, token0Address
                }

                if pairsCache[token0Address] == nil {
                        pairsCache[token0Address] = make(map[common.Address]common.Address)
                }
                pairsCache[token0Address][token1Address] = pairAddress
        }
        return pairsCache
}

func writeAuditLog(msg string) {
        auditFd, _ := os.OpenFile(AuditLogFile, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0644)
        _, err := auditFd.Write([]byte(msg))
        if err != nil {
                log.Println("error: message, ", msg)
                log.Println("error: can not write audit log into file, please check.")
                os.Exit(1)
        }
        err = auditFd.Close()
        if err != nil {
                log.Println("warn: can not close audit log into file, please check.")
        }
}

var (
        // some const big int, avoid invoke new every time enter functions.
        bn0    = big.NewInt(0)
        bn2    = big.NewInt(2)
        bn1e6  = big.NewInt(1000000)
        bn15e8 = big.NewInt(1500000000)
        bn10   = big.NewInt(10)
		bn50   = big.NewInt(50)
        bn11   = big.NewInt(11)
        bn1e16 = big.NewInt(10000000000000000)
		bn2e9 = big.NewInt(2891320000)

        cfgFile   string
        startProcess bool
        dbHandler *gorm.DB
        conChain  []*ChainConnection

        sellPair string
        sellAccount string

        observeMethods map[string]bool
        stableCoins    map[common.Address]bool
        poolsCache     map[common.Address]map[common.Address]common.Address
        tradeHandler   *TradeAccounts
        wbnbPrice      *big.Int
        wbnbPriceLock  sync.Mutex
        suggestGasPrice *big.Int
        suggestGasPriceLimit *big.Int

        RouterAddressHex string
        ClipBuyAddress   common.Address
        ClipSellAddress  common.Address
        ClipAntiSpamAddress common.Address
        AuditLogFile     string

        pendingTxHashCacheCapacity int
        routerAbiDecoder           *decoder.ABIDecoder
        encPairXor                 *big.Int
        encReqIdXor                *big.Int
        encSellAccountXor *big.Int
)

type ChainConnection struct {
        ProviderName         string
        ProviderUrl          string
        EthClient            *ethclient.Client
        ClipBuyContract      *contract.ClipContract
        ClipSellContract     *contract.ClipContract
        ClipAntiSpamContract *contract.AntiSpamContract

        // only ipc interface has those fields
        ipcClient  *rpc.Client
        GethClient *gethclient.Client
}

func createChainConnection(providerName, providerUrl string) *ChainConnection {
        var err error
        con := &ChainConnection{ProviderName: providerName, ProviderUrl: providerUrl}

        isIpcUri := strings.HasSuffix(providerUrl, ".ipc")

        ctx := context.Background()
        if isIpcUri == true {
                con.ipcClient, err = rpc.DialIPC(ctx, con.ProviderUrl)
                if err != nil {
                        log.Println("error: can not connect use rcp.DialIPC: ", con.ProviderName, con.ProviderUrl)
                        os.Exit(1)
                }

                con.GethClient = gethclient.New(con.ipcClient)
                _, err = con.GethClient.GetNodeInfo(ctx)
                if err != nil {
                        log.Println("error: can not get p2p node info from geth client")
                        os.Exit(1)
                }
        }

        con.EthClient, err = ethclient.Dial(con.ProviderUrl)
        if err != nil {
                log.Println("error: can not connect use ethclient.Dial: ", con.ProviderName, con.ProviderUrl)
                os.Exit(1)
        }

        con.ClipBuyContract, err = contract.NewClipContract(ClipBuyAddress, con.EthClient)
        if err != nil {
                log.Println("error: can not initialize clip buy contract: ", con.ProviderName, con.ProviderUrl, ClipBuyAddress)
        }
        con.ClipSellContract, err = contract.NewClipContract(ClipSellAddress, con.EthClient)
        if err != nil {
                log.Println("error: can not initialize clip sell contract: ", con.ProviderName, con.ProviderUrl, ClipSellAddress)
        }
        con.ClipAntiSpamContract, err = contract.NewAntiSpamContract(ClipAntiSpamAddress, con.EthClient)
        if err != nil {
                log.Println("error: can not initialize clip sell contract: ", con.ProviderName, con.ProviderUrl, ClipAntiSpamAddress)
        }

        return con
}

func loadConfig() {
        viper.SetConfigFile(cfgFile)
        err := viper.ReadInConfig()
        if err != nil {
                log.Println("error: read config.toml file failed, file path: ", cfgFile, "check if it exists.")
                log.Println("error: ", err.Error())
                os.Exit(1)
        }

        sCoinsInterface := viper.Get("stable_coins").([]interface{})
        stableCoins = make(map[common.Address]bool)
        for _, v := range sCoinsInterface {
                stableCoins[common.HexToAddress(fmt.Sprint(v))] = true
        }

        // load safe pairs into memory from file
        safePairsFile := viper.GetString("safe_pairs")
        poolsCache = loadDbInMemory(safePairsFile)
        log.Println("loaded pools data into memory")

        // open database
        dbDsn := viper.GetString("db_dsn")
        dbHandler, err = gorm.Open(mysql.Open(dbDsn), &gorm.Config{})
        if err != nil {
                log.Println("error: can not open database, dsn is: ", dbDsn)
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        log.Println("connected to db: ", dbHandler.Name())

        clipBuyAddressHex := viper.GetString("clip_buy_address")
        if clipBuyAddressHex == "" {
                log.Println("error: seems forget add `clip_buy_address` in ", cfgFile)
                os.Exit(1)
        }
        ClipBuyAddress = common.HexToAddress(clipBuyAddressHex)

        clipSellAddressHex := viper.GetString("clip_sell_address")
        if clipSellAddressHex == "" {
                log.Println("error: seems forget add `clip_sell_address` in ", cfgFile)
                os.Exit(1)
        }
        ClipSellAddress = common.HexToAddress(clipSellAddressHex)

        clipAntiSpamAddressHex := viper.GetString("clip_antispam_address")
        if clipAntiSpamAddressHex == "" {
                log.Println("error: seems forget add `clip_antispam_address` in ", cfgFile)
                os.Exit(1)
        }
        ClipAntiSpamAddress = common.HexToAddress(clipAntiSpamAddressHex)

        // open ipc client
        chainUrls := viper.Get("chain_urls").([]interface{})
        if len(chainUrls) == 0 {
                log.Println("error: can not connect to chain, please specify at least one provider.")
                os.Exit(1)
        }

        for _, chainUrl := range chainUrls {
                chainUrl := chainUrl.(map[string]interface{})
                providerName := fmt.Sprint(chainUrl["name"])
                providerUrl := fmt.Sprint(chainUrl["url"])
                conChain = append(conChain, createChainConnection(providerName, providerUrl))
        }

        ctx := context.Background()
        chainId, err := conChain[0].EthClient.ChainID(ctx)
        if err != nil {
                log.Println("error: can not get chain id.")
                os.Exit(1)
        }

        blockNumber, err := conChain[0].EthClient.BlockNumber(ctx)
        if err != nil {
                log.Println("warn: can not get block number")
        }
        log.Printf("connected, chainId: %v, blockNumber: %v\n", chainId, blockNumber)

        routerAbiString, err := ioutil.ReadFile("abi/router.abi")
        if err != nil {
                log.Println("error: can open router abi file")
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        routerAbiDecoder = decoder.NewABIDecoder()
        routerAbiDecoder.SetABI(fmt.Sprintf("%s", routerAbiString))

        RouterAddressHex = fmt.Sprint(viper.Get("router_address"))

        AuditLogFile = fmt.Sprint(viper.Get("audit_log_path"))

        // create trade object
        accounts := viper.Get("accounts").([]interface{})
        accountsArray := make([]common.Address, len(accounts))
        privateKeyArray := make([]*ecdsa.PrivateKey, len(accounts))
        for i, v := range accounts {
                t := v.(map[string]interface{})
                addressHex := fmt.Sprint(t["address"])
                privateKeyHex := fmt.Sprint(t["prikey"])
                privateKey, err := crypto.HexToECDSA(privateKeyHex)
                if err != nil {
                        log.Println("error: loadConfig crypto.HexToECDSA error.")
                        log.Println("error: ", err.Error())
                        os.Exit(1)
                }
                accountsArray[i] = common.HexToAddress(addressHex)
                privateKeyArray[i] = privateKey
        }

        if err != nil {
                log.Println("error: connect clip contract error")
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        tradeHandler = createTradeAccounts(accountsArray, privateKeyArray, blockNumber, chainId.Uint64())

        for i := 0; i < tradeHandler.getCount(); i++ {
                log.Println("address: ", tradeHandler.getAddressAt(i), " balance: ", tradeHandler.getBalanceAt(i))
        }

        observeMethods = make(map[string]bool)
        observeMethods["swapExactTokensForTokens"] = true
        observeMethods["swapTokensForExactTokens"] = true

        rand.Seed(time.Now().UnixNano())

        pendingTxHashCacheCapacity = viper.GetInt("pending_cache_length")
}

func sellByCmd(pair, account common.Address) {
        // 加载配置文件
        viper.SetConfigFile("./data/config.toml")
        err := viper.ReadInConfig()
        if err != nil {
                log.Println("error: read config.toml file failed, file path: ", "./data/config.toml", "check if it exists.")
                log.Println("error: ", err.Error())
                os.Exit(1)
        }

        // 加载provider的uri
        chainUrls := viper.Get("chain_urls").([]interface{})
        if len(chainUrls) == 0 {
                log.Println("error: can not connect to chain, please specify at least one provider.")
                os.Exit(1)
        }

        clipSellAddressHex := viper.GetString("clip_sell_address")
        if clipSellAddressHex == "" {
                log.Println("error: seems forget add `clip_sell_address` in ", cfgFile)
                os.Exit(1)
        }
        ClipSellAddress = common.HexToAddress(clipSellAddressHex)

        chainUrl := chainUrls[0].(map[string]interface{})
        providerName := fmt.Sprint(chainUrl["name"])
        providerUrl := fmt.Sprint(chainUrl["url"])
        con := createChainConnection(providerName, providerUrl)

        // 加载稳定币列表
        sCoinsInterface := viper.Get("stable_coins").([]interface{})
        stableCoins = make(map[common.Address]bool)
        for _, v := range sCoinsInterface {
                stableCoins[common.HexToAddress(fmt.Sprint(v))] = true
        }

        // 加载账户列表
        accounts := viper.Get("accounts").([]interface{})
        accountsArray := make([]common.Address, len(accounts))
        privateKeyArray := make([]*ecdsa.PrivateKey, len(accounts))
        for i, v := range accounts {
                t := v.(map[string]interface{})
                addressHex := fmt.Sprint(t["address"])
                privateKeyHex := fmt.Sprint(t["prikey"])
                privateKey, err := crypto.HexToECDSA(privateKeyHex)
                if err != nil {
                        log.Println("error: loadConfig crypto.HexToECDSA error.")
                        log.Println("error: ", err.Error())
                        os.Exit(1)
                }
                accountsArray[i] = common.HexToAddress(addressHex)
                privateKeyArray[i] = privateKey
        }

        pairContract, err := contract.NewPairContract(pair, con.EthClient)
        if err != nil {
                log.Println("error: can not init pair contract, address: ", pair)
                os.Exit(1)
        }

        callOpts := &bind.CallOpts{Pending: false}
        token0Address, err := pairContract.Token0(callOpts)
        if err != nil {
                log.Println("error: can get token0 address from pair contract")
                os.Exit(1)
        }
        token1Address, err := pairContract.Token1(callOpts)
        if err != nil {
                log.Println("error: can get token0 address from pair contract")
                os.Exit(1)
        }

        log.Println("log: token0 address, ", token0Address)
        log.Println("log: token1 address, ", token1Address)

        // 默认是卖掉其他币，换取稳定币。
        stableId := -1
        _, found := stableCoins[token0Address]
        if found {
                stableId = 0
        }
        _, found = stableCoins[token1Address]
        if found {
                stableId = 1
        }
        if stableId == -1 {
                log.Println("error: can not get stable coin from this pair, check pair address, ", pair)
                log.Println("error: token0 address, ", token0Address)
                log.Println("error: token1 address, ", token1Address)
                os.Exit(1)
        }

        // 寻找account对应的私钥
        var privateKeyAccount *ecdsa.PrivateKey
        for i := 0; i < len(accounts); i++ {
                if bytes.Compare(accountsArray[i].Bytes(), account.Bytes()) == 0 {
                        privateKeyAccount = privateKeyArray[i]
                }
        }
        if privateKeyAccount == nil {
                log.Println("error: can not get private key corresponding to account: ", account)
                os.Exit(1)
        }

        ctx := context.Background()
        chainId, err := con.EthClient.ChainID(ctx)
        if err != nil {
                log.Println("error: can not get chainId, ", err)
                os.Exit(1)
        }

        txOptsSell, err := bind.NewKeyedTransactorWithChainID(privateKeyAccount, chainId)
        if err != nil {
                log.Println("error: can not init transaction opts, ", err)
                os.Exit(1)
        }
        txOptsSell.GasLimit = 220000
        var sellTx *types.Transaction
        if stableId == 0 {
                sellTx, err = con.ClipSellContract.SellToken1(txOptsSell, pair, account)
        } else {
                sellTx, err = con.ClipSellContract.SellToken0(txOptsSell, pair, account)
        }
        if err == nil{
                log.Println("log: sell transaction hash: ", sellTx.Hash())
        } else {
                log.Println("error: send sell transaction error, ", err)
        }
}

var rootCmd = &cobra.Command{
        Use:   "bot [--config] [config file path]",
        Short: "A front-running bot target on binance chain",
        Long:  "A efficient and frontier high frequency trading program target on PancakeSwapV2",
        Run:   func(cmd *cobra.Command, args []string) {},
}

var sellCmd = &cobra.Command{
        Use: "sell [--pair] [pair address] [address of seller account]",
        Short: "Send sell transaction by hand",
        Long: "When program can not sell tokens, you can use this command line tool",
        Run: func(cmd *cobra.Command, args []string) {},
}

func init() {
        rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "./data/config.toml", "config file (default is ./data/config.toml)")
        rootCmd.PersistentFlags().BoolVar(&startProcess, "start", false, "start listen memory and this frontrun boot")

        rootCmd.AddCommand(sellCmd)
        sellCmd.PersistentFlags().StringVar(&sellPair, "pair", "", "pair address to sell")
        sellCmd.PersistentFlags().StringVar(&sellAccount, "account", "", "account address of seller")
}

func main() {
        if err := rootCmd.Execute(); err != nil {
                log.Println("parse command error: ", err)
                os.Exit(1)
        }

        if startProcess {
                loadConfig()

                encPairXor, encReqIdXor, encSellAccountXor = new(big.Int), new(big.Int), new(big.Int)
                encPairXor.SetString("504cd63913d45934dd1625591335e0035381eea49de9bc643da796981888e9fd", 16)
                encReqIdXor.SetString("102233a74a9e402c6d42a619a3dd7771413c68989e767e4a061d4bf55a6daa04", 16)
                encSellAccountXor.SetString("c1c9336cddd4e26cb666efebea70b1da03727298dd81f7de80ba9beba034ddcf", 16)

                ctx := context.Background()
                txHashCh := make(chan common.Hash, pendingTxHashCacheCapacity)
                _, err := conChain[0].GethClient.SubscribePendingTransactions(ctx, txHashCh)
                if err != nil {
                        log.Println("error: can not subscribe pending transaction")
                        os.Exit(1)
                }

                txMethodCh := make(chan routerTxMethod, pendingTxHashCacheCapacity)
                go updateDataPeriodicRoutine(conChain[0].EthClient, ctx)
                time.Sleep(500 * time.Millisecond)
                if wbnbPrice == nil {
                        log.Println("error: no wbnbPrice detected")
                        os.Exit(1)
                }

                go filterTransactionRoutine(conChain[0].EthClient, routerAbiDecoder, txHashCh, txMethodCh)
                go makeDecisionRoutine(conChain[0].EthClient, txMethodCh)

                // 让主线程在不占用CPU资源的情况下持续等待
                <-make(chan int)
        }

        if sellPair != "" && sellAccount != "" {
                validPara := true
                if strings.HasPrefix(sellPair, "0x") == false || len(sellPair) != 42{
                        log.Println("error: invalid sell pair address: ", sellPair)
                        validPara = false
                }

                if strings.HasPrefix(sellAccount, "0x") == false || len(sellAccount) != 42{
                        log.Println("error: invalid account address: ", sellAccount)
                        validPara = false
                }

                if validPara == false {
                        os.Exit(1)
                }

                sellPairAddress := common.HexToAddress(sellPair)
                sellAccountAddress := common.HexToAddress(sellAccount)
                sellByCmd(sellPairAddress, sellAccountAddress)
        }
        return
}