# 金融OPC系统 - Skills配置说明

本目录包含金融OPC系统所需的所有skills。

## Skills组织结构

```
skills/
├── shared/              # 共享skills
│   ├── data_fetching/   # 数据获取skills
│   ├── analysis/        # 分析skills
│   └── utils/           # 工具skills
├── finance_data/        # F02专用skills
├── finance_analysis/    # F03专用skills
├── finance_trading/     # F04专用skills
└── finance_monitor/     # F05专用skills
```

## Skills加载机制

通过openclaw.json中的skills.load配置自动加载：
```json
{
  "skills": {
    "load": {
      "extraDirs": [
        "__PACKAGE_ROOT__/workspace/skills"
      ]
    }
  }
}
```

## Skills使用说明

每个Agent可以根据需要调用相应的skills：
- F02: 数据获取和处理skills
- F03: 技术分析和基本面分析skills  
- F04: 交易执行和风险控制skills
- F05: 监控和告警skills
