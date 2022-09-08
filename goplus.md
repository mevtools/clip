必须满足：

```json
{
    "buy_tax": "0",
    "can_take_back_ownership": "0",
    "cannot_buy": "0",
    "is_anti_whale": "0",
    "is_blacklisted": "0",
    "is_honeypot": "0",
    "is_open_source": "1",
    "is_whitelisted": "0",
    "sell_tax": "0",
    "transfer_pausable": "0",
    "trading_cooldown": "0",
}
```

Example:

```json
{
    "code": 1,
    "message": "OK",
    "result": {
        "0xf29ac0cc7611155595c40890c3b6b3fbf85b5f1c": {
            "buy_tax": "0",
            "can_take_back_ownership": "0",
            "cannot_buy": "0",
            "creator_address": "0xb9aafe776d70b432b53f7ce0f3aa5d194c6b6005",
            "creator_balance": "393139280.249366095677970556",
            "creator_percent": "0.393139",
            "dex": [
                {
                    "name": "PancakeV2",
                    "liquidity": "28.67292092",
                    "pair": "0xc2d94E0F00B3deCB22DC98962B7274a2F05f2DED"
                },
                {
                    "name": "PancakeV2",
                    "liquidity": "0.03186784",
                    "pair": "0x76F342Cb651b44CdB6E6A4350B5BF63a346350Ac"
                }
            ],
            "external_call": "0",
            "hidden_owner": "1",
            "holder_count": "402",
            "holders": [
                {
                    "address": "0x1a1d6e38c2bf676c19e6dfc9a02a3e27b8f4c946",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "479666347.202",
                    "percent": "0.479666344803668275",
                    "is_locked": 0
                },
                {
                    "address": "0xb9aafe776d70b432b53f7ce0f3aa5d194c6b6005",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "393139280.24937",
                    "percent": "0.393139278283673608",
                    "is_locked": 0
                },
                {
                    "address": "0x1a705bf5a327bad29bca0ca8002039bdea9c06dc",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "35344902.084231",
                    "percent": "0.035344901907506490",
                    "is_locked": 0
                },
                {
                    "address": "0x59d7d59577def4fa5199877821d31b6107649397",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "31757025.680572",
                    "percent": "0.031757025521786872",
                    "is_locked": 0
                },
                {
                    "address": "0x357d5edf29adfa6937933bd99e4ed12b676098db",
                    "tag": "",
                    "is_contract": 1,
                    "balance": "14051538.126683",
                    "percent": "0.014051538056425309",
                    "is_locked": 0
                },
                {
                    "address": "0x904edb6f206e2fafaf4183fb4117320752a398e4",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "7498370.5009874",
                    "percent": "0.007498370463495547",
                    "is_locked": 0
                },
                {
                    "address": "0x5eb80dbdaa76fac25615575af2afc77313788307",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "3250120.280366",
                    "percent": "0.003250120264115398",
                    "is_locked": 0
                },
                {
                    "address": "0x4a054c66fbeb4b2ca40036db0ee383c34a89473f",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "2424656.4177604",
                    "percent": "0.002424656405637117",
                    "is_locked": 0
                },
                {
                    "address": "0xa2930602482351fc6ff19ae49dc6527f933a8810",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "1904936.4214282",
                    "percent": "0.001904936411903517",
                    "is_locked": 0
                },
                {
                    "address": "0x47cca9666d547558cb79777fc18abe42bacdbb77",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "1641713.425759",
                    "percent": "0.001641713417550432",
                    "is_locked": 0
                }
            ],
            "is_anti_whale": "0",
            "is_blacklisted": "1",
            "is_honeypot": "0",
            "is_in_dex": "1",
            "is_mintable": "0",
            "is_open_source": "1",
            "is_proxy": "0",
            "is_whitelisted": "1",
            "lp_holder_count": "2",
            "lp_holders": [
                {
                    "address": "0x0ed943ce24baebf257488771759f9bf482c39706",
                    "tag": "",
                    "is_contract": 1,
                    "balance": "2019.8428206881",
                    "percent": "1.000000000000022463",
                    "is_locked": 0
                },
                {
                    "address": "0x0000000000000000000000000000000000000000",
                    "tag": "",
                    "is_contract": 0,
                    "balance": "0.000000000000001000",
                    "percent": "0.000000000000000000",
                    "is_locked": 1
                }
            ],
            "lp_total_supply": "2019.842820688054627331",
            "owner_address": "0xb9aafe776d70b432b53f7ce0f3aa5d194c6b6005",
            "owner_balance": "393139280.249366095677970556",
            "owner_change_balance": "0",
            "owner_percent": "0.393139",
            "personal_slippage_modifiable": "0",
            "selfdestruct": "0",
            "sell_tax": "1",
            "slippage_modifiable": "0",
            "total_supply": "1000000005.000000000000000000",
            "trading_cooldown": "0",
            "transfer_pausable": "1",
            "token_name": "TNK",
            "token_symbol": "TNK"
        }
    }
}
```

