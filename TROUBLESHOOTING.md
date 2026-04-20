# 🔧 安装故障排除

## 问题：找不到PowerShell安装脚本

如果您遇到以下错误：
```
-File 形式参数的实际参数".\install-finance-opc.ps1"不存在
```

### 解决方法

#### 方法1：重新克隆项目（推荐）

```powershell
# 删除旧目录
Remove-Item -Recurse -Force finance-opc-kit

# 重新克隆
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit

# 验证文件存在
dir *.ps1

# 然后运行安装
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

#### 方法2：手动拉取最新代码

```powershell
cd finance-opc-kit
git pull origin main

# 验证文件存在
dir *.ps1

# 运行安装
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

#### 方法3：检查文件是否正确下载

```powershell
# 查看当前目录文件
dir

# 查找所有PowerShell脚本
dir *.ps1

# 如果看到 install-finance-opc.ps1，直接运行：
.\install-finance-opc.ps1
```

## 常见问题

### 1. PowerShell执行策略限制
如果遇到执行策略错误，使用：
```powershell
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

### 2. Python未安装
脚本需要Python3，请先安装：https://www.python.org/downloads/

### 3. OpenClaw未安装
请先安装OpenClaw：https://github.com/anthropics/openclaw

### 4. 权限问题
以管理员身份运行PowerShell

## 验证安装成功

安装完成后，您应该看到：
```
✅ 检测到OpenClaw安装
✅ 已备份配置
📁 创建Agent目录...
  ✅ finance_main
  ✅ finance_data
  ✅ finance_analysis
  ✅ finance_trading
  ✅ finance_monitor
📝 创建Agent配置...
🔧 注册Agent...
🎉 安装完成！
```

## 仍需要帮助？

如果以上方法都无法解决，请提交Issue：
https://github.com/pengke531/finance-opc-kit/issues
