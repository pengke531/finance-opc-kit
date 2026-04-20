# Skills配置分配表

## Agent与Skills对应关系

### F01 Financial Commander (总指挥)
**所需Skills**:
- `risk_management` - 风险管理和控制
- `decision_framework` - 决策框架

**主要用途**:
- 风险评估和控制
- 投资决策制定
- 资源分配优化
- 应急情况处理

### F02 Data Collector (数据收集)
**所需Skills**:
- `eastmoney_api` - 东方财富API数据获取
- `data_processing` - 数据处理和清洗
- `data_storage` - 数据存储管理

**主要用途**:
- 实时行情数据获取
- 历史数据收集
- 财务数据获取
- 数据质量验证

### F03 Market Analyst (市场分析)
**所需Skills**:
- `technical_analysis` - 技术分析
- `fundamental_analysis` - 基本面分析
- `data_processing` - 数据处理

**主要用途**:
- 技术指标分析
- 图表形态识别
- 财务报表分析
- 投资建议生成

### F04 Trading Executor (交易执行)
**所需Skills**:
- `risk_management` - 风险管理
- `order_execution` - 订单执行
- `position_management` - 持仓管理

**主要用途**:
- 交易指令执行
- 风险检查
- 持仓管理
- 交易确认

### F05 Market Monitor (市场监控)
**所需Skills**:
- `market_monitoring` - 市场监控
- `eastmoney_api` - 实时数据获取
- `alert_system` - 告警系统

**主要用途**:
- 实时价格监控
- 异常情况检测
- 告警推送
- 风险预警

## Skills加载优先级

### 核心Skills (必须)
1. `eastmoney_api` - 数据获取基础
2. `data_processing` - 数据处理基础
3. `risk_management` - 风控基础
4. `technical_analysis` - 分析基础

### 扩展Skills (可选)
1. `fundamental_analysis` - 基本面分析
2. `market_monitoring` - 市场监控
3. `alert_system` - 告警系统
4. `backtesting` - 策略回测

## Skills依赖关系

```
eastmoney_api (基础)
    ↓
data_processing (数据处理)
    ↓
technical_analysis (技术分析)
    ↓
risk_management (风险管理)
    ↓
order_execution (订单执行)
```

## Skills配置文件

### openclaw.json中的skills配置
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

### Agent特定的skills配置
每个Agent可以指定优先使用的skills：
```json
{
  "id": "finance_data",
  "preferred_skills": [
    "eastmoney_api",
    "data_processing"
  ]
}
```

## Skills性能要求

### 响应时间要求
- API调用: < 2秒
- 数据处理: < 1秒
- 技术分析: < 3秒
- 风险计算: < 1秒

### 可靠性要求
- Skills可用率: > 99.5%
- 数据准确率: > 99.9%
- 错误恢复率: > 95%

## Skills监控

### 性能监控
- 调用频率统计
- 响应时间监控
- 错误率监控
- 资源使用监控

### 质量监控
- 输出质量检查
- 异常检测
- 用户反馈收集
- 持续改进

## Skills更新机制

### 自动更新
- 定期检查skills更新
- 自动下载新版本
- 测试新版本兼容性
- 逐步部署更新

### 手动更新
- 用户触发更新
- 备份当前版本
- 安装新版本
- 验证功能正常
