# OpenClaw A-Stock Bootstrap

This repository is the shared source for all OpenClaw computers that need A-share data access.

Repository:

```text
https://github.com/pengke531/finance-opc-kit
```

## What OpenClaw Should Do

When an OpenClaw agent reads this repository, it should:

1. Load the skill root:

```text
workspace/skills/shared
```

2. Use this skill for A-share data tasks:

```text
workspace/skills/shared/a-stock-data/SKILL.md
```

3. Keep this compatibility skill available for older finance agents:

```text
workspace/skills/shared/eastmoney_api/SKILL.md
```

No API key is required for the public Eastmoney market data endpoints below.

## Eastmoney Public API

Realtime quote endpoint:

```text
https://push2.eastmoney.com/api/qt/stock/get
```

Example:

```text
https://push2.eastmoney.com/api/qt/stock/get?secid=0.000001&fields=f43,f44,f45,f46,f47,f48,f57,f58,f60,f169,f170
```

Historical K-line endpoint:

```text
https://push2his.eastmoney.com/api/qt/stock/kline/get
```

Example:

```text
https://push2his.eastmoney.com/api/qt/stock/kline/get?secid=0.000001&klt=101&fqt=1&beg=20250101&end=20500101&lmt=30&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61
```

## OpenClaw Config Snippet

If the repository is cloned locally instead of imported directly, add this to `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "load": {
      "extraDirs": [
        "/absolute/path/to/finance-opc-kit/workspace/skills/shared"
      ]
    }
  }
}
```

On Windows, an example path is:

```text
C:/Users/itach/Documents/codex/finance-opc-kit/workspace/skills/shared
```

## Verification Prompts

After loading this repository, start a new OpenClaw session and try:

```text
@finance_data 获取 000001.SZ 的实时行情，使用 a-stock-data skill 和东方财富公开 API
```

```text
@finance_data 获取 600519.SH 最近30根日K线，返回数据来源和时间
```

Expected behavior:

- Use `a-stock-data`.
- Use Eastmoney public endpoints.
- Normalize symbols such as `000001.SZ`, `600519.SH`, `SZ000001`, and `sh600519`.
- Say clearly when Eastmoney returns no data or the endpoint is unavailable.
- Do not invent market data.

## Notes

This is market reference data only. It is not a trading API and should not be used to place live orders.
