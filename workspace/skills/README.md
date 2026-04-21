# 金融OPC系统 - Skills配置说明

本目录包含金融OPC系统所需的所有skills。

## Skills组织结构

```
skills/
└── shared/
    ├── data_processing/
    ├── eastmoney_api/
    ├── market_monitoring/
    ├── risk_management/
    └── technical_analysis/
```

## Skills加载机制

通过openclaw.json中的skills.load配置自动加载：
```json
{
  "skills": {
    "load": {
      "extraDirs": [
        "__DOMAIN_ROOT__/workspace/skills/shared"
      ]
    }
  }
}
```

## Skills使用说明

各 Agent 通过共享 skills 获取能力：
- F02: 行情获取、数据处理
- F03: 技术分析、风险评估
- F04: 执行前风险约束与状态确认
- F05: 行情监控与告警逻辑
