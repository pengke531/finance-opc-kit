# Finance OPC Kit - 金融交易多代理编排系统

专业级的金融交易自动化系统，基于OpenClaw平台构建。

## 🎯 系统功能

### 核心能力
- ✅ **信息收集**: 实时行情、历史数据、财务信息
- ✅ **智能分析**: 技术分析、基本面分析、风险评估
- ✅ **交易执行**: 模拟交易、订单管理、风险控制
- ✅ **实时监控**: 价格告警、异常检测、条件触发
- ✅ **自动复盘**: 交易分析、策略优化、性能评估

### 数据源
- 东方财富API (实时行情、历史数据)
- 财务数据API (财务报表、基本面)
- 新闻API (市场资讯、公司公告)
- 经济数据API (宏观指标、行业数据)

## 🏗️ Agent架构

### F01 Financial Commander (总指挥)
- **性格**: 战略性、谨慎、果断
- **职责**: 投资决策、风险管理、团队协调
- **权限**: 全局协调、最终批准、紧急干预

### F02 Data Collector (数据收集)
- **性格**: 高效、细致、组织化
- **职责**: 数据采集、质量验证、存储管理
- **权限**: 数据访问、API调用、存储操作

### F03 Market Analyst (市场分析)
- **性格**: 分析性、客观、注重细节
- **职责**: 技术分析、基本面分析、风险评估
- **权限**: 分析工具、报告生成、建议输出

### F04 Trading Executor (交易执行)
- **性格**: 精确、快速、守纪律
- **职责**: 订单执行、头寸管理、交易确认
- **权限**: 交易接口、订单管理、资金操作

### F05 Market Monitor (市场监控)
- **性格**: 警惕、响应、前瞻性
- **职责**: 实时监控、告警触发、异常检测
- **权限**: 监控工具、告警系统、通知接口

## 🚀 快速开始

### 安装

**macOS/Linux**:
```bash
git clone https://github.com/yourusername/finance-opc-kit.git
cd finance-opc-kit
chmod +x ./install-finance-opc.sh
./install-finance-opc.sh
```

**Windows**:
```powershell
git clone https://github.com/yourusername/finance-opc-kit.git
cd finance-opc-kit
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

### 配置

编辑环境变量文件：
```bash
~/.openclaw/domains/finance-opc/.env
```

关键配置项：
- `TRADING_MODE`: simulation (模拟) 或 live (实盘)
- `MAX_POSITION_SIZE`: 最大头寸规模
- `STOP_LOSS_PERCENTAGE`: 止损百分比
- `TAKE_PROFIT_PERCENTAGE`: 止盈百分比

### 使用

启动OpenClaw：
```bash
openclaw gateway
```

开始金融操作：
```bash
openclaw chat --agent finance_main
```

## 📊 工作流程示例

### 每日市场分析
1. F05检测市场开盘
2. F02收集盘前数据
3. F03分析隔夜走势
4. F01制定当日策略
5. F05监控触发条件

### 交易执行
1. F05发现交易机会
2. F03验证技术分析
3. F01风险范围内批准
4. F04执行订单确认
5. F05监控退出条件

### 复盘分析
1. F04收集交易数据
2. F03分析预期表现
3. F01记录经验教训
4. F02存档备查数据

## 🔧 技术架构

```
OpenClaw Core → Finance OPC Agents → Data APIs
    ↓              ↓                  ↓
 AI Engine    F01-F05 Agents    Eastmoney APIs
 Scheduler    协作层             数据源
 Memory       执行层             接口层
```

## ⚠️ 风险警告

- 本系统仅供学习研究使用
- 所有交易决策请咨询专业金融顾问
- 模拟交易模式可安全测试策略
- 实盘交易涉及真实资金风险

## 📄 文档位置

- 架构文档: `workspace/docs/architecture/`
- Agent配置: `agents/*/` 目录
- API文档: `workspace/docs/api/`
- 使用指南: `workspace/docs/runbooks/`

## 🛠️ 故障排除

### 常见问题

1. **API连接失败**
   - 检查网络连接
   - 验证API密钥
   - 查看日志文件

2. **数据不准确**
   - 验证数据源
   - 检查时间同步
   - 重新获取数据

3. **告警不触发**
   - 检查告警条件设置
   - 验证监控状态
   - 查看告警历史

## 📞 支持与反馈

- 问题报告: GitHub Issues
- 功能建议: GitHub Discussions
- 文档改进: Pull Requests

## 📜 许可证

MIT License - 详见 LICENSE 文件

---

**免责声明**: 本系统仅供教育目的使用。投资有风险，决策需谨慎。
