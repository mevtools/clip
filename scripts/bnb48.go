package cmd

import (
        "context"
        "github.com/bnb48club/puissant_sdk/bnb48.sdk"
        "github.com/ethereum/go-ethereum/accounts/abi"
        "github.com/ethereum/go-ethereum/accounts/abi/bind"
        "github.com/ethereum/go-ethereum/common"
        "github.com/ethereum/go-ethereum/core/types"
        "github.com/ethereum/go-ethereum/crypto"
        "github.com/mevtools/private_tx/contracts"
        "github.com/mevtools/private_tx/log"
        "github.com/spf13/cobra"
        "math/big"
        "os"
        "strings"
)

var mevCheckerAddrStr string

func init() {
        pritxCmd.Flags().StringVar(&mevCheckerAddrStr, "addr", "", "address of mev checker contract")
        rootCmd.AddCommand(pritxCmd)
}

var pritxCmd = &cobra.Command{
        Use:   "pritx",
        Short: "send private transaction to mev checker",
        Long:  "More specifically, invoke the inc epoch of mev checker",
        RunE: func(cmd *cobra.Command, args []string) error {
                log.Root().SetHandler(log.LvlFilterHandler(log.LvlInfo, log.StreamHandler(os.Stderr, log.TerminalFormat(true))))

                client, err := bnb48.Dial("https://rpc-bsc.48.club",
                        "https://puissant-bsc.48.club")
                if err != nil {
                        log.Crit("connect to bnb48 server failed", "reason", err)
                }

                gasPrice, err := client.SuggestGasPrice(context.Background())
                if err != nil {
                        log.Crit("get suggest gas price failed", "reason", err)
                }
                log.Info("got gas price", "price", gasPrice.String())

                mevChecker, _ := abi.JSON(strings.NewReader(contracts.MevCheckerContractMetaData.ABI))
                inputData, _ := mevChecker.Pack("addEpoch")
                if len(mevCheckerAddrStr) < 30 {
                        log.Crit("please give me address of mev checker contract")
                }
                mevCheckerAddr := common.HexToAddress(mevCheckerAddrStr)

                //#[[accounts]]
                //#address = '0x46e3702Fe8a5c5532e368D768418b3cacF1623eE'
                //#prikey = 'b1488e21537774941ac404ad721389dfab03ec90970c9753384fa347de97fdec'
                privateKey, err := crypto.HexToECDSA("690fdb2e54c573dc474a771951839ed111b21ecf17a299592cdaaa7c5d352c09")
                txOpt, err := bind.NewKeyedTransactorWithChainID(privateKey, big.NewInt(56))
                txOpt.GasLimit = 220000
                txOpt.GasPrice = gasPrice

                tx := types.NewTx(&types.LegacyTx{
                        Value:    big.NewInt(1),
                        GasPrice: txOpt.GasPrice,
                        Gas:      txOpt.GasLimit,
                        To:       &mevCheckerAddr,
                        //Data:     inputData,
                })
                log.Info("tx", "data", inputData)

                err = client.SendPrivateRawTransaction(context.Background(), tx)
                if err != nil {
                        log.Crit("send transaction failed", "reason", err)
                }
                return nil
        },
}