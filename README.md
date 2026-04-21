# 金融OPC系统 - OpenClaw金融交易Agent包

一键安装即可为您的OpenClaw系统添加专业的金融交易Agent！

## ⚡ 快速开始

### 🚀 OpenClaw 仓库导入（推荐）

将本仓库地址直接导入 OpenClaw。仓库根目录的 `openclaw.json` 已配置为
增量导入入口，导入后会自动注册以下 Agent：

- `finance_main`
- `finance_data`
- `finance_analysis`
- `finance_trading`
- `finance_monitor`

导入完成后请重启 OpenClaw，并在新会话中测试：

```text
@finance_main 分析一下平安银行
```

### 🪟 Windows用户

```powershell
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

### 🍎 macOS/Linux用户

```bash
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit
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

安装完成后，建议按下面顺序使用：

1. 重启 OpenClaw 桌面端或 Gateway
2. 新建一个会话
3. 先测试主 Agent 是否可见
4. 再做一次真实分析请求

推荐测试语句：

```
@finance_main 你好
@finance_main 分析一下平安银行
@finance_main 设置交易权限为模拟模式
```

更完整的安装后启用流程、CLI 调用方法、客户交付验收方式，请查看 [USER_GUIDE.md](USER_GUIDE.md)。

## 🛡️ 安全特性

- 交易权限开关控制
- 个股黑名单管理
- 完整的容错机制
- 风险评估系统

详细使用指南请查看 [USER_GUIDE.md](USER_GUIDE.md)

## 🔄 卸载

### Windows
```powershell
# 删除Agent目录
Remove-Item -Recurse -Force $env:USERPROFILE\.openclaw\agents\finance_*

# 或者使用备份恢复（如果有）
dir $env:USERPROFILE\.openclaw\openclaw.json.backup-*
```

### macOS/Linux
```bash
# 删除Agent目录
rm -rf ~/.openclaw/agents/finance_*

# 或者使用备份恢复（如果有）
ls ~/.openclaw/openclaw.json.backup-finance-*
```

## 📚 文档

- [USER_GUIDE.md](USER_GUIDE.md) - 完整使用指南
- [FAULT_TOLERANCE.md](FAULT_TOLERANCE.md) - 容错机制说明
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - 故障排除指南

## ⚠️ 重要提醒

本系统仅供教育研究使用，实际交易请谨慎操作并遵守相关法规。

## 💬 问题反馈

如遇到安装问题，请提交Issue：
https://github.com/pengke531/finance-opc-kit/issues

---

**License**: MIT | **Star** ⭐ if you find this useful!
