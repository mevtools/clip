const ethers = require("ethers");
const clipABI = require("../contracts/clip.abi");

const clipInterface = new ethers.utils.Interface(clipABI);
const fromAddress = "0xA2cA1241A01B2fE1A9B56765aC66C1a13F131314";
const clipAddress = "0x6A11823BfA6eda019512bAEEa7Fb25A6dE179715";

const pairAddress = "0x9a57a0B448bFad9B1858b2D5248907bB4bA0B213"
const data1 = clipInterface.encodeFunctionData("testHoneypot", [
    pairAddress,
    0,
    ethers.utils.parseEther("1"),
]);

(async () => {
  const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
  const response = await provider.send("debug_traceCall", [
    {
      "from": fromAddress,
      "to": clipAddress,
      "data": data1,
    },
    "latest",
  ]);
  console.log(response);
})();
