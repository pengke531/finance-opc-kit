# 故障排除

本页只保留最常见、最容易影响客户一键部署的问题。

## 1. 找不到安装脚本

如果 PowerShell 提示：

```text
.\install-finance-opc.ps1 不存在
```

通常是仓库目录不完整或当前目录不对。

请按下面顺序检查：

```powershell
dir
dir *.ps1
```

如果当前目录下没有 `install-finance-opc.ps1`，建议重新拉取仓库：

```powershell
cd ..
Remove-Item -Recurse -Force .\finance-opc-kit
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit
dir *.ps1
```

## 2. 安装脚本提示缺少 Python

本项目安装脚本依赖 `python` 或 `python3`。

请验证：

```bash
python --version
python3 --version
```

如果都不可用，请先安装 Python，再重新执行安装脚本。

## 3. `openclaw config validate` 报错

先区分两种情况。

### 情况 A：finance 包没导入成功

建议检查：

- 仓库是否是最新版本
- `openclaw.json` 是否存在
- `workspace/scripts/deploy_profile.py` 是否存在

### 情况 B：宿主配置本身有历史脏项

这很常见，比如用户之前配置过旧插件、旧 channel。

可以先运行：

```bash
openclaw doctor
```

如需自动修复：

```bash
openclaw doctor --fix --yes
```

## 4. 安装脚本提示 `deploy_profile.py failed`

如果安装输出里出现：

```text
[finance-opc] deploy_profile.py failed
```

现在新版脚本会继续打印更具体的原因。最常见的是宿主
`~/.openclaw/openclaw.json` 本身有问题。

### 情况 A：宿主配置里有注释或尾逗号

新版安装器已经会自动兼容这两种写法，并继续导入。

如果您看到类似：

```text
[finance-opc] note: recovered the host openclaw.json by stripping comments or trailing commas before merging.
```

说明安装器已经自动处理完成，无需额外操作。

### 情况 B：宿主配置已经损坏，无法解析

如果您看到类似：

```text
[finance-opc] Cannot parse existing OpenClaw config: C:\Users\xxx\.openclaw\openclaw.json
```

说明这个文件已经不是可恢复的 JSON 结构了。请先：

1. 备份原文件
2. 用编辑器修复 JSON 结构
3. 或者先把它重命名为 `openclaw.json.broken.bak`
4. 再重新执行安装脚本

如果您不确定哪里坏了，先执行：

```bash
openclaw config validate
```

或者直接打开 `~/.openclaw/openclaw.json` 检查是否存在：

- 缺少右括号 `}`
- 缺少右中括号 `]`
- 引号没有闭合
- 复制粘贴残留了非 JSON 文本

## 5. Agent 已注册，但聊天里不工作

请按顺序检查：

1. 是否已经重启 OpenClaw
2. 是否新开了一个会话
3. 是否能在 `openclaw agents list` 中看到 `finance_main`
4. 是否使用 `@finance_main` 发起请求

推荐验收语句：

```text
@finance_main 分析一下平安银行
```

## 6. 如何确认安装真的完成了

执行：

```bash
openclaw agents list
openclaw config validate
```

其中：

- `agents list` 能看到 `finance_*`，说明 Agent 已注册
- `config validate` 通过，说明配置结构正常

## 7. 仍然有问题怎么办

建议把下面三项信息一起整理后再提 Issue：

1. 您执行的安装命令
2. `openclaw agents list` 输出
3. `openclaw config validate` 输出

Issue 地址：

[https://github.com/pengke531/finance-opc-kit/issues](https://github.com/pengke531/finance-opc-kit/issues)
