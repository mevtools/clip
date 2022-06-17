const ethers = require("ethers");
const clipABI = require("../contracts/clip.json");
const pairs = require("./transfer.json");
const Web3 = require('web3');
const web3 = new Web3('http://localhost:8545');
// const pancakeABI = require("../contracts/pancake.json");

const clipInterface = new ethers.utils.Interface(clipABI);
const fromAddress = "0xA2cA1241A01B2fE1A9B56765aC66C1a13F131314";
const clipAddress = "0x6A11823BfA6eda019512bAEEa7Fb25A6dE179715";
const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
// const poolContract = new ethers.Contract("0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73", pancakeABI, provider);

// const pairAddress = "0x9a57a0B448bFad9B1858b2D5248907bB4bA0B213";


const stableCoins = ["BUSD", "USDT", "USDC", "DAI", "TUSD"];

(async () => {
  const len = pairs.length;
  for(var i = 0; i < len; i++) {
    const pair = pairs[i];
    const pairAddress = pair["pair"];
    var outId = 0;
    if (pair["token0Symbol"] in stableCoins) {
        outId = 1;
    }
    const data = clipInterface.encodeFunctionData("testHoneypot", [
      pairAddress,
      0,
      ethers.utils.parseEther("1"),
    ]);
    // const response = await provider.send("debug_traceCall", [
    //     {
    //         "from": fromAddress,
    //         "to": clipAddress,
    //         "data": data,
    //     },
    //     "latest",
    // ]);
    // // console.log[response["failed"]];
    // if(response.failed) {
    //    console.log(i,"/" , len, " ", pairAddress);
    // }
    web3.currentProvider.send({
        method: "debug_traceTransaction",
        params: [ {
            "from": fromAddress,
            "to": clipAddress,
            "data": data,
        },
        "latest",],
        jsonrpc: "2.0",
        id: "2"
    }, function (err, result) {
        if(err == null && !result.failed) {
            console.log(i,"/" , len, " ", pairAddress);
        }
    });

  }
})();
