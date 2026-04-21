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

## 4. Agent 已注册，但聊天里不工作

请按顺序检查：

1. 是否已经重启 OpenClaw
2. 是否新开了一个会话
3. 是否能在 `openclaw agents list` 中看到 `finance_main`
4. 是否使用 `@finance_main` 发起请求

推荐验收语句：

```text
@finance_main 分析一下平安银行
```

## 5. 如何确认安装真的完成了

执行：

```bash
openclaw agents list
openclaw config validate
```

其中：

- `agents list` 能看到 `finance_*`，说明 Agent 已注册
- `config validate` 通过，说明配置结构正常

## 6. 仍然有问题怎么办

建议把下面三项信息一起整理后再提 Issue：

1. 您执行的安装命令
2. `openclaw agents list` 输出
3. `openclaw config validate` 输出

Issue 地址：

[https://github.com/pengke531/finance-opc-kit/issues](https://github.com/pengke531/finance-opc-kit/issues)
