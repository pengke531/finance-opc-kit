# 🔧 安装问题紧急修复

## 问题诊断

文件 `install-finance-opc.ps1` **确实在GitHub仓库中**。

## 立即解决方案

### 方案1：强制刷新（推荐）

```powershell
# 删除整个目录
Remove-Item -Recurse -Force finance-opc-kit

# 重新克隆
git clone https://github.com/pengke531/finance-opc-kit.git

# 进入目录并立即检查
cd finance-opc-kit
dir

# 如果看到 install-finance-opc.ps1，运行它：
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

### 方案2：直接下载安装脚本

如果git一直有问题，直接下载安装脚本：

```powershell
# 创建目录
New-Item -ItemType Directory -Force finance-opc-kit
cd finance-opc-kit

# 下载安装脚本（直接从GitHub）
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/pengke531/finance-opc-kit/main/install-finance-opc.ps1" -OutFile "install-finance-opc.ps1"

# 运行
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

### 方案3：使用Bash脚本（Git Bash）

如果您安装了Git for Windows，可以用bash脚本：

```bash
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit
bash install.sh
```

## 验证安装

安装成功后应该看到5个Agent被注册：
- finance_main
- finance_data
- finance_analysis
- finance_trading
- finance_monitor
