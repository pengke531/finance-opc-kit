# 金融OPC系统 - OpenClaw金融交易Agent包

一键安装即可为您的OpenClaw系统添加专业的金融交易Agent！

## ⚡ 快速开始

### 🪟 Windows用户

```powershell
# 1. 克隆项目
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit

# 2. 运行安装脚本
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

### 🍎 macOS/Linux用户

```bash
# 1. 克隆项目
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit

# 2. 运行安装脚本
chmod +x install.sh
./install.sh
```

## 🤖 已安装的Agent

- **F01 Financial Commander** - 金融总指挥，负责风险管理和最终决策
- **F02 Data Collector** - 数据收集专家，负责市场数据获取
- **F03 Market Analyst** - 市场分析师，负责技术分析和投资建议  
- **F04 Trading Executor** - 交易执行专家，负责具体交易操作
- **F05 Market Monitor** - 市场监控专家，负责实时监控和风险预警

## 📋 使用方法

安装完成后重启OpenClaw，然后就可以使用：

```
@finance_main 你好
@finance_main 分析一下平安银行
@finance_main 设置交易权限为模拟模式
```

## 🛡️ 安全特性

- 交易权限开关控制
- 个股黑名单管理
- 完整的容错机制
- 风险评估系统

详细使用指南请查看 [USER_GUIDE.md](USER_GUIDE.md)

## 🔄 卸载

### Windows
```powershell
# 查找备份文件
dir $env:USERPROFILE\.openclaw\openclaw.json.backup-finance-*

# 恢复最新备份
cp $env:USERPROFILE\.openclaw\openclaw.json.backup-finance-最新时间 $env:USERPROFILE\.openclaw\openclaw.json
```

### macOS/Linux
```bash
# 恢复备份
cp ~/.openclaw/openclaw.json.backup-finance-* ~/.openclaw/openclaw.json
```

## 📚 文档

- [USER_GUIDE.md](USER_GUIDE.md) - 完整使用指南
- [FAULT_TOLERANCE.md](FAULT_TOLERANCE.md) - 容错机制说明
- [AGENT_INTERACTION_ANALYSIS.md](AGENT_INTERACTION_ANALYSIS.md) - Agent交互分析

## ⚠️ 重要提醒

本系统仅供教育研究使用，实际交易请谨慎操作并遵守相关法规。

---

**License**: MIT | **Star** ⭐ if you find this useful!
