---
name: a-stock-data
description: Use this skill whenever the user asks for A-share market data, China stock quotes, K-line/history data, Eastmoney/东方财富 API access, 股票行情, A股, 实时行情, or finance-opc data collection. This skill tells OpenClaw how to use Eastmoney public market data endpoints without requiring an API key.
---

# A-Stock Data

Use Eastmoney public market data endpoints for A-share quote and K-line requests.

## Endpoints

Realtime quote:

```text
https://push2.eastmoney.com/api/qt/stock/get
```

Historical K-line:

```text
https://push2his.eastmoney.com/api/qt/stock/kline/get
```

## Symbol Rules

Normalize common input forms:

- `000001` -> infer `000001.SZ`
- `000001.SZ` -> `secid=0.000001`
- `SZ000001` -> `secid=0.000001`
- `600519.SH` -> `secid=1.600519`
- `sh600519` -> `secid=1.600519`

Shanghai codes usually start with `5`, `6`, or `9`. Shenzhen codes usually start with `0`, `2`, or `3`.

## Quote Request

Use:

```text
https://push2.eastmoney.com/api/qt/stock/get?secid=<secid>&fields=f43,f44,f45,f46,f47,f48,f57,f58,f60,f169,f170
```

Important fields:

- `f43`: latest price, scaled by 100
- `f44`: high, scaled by 100
- `f45`: low, scaled by 100
- `f46`: open, scaled by 100
- `f47`: volume
- `f48`: amount
- `f57`: code
- `f58`: name
- `f60`: previous close, scaled by 100
- `f169`: price change, scaled by 100
- `f170`: percent change, scaled by 100

## K-Line Request

Use:

```text
https://push2his.eastmoney.com/api/qt/stock/kline/get?secid=<secid>&klt=101&fqt=1&beg=20250101&end=20500101&lmt=30&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61
```

Common `klt` values:

- `101`: daily
- `102`: weekly
- `103`: monthly
- `1`, `5`, `15`, `30`, `60`: minute periods

Common `fqt` values:

- `0`: no adjustment
- `1`: forward adjustment
- `2`: backward adjustment

## Response Rules

When answering the user:

- Include symbol, name, latest price or K-line rows, and source.
- Mention that the source is Eastmoney public market data.
- If the endpoint fails or returns empty data, say so directly.
- Never invent missing market data.
- Do not place trades from this skill.
