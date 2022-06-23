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
        "github.com/spf13/viper"
        "gorm.io/driver/mysql"
        "gorm.io/gorm"
        "io/ioutil"
        "log"
        "math"
        "math/big"
        "math/rand"
        "os"
        "strings"
        "sync"
        "sync/atomic"
        "time"
)

const RouterAddress = "0x10ED43C718714eb63d5aA57B78B54704E256024E"
const ClipAddress = "0x3742B417Af5D072dc94D4262aa2eA135fc56a98b"
const Dsn = "root:frontrun@tcp(127.0.0.1:3306)/frontrun?charset=utf8mb4&parseTime=True&loc=Local"

//const WatchAddress = "0x37cAc9486722E82EFD2B32530Be0193A87a3B5D4"

var observeMethods map[string]bool

type CacheAccounts struct {
        count        int
        ethClient    *ethclient.Client
        clipContract *ClipContract
        addresses    []common.Address
        privateKeys  []*ecdsa.PrivateKey
        nextNonce    []uint64
        balances     []*big.Int
        isBusy       []bool
        blockNumber  *big.Int
        chainId      *big.Int

        lock *sync.Mutex
}

func (m *CacheAccounts) insertAccount(address common.Address, privateKey *ecdsa.PrivateKey) {
        ctx := context.Background()
        balance, err := m.ethClient.BalanceAt(ctx, address, m.blockNumber)
        if err != nil {
                log.Println("error: can not get balance at: ", address)
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        nonce, err := m.ethClient.PendingNonceAt(ctx, address)
        if err != nil {
                log.Println("error: can not get next nonce at: ", address)
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        m.addresses = append(m.addresses, address)
        m.privateKeys = append(m.privateKeys, privateKey)
        m.balances = append(m.balances, balance)
        m.isBusy = append(m.isBusy, false)
        m.nextNonce = append(m.nextNonce, nonce)
        m.count += 1
}

func (m *CacheAccounts) updateAllBalance() {
        ctx := context.Background()
        for i := 0; i < m.count; i++ {
                balance, err := m.ethClient.BalanceAt(ctx, m.addresses[i], m.blockNumber)
                if err != nil {
                        log.Println("warn: can not get balance at: ", m.addresses[i])
                        log.Println("warn: ", err.Error())
                }
                m.balances[i] = balance
        }
}

func (m CacheAccounts) getCount() int {
        return m.count
}

func (m CacheAccounts) getAddressAt(idx int) common.Address {
        return m.addresses[idx]
}

func (m CacheAccounts) getBalanceAt(idx int) *big.Int {
        res := new(big.Int)
        res.SetBytes(m.balances[idx].Bytes())
        return res
}

func (m *CacheAccounts) getFreeAccount() (*ecdsa.PrivateKey, int) {
        m.lock.Lock()
        defer m.lock.Unlock()

        var res *ecdsa.PrivateKey
        var idx int
        res = nil

        cnt := 1

        idx = rand.Int() % m.count
        for {
                if m.isBusy[idx] == false {
                        m.isBusy[idx] = true
                        res = m.privateKeys[idx]
                        break
                }
                idx = rand.Int() % m.count
                cnt += 1

                // 尝试了m.count次，没有找到空闲的账户，则遍历循环，取第一个空闲的。
                if cnt > m.count/2 {
                        for i := 0; i < m.count; i++ {
                                if m.isBusy[idx] == false {
                                        m.isBusy[idx] = true
                                        res = m.privateKeys[idx]
                                        break
                                }
                        }
                        break
                }
        }

        return res, idx
}

func (m *CacheAccounts) freeThisAccount(idx int) {
        m.lock.Lock()
        m.isBusy[idx] = false
        m.lock.Unlock()
}

func (m *CacheAccounts) incNextNonce(idx int) {
        atomic.AddUint64(&m.nextNonce[idx], 1)
}

func (m *CacheAccounts) getNextNonce(idx int) uint64 {
        return atomic.LoadUint64(&m.nextNonce[idx])
}

func (m *CacheAccounts) SendTxTryBuyAndSellToken(tokenInId int, amountIn *big.Int, userFrom common.Address, pair common.Address,
        maxReserveIn *big.Int, minClipIn *big.Int, gasPrice *big.Int, userTxHash common.Hash) {

        // 该函数可能同时有多个Routine在执行，因此应该考虑数据同步的问题。

        // ctx := context.Background()

        // 随机获得一个空闲的账户，注意这里可能存在条件竞争，需要加锁。
        privateKey, accountIdx := m.getFreeAccount()
        defer m.freeThisAccount(accountIdx)
        if privateKey == nil {
                // TODO: 没有空闲账户，要将其写入日志。
                log.Println("warn: sendTxTryBuyToken all account is busy now, can not send transaction")
                return
        }
        txOptsWithSingerSell0, err := bind.NewKeyedTransactorWithChainID(privateKey, m.chainId)
		txOptsWithSingerSell1, err := bind.NewKeyedTransactorWithChainID(privateKey, m.chainId)
        txOptsWithSingerBuy, err := bind.NewKeyedTransactorWithChainID(privateKey, m.chainId)
        if err != nil {
                log.Println("warn: sendTxTryBuyToken NewKeyedTransactorWithChainID error")
                log.Println("warn: ", err.Error())
                return
        }

        // 以 nextNonce+1 先发一笔卖的交易，这是为了1、能卖在其他夹子前面，2、卖在买交易的后面
        var sellTx, buyTx *types.Transaction
        var sellErr, buyErr error
        nextNonce := m.getNextNonce(accountIdx) // 这个有没有链上交互？
		// tmpGasp1 := new(big.Int)
		tmpGasp0 := new(big.Int)
		// tmpGasp1.Div(gasPrice, bn13)
		tmpGasp0.Add(gasPrice, big.NewInt(int64(10000)))
		txOptsWithSingerSell0.GasPrice = tmpGasp0
        txOptsWithSingerSell0.Nonce = big.NewInt(int64(nextNonce + 1))
        txOptsWithSingerSell0.GasLimit = 220000
		txOptsWithSingerSell1.GasPrice = gasPrice
        txOptsWithSingerSell1.Nonce = big.NewInt(int64(nextNonce + 1))
        txOptsWithSingerSell1.GasLimit = 220000

        minSellIn := new(big.Int)
        minSellIn.Div(amountIn, bn10)
        // minSellIn.Mul(minSellIn, bn9)
        minSellIn.Add(maxReserveIn, minSellIn)

        // 以用户gas价格的1.2倍价格发出该交易，以nextNonce发买的交易
        txOptsWithSingerBuy.GasPrice = tmpGasp0
        txOptsWithSingerBuy.GasLimit = 220000
        txOptsWithSingerBuy.Nonce = big.NewInt(int64(nextNonce))
		tmpGasp2 := new(big.Int)
		tmpGasp2.Mul(gasPrice, big.NewInt(2))

        if tokenInId == 1 {
				buyTx, buyErr = m.clipContract.TryBuyToken1WithCheck(txOptsWithSingerBuy,
					pair, maxReserveIn, minClipIn, userFrom, amountIn)
				time.Sleep(1000 * time.Millisecond)
                sellTx, sellErr = m.clipContract.TrySellToken1(txOptsWithSingerSell1,
                        pair, bn10)
				// sellTx, sellErr = m.clipContract.TrySellToken1(txOptsWithSingerSell0,
				// 	pair, minSellIn)
                
				// time.Sleep(800 * time.Millisecond)
				// txOptsWithSingerBuy.GasPrice = tmpGasp2
				// buyTx, buyErr = m.clipContract.TryBuyToken1WithCheck(txOptsWithSingerBuy,
				// 	pair, maxReserveIn, minClipIn, userFrom, amountIn)

        } else {
				buyTx, buyErr = m.clipContract.TryBuyToken0WithCheck(txOptsWithSingerBuy,
					pair, maxReserveIn, minClipIn, userFrom, amountIn)
				time.Sleep(1000 * time.Millisecond)
				sellTx, sellErr = m.clipContract.TrySellToken0(txOptsWithSingerSell1,
                        pair, bn10)
				// sellTx, sellErr = m.clipContract.TrySellToken0(txOptsWithSingerSell0,
				// 	pair, minSellIn)
                
				// time.Sleep(800 * time.Millisecond)
				// txOptsWithSingerBuy.GasPrice = tmpGasp2
				// buyTx, buyErr = m.clipContract.TryBuyToken0WithCheck(txOptsWithSingerBuy,
				// 	pair, maxReserveIn, minClipIn, userFrom, amountIn)
        }

        var sellBuyErrCnt = 0
        if buyErr != nil {
                log.Println("error: sendTxTryBuyToken buy error")
                log.Println("error: buy, ", buyErr.Error())
                sellBuyErrCnt += 1
        }
        if sellErr != nil {
                log.Println("error: sendTxTryBuyToken sell error")
                log.Println("error: sell, ", sellErr.Error())
                sellBuyErrCnt += 1
        }
        for i := 2; i > sellBuyErrCnt; i-- {
                m.incNextNonce(accountIdx)
                m.incNextNonce(accountIdx)
        }
        if sellBuyErrCnt != 0 && buyErr != nil {
                return
        }

        txOptsWithSingerSell1.Nonce = nil
        if buyTx != nil {
			log.Println("buy hash: ", buyTx.Hash())
		} else {
			log.Println("buy hash: NULL")
		}
		if sellTx != nil {
			log.Println("sell hash: ", sellTx.Hash())
		} else {
			log.Println("sell hash: NULL")
		}

        // 等待3秒，接着查询卖出是否成功，上面trySellTimes中，只要有一次成功就算成功。
        // time.Sleep(6 * time.Second)
        // existsSucc := false
        // if sellTx != nil {
        //         sellReceipt, err := m.ethClient.TransactionReceipt(ctx, sellTx.Hash())
        //         existsSucc = err == nil && sellReceipt.Status == types.ReceiptStatusSuccessful
        // }

        // minSellInCp := new(big.Int)
        // minSellInCp.SetBytes(minSellIn.Bytes())

        // sellSucc := false
        // for tryCount := 0; tryCount < 0; tryCount++ {
        //         if existsSucc == false {
        //                 if tryCount == 0 {
        //                         // 如果第一次卖出没有成功，则检测买入是否成功，如果买入失败，卖出自然不能成功，因此可以跳过。
        //                         // 当然，这里的前提条件是，正常情况下5秒钟，交易一定会从pending状态转为确认状态。
        //                         var buyReceipt *types.Receipt
        //                         for tryCheckBuy := 0; tryCheckBuy < 3; tryCheckBuy++ {
        //                                 buyReceipt, err = m.ethClient.TransactionReceipt(ctx, buyTx.Hash())
        //                                 if err != nil {
        //                                         log.Println("warn: con not get buy token transaction receipt: ", err.Error(), "retry ...")
        //                                         time.Sleep(time.Second)
        //                                 } else {
        //                                         break
        //                                 }
        //                         }
        //                         // 如果连续三次检查买入，仍然失败，则认为买入没有成功。
        //                         if err != nil {
        //                                 log.Println("warn: try 3 times check buy token transaction, still not found.")
        //                                 return
        //                         }
        //                         if buyReceipt.Status != types.ReceiptStatusSuccessful {
        //                                 log.Println("warn: buy token transaction failed, status: ", buyReceipt.Status)
        //                                 return
        //                         }

        //                         // 起初的数次交易都没有成功，此时查看被夹交易是否已经上链。如果已经上链，直接设置minSellIn为零卖出，否则每次乘以95%卖出。
        //                         userTxReceipt, err := m.ethClient.TransactionReceipt(ctx, userTxHash)
        //                         if err != nil {
        //                                 log.Println("warn: get user transaction's receipt error")
        //                         }
        //                         if userTxReceipt.Status == types.ReceiptStatusSuccessful {
        //                                 minSellInCp.SetUint64(0)
        //                         }

        //                 } else {
        //                         minSellInCp.Div(minSellIn, bn100)
        //                         minSellInCp.Mul(minSellInCp, bn95)
        //                 }

        //                 log.Println("warn: get sell transaction receipt error, retry use lower minSellIn: ", minSellIn)
        //                 if tokenInId == 1 {
        //                         sellTx, err = m.clipContract.TrySellToken1(txOptsWithSingerSell1, pair, minSellInCp)
        //                 } else {
        //                         sellTx, err = m.clipContract.TrySellToken0(txOptsWithSingerSell1, pair, minSellInCp)
        //                 }
        //                 m.incNextNonce(accountIdx)
        //         } else {
        //                 sellSucc = true
        //                 break
        //         }

        //         // 等待3秒，再查询一次。
        //         time.Sleep(3 * time.Second)
        //         sellReceipt, err := m.ethClient.TransactionReceipt(ctx, sellTx.Hash())
        //         existsSucc = err == nil && sellReceipt.Status == types.ReceiptStatusSuccessful
        // }
        // if sellSucc == false {
        //         // TODO: 数次卖出都没有成功，交由手动处理，写入关键日志文件。
        //         log.Println("buy transaction hash: ", buyTx.Hash(), "operation account: ", accountIdx,
        //                 "error: can not sell, please check it")
        //         os.Exit(1)
        // }
        // log.Println("sell success, buy tx hash: ", buyTx.Hash(), "sell tx hash: ", sellTx.Hash(),
        //         "operation account: ", m.getAddressAt(accountIdx))
}

func createCacheAccounts(addresses []common.Address, privateKeys []*ecdsa.PrivateKey,
        client *ethclient.Client, clipContract *ClipContract, blockNumber uint64, chainId uint64) *CacheAccounts {
        cacheAccounts := &CacheAccounts{}
        cacheAccounts.ethClient = client
        cacheAccounts.blockNumber = big.NewInt(int64(blockNumber))
        cacheAccounts.clipContract = clipContract
        cacheAccounts.chainId = big.NewInt(int64(chainId))
        cacheAccounts.lock = new(sync.Mutex)

        n := len(addresses)
        for i := 0; i < n; i++ {
                cacheAccounts.insertAccount(addresses[i], privateKeys[i])
        }

        return cacheAccounts
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

func calculateRange(reserveIn *big.Int, reserveOut *big.Int, amountIn *big.Int, amountOut *big.Int, gasFee *big.Int) (*big.Int, *big.Int) {
        // TODO：这里边的常量提到函数外边，避免每次初始化常量。
        d := 1000000000000.0 //amountIn accuracy
        c := 0.9975          // fee rate
        rateIn := new(big.Int)
        rateOut := new(big.Int)
        BN10000 := big.NewInt(int64(d))
        limit := big.NewInt(398501316249847) // 398.50131624984755
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
        p1 := c * d * math.Sqrt((a*math.Pow(c, 4)-a*math.Pow(c, 3))*d+math.Pow(a, 2)*math.Pow(c, 4)-math.Pow(a, 2)*math.Pow(c, 3)+math.Pow(a, 2)*c)
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

        // fmt.Print(int64(rX), " ", amountX.String(), "  ", amountZ.String(), "  ", 1/dy, " ", minClipIn.String(), " ",  maxReserveIn.String(), "\n")

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

func (m routerTxMethod) swapExactTokensForTokens(ipcClient *ethclient.Client) {
        // TODO：考虑被夹交易的gas费
        //isAddversal := false
        fromAddress := m.getFrom()
        //if fromAddress.Hex() == WatchAddress {
        //      log.Println("Found!!!!")
        //      isAddversal = true
        //}

        if m.checkParaForSwapTokensFotTokens() == false {
                return
        }

        amountIn, amountOutMin := new(big.Int), new(big.Int)
        amountIn.SetString(m.Method.Params[0].Value, 10)
        amountOutMin.SetString(m.Method.Params[1].Value, 10)

        pathValueString := m.Method.Params[2].Value
        pathValueString = pathValueString[1 : len(m.Method.Params[2].Value)-1]
        splitPathValueString := strings.Fields(pathValueString)
        if len(splitPathValueString) != 2 {
                return
        }
        path := make([]common.Address, 2)
        path[0] = common.HexToAddress(splitPathValueString[0])
        path[1] = common.HexToAddress(splitPathValueString[1])
        deadline := new(big.Int)
        deadline.SetString(m.Method.Params[4].Value, 10)

        _, found := stableCoins[path[0]]
        if found == false {
                return
        }

        firstBigger := bytes.Compare(path[0][:], path[1][:]) > 0
        var token0, token1 common.Address
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

        pairContract, err := NewPairContract(pairAddress, ipcClient)
        if err != nil {
                log.Println("warn: swapExactTokensForTokens NewPairContract error, pair: ", pairAddress)
                return
        }
        callOpts := &bind.CallOpts{Pending: false}
        reserves, err := pairContract.GetReserves(callOpts)
        if err != nil {
                log.Println("warn: swapExactTokensForTokens getReserves error, pair: ", pairAddress)
                return
        }
        if firstBigger {
                reserves.Reserve1, reserves.Reserve0 = reserves.Reserve0, reserves.Reserve1
        }

        ZERO := big.NewInt(0)
        var amountOut *big.Int
        if amountOutMin.Cmp(ZERO) == 0 {
                amountOut = big.NewInt(1)
        } else {
                amountOut = new(big.Int)
                amountOut.SetBytes(amountOutMin.Bytes())
        }

        log.Println("hash: ", m.Tx.Hash(), "amountIn: ", amountIn, "amountOutMin", amountOutMin,
                "tokenIn_Reserve: ", reserves.Reserve0, "tokenOut_Reserve: ", reserves.Reserve1)

        //if isAddversal == false {
        //      return
        //}

        // 发交易用的gas设置成用户gasPrice的1.3倍
        gasFee := new(big.Int)
        gasFee.SetString("220000", 10)
        gasPrice := new(big.Int)
        gasPrice.SetBytes(m.Tx.GasPrice().Bytes())
        gasPrice.Div(gasPrice, bn10)
        gasPrice.Mul(gasPrice, bn13)
        gasFee.Mul(gasFee, gasPrice)

        wbnbPriceLock.Lock()
        gasFee.Mul(gasFee, wbnbPrice)
        wbnbPriceLock.Unlock()

        reserveIn, reserveOut := reserves.Reserve0, reserves.Reserve1
        minClipIn, maxReserveIn := calculateRange(reserveIn, reserveOut, amountIn, amountOut, gasFee)
        if minClipIn == nil || maxReserveIn == nil || gasPrice.Cmp(big.NewInt(6000000000)) > 0{
                return
        }

        log.Println("hash: ", m.Tx.Hash(), "amountIn: ", amountIn, "amountOutMin", amountOutMin,
                "log: decide buy&sell, gasPrice is ", gasPrice, " minClipIn: ", minClipIn,
                "maxReserveIn: ", maxReserveIn, "path: ", path[0], "path: ", path[1])

        var tokenInId int
        if firstBigger {
                tokenInId = 0
        } else {
                tokenInId = 1
        }

        // minClipIn.Sub(maxReserveIn, reserveIn)
        minClipIn.Add(reserveIn, bn10)

        // 等待交易确认是一件比较耗时的操作，需要启动一个Routine。
        go accountsCache.SendTxTryBuyAndSellToken(tokenInId, amountIn, *fromAddress, pairAddress,
                maxReserveIn, minClipIn, gasPrice, m.Tx.Hash())
}

func (m routerTxMethod) swapTokensForExactTokens(ipcClient *ethclient.Client) {
        //fromAddress := m.getFrom()
        //log.Println("From: ", fromAddress)

        if m.checkParaForSwapTokensFotTokens() == false {
                return
        }

        amountInMax, amountOut := new(big.Int), new(big.Int)
        amountOut.SetString(m.Method.Params[0].Value, 10)
        amountInMax.SetString(m.Method.Params[1].Value, 10)

        pathValueString := m.Method.Params[2].Value
        pathValueString = pathValueString[1 : len(m.Method.Params[2].Value)-1]
        splitPathValueString := strings.Fields(pathValueString)
        if len(splitPathValueString) != 2 {
                return
        }
        path := make([]common.Address, 2)
        path[0] = common.HexToAddress(splitPathValueString[0])
        path[1] = common.HexToAddress(splitPathValueString[1])
        deadline := new(big.Int)
        deadline.SetString(m.Method.Params[4].Value, 10)

        _, found := stableCoins[path[0]]
        if found == false {
                return
        }

        firstBigger := bytes.Compare(path[0][:], path[1][:]) > 0
        var token0, token1 common.Address
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

        pairContract, err := NewPairContract(pairAddress, ipcClient)
        if err != nil {
                log.Println("warn: swapTokensForExactTokens NewPairContract error, pair: ", pairAddress)
                return
        }
        callOpts := &bind.CallOpts{Pending: false}
        reserves, err := pairContract.GetReserves(callOpts)
        if err != nil {
                log.Println("warn: swapTokensForExactTokens getReserves error, pair: ", pairAddress)
                return
        }
        if firstBigger {
                reserves.Reserve1, reserves.Reserve0 = reserves.Reserve0, reserves.Reserve1
        }

        fromAddress := m.getFrom()

        log.Println("hash: ", m.Tx.Hash(), "from: ", fromAddress, "amountInMax: ", amountInMax, "amountOut", amountOut,
                "token0: ", reserves.Reserve0, "token1: ", reserves.Reserve1)

        //if fromAddress.Hex() != WatchAddress {
        //      return
        //}

        //log.Println("Found!!!!!!!!!!!!!")

        // 发交易用的gas设置成用户gasPrice的1.3倍, TODO: 跟上面的重复代码合并下
        gasFee := new(big.Int)
        gasFee.SetString("220000", 10)
        gasPrice := new(big.Int)
        gasPrice.SetBytes(m.Tx.GasPrice().Bytes())
        gasPrice.Div(gasPrice, bn10)
        gasPrice.Mul(gasPrice, bn13)
        gasFee.Mul(gasFee, gasPrice)

        wbnbPriceLock.Lock()
        gasFee.Mul(gasFee, wbnbPrice)
        wbnbPriceLock.Unlock()

        amountIn := new(big.Int)
        amountIn.SetBytes(amountInMax.Bytes())
        reserveIn, reserveOut := reserves.Reserve0, reserves.Reserve1
        minClipIn, maxReserveIn := calculateRange(reserveIn, reserveOut, amountIn, amountOut, gasFee)

        if minClipIn == nil || maxReserveIn == nil || gasPrice.Cmp(big.NewInt(6500000000)) > 0 {
                return
        }

        log.Println("hash: ", m.Tx.Hash(), "amountInMax: ", amountInMax, "amountOut", amountOut,
                "log: decide buy&sell, gasPrice is ", gasPrice, "fromAddress: ", fromAddress, " minClipIn: ", minClipIn,
                "maxReserveIn: ", maxReserveIn, "path: ", path[0], "path: ", path[1])

        var tokenInId int
        if firstBigger {
                tokenInId = 0
        } else {
                tokenInId = 1
        }

        //minClipIn.Sub(maxReserveIn, reserveIn)
        minClipIn.Add(reserveIn, bn10)

        // 等待交易确认是一件比较耗时的操作，需要启动一个Routine。
        go accountsCache.SendTxTryBuyAndSellToken(tokenInId, amountIn, *fromAddress, pairAddress,
                maxReserveIn, minClipIn, gasPrice, m.Tx.Hash())

}

func makeDecisionRoutine(ipcClient *ethclient.Client, ch <-chan routerTxMethod) {
        for txMethod := range ch {
                switch txMethod.Method.Name {
                case "swapExactTokensForTokens":
                        txMethod.swapExactTokensForTokens(ipcClient)
                case "swapTokensForExactTokens":
                        txMethod.swapTokensForExactTokens(ipcClient)
                }
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
                } else if tx.To() != nil && tx.To().String() == RouterAddress {
                        //var fromAddress common.Address
                        //var err error
                        //fromAddress, err = types.Sender(types.NewEIP155Signer(tx.ChainId()), tx)
                        //if err != nil {
                        //      fromAddress, err = types.Sender(types.HomesteadSigner{}, tx)
                        //}
                        // TODO: 此处还可以更快，这里为了快速开发，先把bytes十六进制编码成字符串，再由库解码。接下来计划修改此处逻辑，直接在bytes上解码。
                        inputData := fmt.Sprintf("%x", tx.Data())
                        method, err := abiDecoder.DecodeMethod(inputData) // TODO：这里可能有问题
                        if err != nil {
                                log.Println("warn: filterTransactionRoutine abiDecoder.DecodeMethod error, hash: ", hash)
                        }
                        isIn, found := observeMethods[method.Name]

                        //if fromAddress.Hex() == WatchAddress {
                        //      log.Println("Found!!!!: ", tx.Hash(), "IsIn: ", isIn)
                        //}

                        if isIn && found {
                                chOut <- createRouterTxMethod(tx, method)
                        }
                }
        }
}

func updateDataPeriodicRoutine(ipcClient *ethclient.Client) {
        // TODO: 该线程每隔一段时间同步新区块上的创建Pair的事件，检测新Pair是否合法（能够买入卖出），将其加入数据库。
        // TODO：定期的检查交易账户的BNB余额，如果低于0.2，则提示用户充钱。检查合约稳定币账户余额。

        wbnb2usdPoolAddress := common.HexToAddress("0x58f876857a02d6762e0101bb5c46a8c1ed44dc16")
        pairContract, err := NewPairContract(wbnb2usdPoolAddress, ipcClient)
        if err != nil {
                log.Println("warn: updateDataPeriodicRoutine NewPairContract error, pair: wbnb2usdPoolAddress ",
                        wbnb2usdPoolAddress)
                os.Exit(1)
        }

        wbnbPrice = new(big.Int)
        callOpts := &bind.CallOpts{Pending: false}

        for {
                reserves, err := pairContract.GetReserves(callOpts)
                if err != nil {
                        log.Println("warn: updateDataPeriodicRoutine getReserves error, pair: wbnb2usdPoolAddress",
                                wbnb2usdPoolAddress)
                        os.Exit(1)
                }
                // 通过wbnb兑换busd池子，大致算下wbnb的价格，以计算gas费用。
                wbnbReserve, busdReserve := reserves.Reserve0, reserves.Reserve1

                wbnbPriceLock.Lock()
                wbnbPrice.Div(busdReserve, wbnbReserve)
                log.Println("log: updateDataPeriodicRoutine get wbnb price: ", wbnbPrice)
                wbnbPriceLock.Unlock()

                // 每隔5分钟更新
                time.Sleep(5 * time.Minute)

                log.Println("log: updateDataPeriodicRoutine get all trade accounts' balance")
                accountsCache.updateAllBalance()
                for i := 0; i < accountsCache.count; i++ {
                        log.Println("log: ", accountsCache.addresses[i], accountsCache.balances[i])
                }
        }

}

func loadDbInMemory() map[common.Address]map[common.Address]common.Address {
        f, e := os.Open("./data/safepair.txt")
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

func loadConfig(client *ethclient.Client, blockNumber uint64, chainId uint64) {
        viper.SetConfigFile("./data/config.toml")
        err := viper.ReadInConfig()
        if err != nil {
                log.Println("error: read config.toml file failed.")
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        sCoinsInterface := viper.Get("stable_coins").([]interface{})
        stableCoins = make(map[common.Address]bool)
        for _, v := range sCoinsInterface {
                stableCoins[common.HexToAddress(fmt.Sprint(v))] = true
        }

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

        clipContract, err := NewClipContract(common.HexToAddress(ClipAddress), client)
        if err != nil {
                log.Println("error: connect clip contract error")
                log.Println("error: ", err.Error())
                os.Exit(1)
        }

        accountsCache = createCacheAccounts(accountsArray, privateKeyArray, client, clipContract, blockNumber, chainId)
}

var poolsCache map[common.Address]map[common.Address]common.Address
var stableCoins map[common.Address]bool
var accountsCache *CacheAccounts

var wbnbPrice *big.Int
var wbnbPriceLock sync.Mutex

var bn10, bn9, bn100, bn95, bn13 *big.Int

func main() {
        db, err := gorm.Open(mysql.Open(Dsn), &gorm.Config{})
        if err != nil {
                log.Println("error: can not open database")
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        log.Println("connected to db: ", db.Name())

        poolsCache = loadDbInMemory()
        log.Println("loaded pools data into memory")

        const ipcUri = "/data/bsc/geth.ipc"
        ctx := context.Background()
        rpcClient, err := rpc.DialIPC(ctx, ipcUri)
        if err != nil {
                log.Println("error: can not connect to geth'ipc use rcp.DialIPC: ", ipcUri)
                os.Exit(1)
        }
        ipcClient, err := ethclient.Dial(ipcUri)
        if err != nil {
                log.Println("error: can not connect to geth'ipc use ethclient.Dial: ", ipcUri)
                os.Exit(1)
        }

        chainId, err := ipcClient.ChainID(ctx)
        if err != nil {
                log.Println("error: can not get chain id.")
                os.Exit(1)
        }
        blockNumber, err := ipcClient.BlockNumber(ctx)
        if err != nil {
                log.Println("warn: can not get block number")
        }
        log.Printf("connected, chainId: %v, blockNumber: %v\n", chainId, blockNumber)

        gethClient := gethclient.New(rpcClient)
        _, err = gethClient.GetNodeInfo(ctx)
        if err != nil {
                log.Println("error: can not get p2p node info from geth client")
                os.Exit(1)
        }

        routerAbiString, err := ioutil.ReadFile("abi/router.abi")
        if err != nil {
                log.Println("error: can open router abi file")
                log.Println("error: ", err.Error())
                os.Exit(1)
        }
        routerAbiDecoder := decoder.NewABIDecoder()
        routerAbiDecoder.SetABI(fmt.Sprintf("%s", routerAbiString))

        loadConfig(ipcClient, blockNumber, chainId.Uint64())
        for i := 0; i < accountsCache.getCount(); i++ {
                log.Println("address: ", accountsCache.getAddressAt(i), " balance: ", accountsCache.getBalanceAt(i),
                        "next nonce: ", accountsCache.getNextNonce(i))
        }

        observeMethods = make(map[string]bool)
        observeMethods["swapExactTokensForTokens"] = true
        observeMethods["swapTokensForExactTokens"] = true

        rand.Seed(time.Now().UnixNano())

        pendingTxHashCacheCapacity := 1024
        txHashCh := make(chan common.Hash, pendingTxHashCacheCapacity)
        // defer close(txHashCh)
        _, err = gethClient.SubscribePendingTransactions(ctx, txHashCh)
        if err != nil {
                log.Println("error: can not subscribe pending transaction")
                os.Exit(1)
        }

        txMethodCh := make(chan routerTxMethod, pendingTxHashCacheCapacity)

        bn10 = big.NewInt(10)
        bn9 = big.NewInt(9)
        bn13 = big.NewInt(10)
        bn100 = big.NewInt(100)
        bn95 = big.NewInt(95)

        go updateDataPeriodicRoutine(ipcClient)
        time.Sleep(500 * time.Millisecond)
        if wbnbPrice == nil {
                log.Println("error: no wbnbPrice detected")
                os.Exit(1)
        }

        go filterTransactionRoutine(ipcClient, routerAbiDecoder, txHashCh, txMethodCh)
        go makeDecisionRoutine(ipcClient, txMethodCh)

        // 让主线程在不占用CPU资源的情况下持续等待
        <-make(chan int)

        return
}
