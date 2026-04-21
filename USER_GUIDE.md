# 金融 OPC 系统使用说明

本文档面向第一次接触 `finance-opc-kit` 的用户，目标是让您按顺序完成：

1. 安装或导入
2. 验证 Agent 是否成功注册
3. 在 OpenClaw 中启用并发起第一次对话
4. 学会日常使用流程
5. 遇到问题时快速定位

## 1. 使用前准备

开始前请确认以下条件：

- 已安装 OpenClaw
- 本机可以正常运行 `openclaw --version`
- 已有可用的模型配置或可正常使用 OpenClaw 桌面端 / Gateway
- 安装脚本运行环境中可用 `python` 或 `python3`

建议先执行：

```bash
openclaw --version
openclaw config validate
```

如果这里已经报错，说明宿主 OpenClaw 环境本身有问题，建议先修复宿主环境，再导入本项目。

## 2. 推荐安装流程

### 方式 A：直接通过仓库导入

如果您使用的是支持仓库导入的 OpenClaw 界面，直接导入以下仓库即可：

```text
https://github.com/pengke531/finance-opc-kit.git
```

导入时，OpenClaw 会读取仓库根目录的 [openclaw.json](openclaw.json)，按增量导入方式注册以下 Agent：

- `finance_main`
- `finance_data`
- `finance_analysis`
- `finance_trading`
- `finance_monitor`

导入完成后，重启 OpenClaw 桌面端或 Gateway，再进入新会话测试。

### 方式 B：克隆后执行一键安装脚本

#### Windows

```powershell
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

#### macOS / Linux

```bash
git clone https://github.com/pengke531/finance-opc-kit.git
cd finance-opc-kit
chmod +x install.sh
./install.sh
```

脚本会完成以下动作：

1. 把当前仓库内容复制到 `~/.openclaw/domains/finance-opc`
2. 将本项目的 Agent 配置增量合并到用户现有 `openclaw.json`
3. 自动备份原有配置
4. 运行 `openclaw config validate` 做一次校验

## 3. 安装后如何确认成功

执行：

```bash
openclaw agents list
```

输出中应该至少能看到以下 5 个 Agent：

- `finance_main`
- `finance_data`
- `finance_analysis`
- `finance_trading`
- `finance_monitor`

如果您想看得更清楚，可以直接筛选：

```bash
openclaw agents list --json
```

另外也建议执行一次：

```bash
openclaw config validate
```

说明：

- 如果这里显示 `Config valid`，说明 finance 包和当前宿主配置都没有明显结构问题。
- 如果这里报错，但安装脚本已经提示 “profile imported”，那通常表示 finance 包已导入成功，只是宿主原有配置中还存在别的 channel / plugin 脏项，需要单独修复。

## 4. 首次启用流程

安装成功后，请严格按这个顺序使用。

### 第 1 步：重启 OpenClaw

如果您使用桌面端，关闭并重新打开应用。

如果您使用 Gateway / 服务模式，请重启对应进程，确保新导入的 Agent 配置被重新加载。

### 第 2 步：新建一个新的会话

不要直接沿用导入前的旧会话。新会话能确保新的 Agent 路由和 bootstrap 文件被重新读取。

### 第 3 步：先用主 Agent 测试

在聊天界面里输入：

```text
@finance_main 你好，请介绍一下你的职责和你能调用哪些金融子 Agent
```

正常情况下，`finance_main` 会以金融总指挥的身份响应，并说明自己会协调：

- `finance_data`
- `finance_analysis`
- `finance_trading`
- `finance_monitor`

### 第 4 步：做一次简单业务测试

建议用这句：

```text
@finance_main 分析一下平安银行
```

或者用英文 / 代码化一点的写法：

```text
@finance_main analyze 000001.SZ
```

这是最适合做首轮验收的请求，因为它会覆盖主 Agent 的典型调用链：

1. `finance_main` 接收需求
2. 按需调用 `finance_data` 获取事实数据
3. 按需调用 `finance_analysis` 输出技术面 / 风险判断
4. 最终由 `finance_main` 汇总成用户可读结果

## 5. CLI 直接调用方法

如果您不走桌面会话，也可以直接用 CLI 发起一次 Agent turn：

```bash
openclaw agent --agent finance_main --message "分析一下平安银行"
```

如果您在纯本地模式下运行，并且已经在当前 shell 中配置好了模型 API Key，可以尝试：

```bash
openclaw agent --agent finance_main --message "分析一下平安银行" --local
```

注意：

- `--local` 依赖当前 shell 已配置好模型凭证
- 如果您平时依赖桌面端或 Gateway，优先使用默认模式，不必强行加 `--local`

## 6. 五个 Agent 的分工

### `finance_main`

金融总指挥。负责：

- 理解用户目标
- 组织子 Agent 分工
- 做最终总结和风险提示

建议优先与它对话。

### `finance_data`

数据收集 Agent。负责：

- 市场数据
- 历史数据
- 基础事实检索

### `finance_analysis`

分析 Agent。负责：

- 技术分析
- 基本面分析
- 风险收益判断

### `finance_trading`

执行 Agent。负责：

- 交易执行思路
- 订单参数确认
- 执行层面的风险约束

### `finance_monitor`

监控 Agent。负责：

- 风险告警
- 价格阈值监控
- 波动异常提醒

## 7. 推荐日常使用流程

### 场景 A：先做研究，再决定要不要交易

推荐流程：

1. 先问主 Agent
2. 看分析结论和风险提示
3. 觉得值得跟进，再继续问执行建议

示例：

```text
@finance_main 分析一下宁德时代，重点看趋势、风险和适合的仓位
```

如果分析结果不错，再继续：

```text
@finance_main 如果我只想先试仓 5%，怎么下更稳妥？
```

### 场景 B：已经有标的，只想做执行规划

示例：

```text
@finance_main 我计划买入 000001.SZ，请给我一个更稳妥的分批买入方案和止损建议
```

此时主 Agent 通常会协调：

- `finance_analysis` 做风险判断
- `finance_trading` 给出执行层方案

### 场景 C：希望持续观察某个标的

示例：

```text
@finance_main 监控平安银行，跌破 12 元提醒我，并说明可能的应对动作
```

这类请求通常会交给 `finance_monitor` 做持续监控逻辑说明。

### 场景 D：管理已有持仓

示例：

```text
@finance_main 我现在持有 000001.SZ、600519.SH、00700.HK，请按风险、仓位和后续动作给我一个组合复盘
```

建议您在这类请求里明确提供：

- 持仓标的
- 成本价
- 当前仓位
- 您偏保守还是偏激进

这样主 Agent 更容易给出有操作价值的结果。

## 8. 与客户沟通时建议这样教他们

如果您要把项目交付给客户，建议直接让客户按下面这条固定流程走：

1. 导入仓库或运行一键安装脚本
2. 重启 OpenClaw
3. 新建一个会话
4. 先发 `@finance_main 你好`
5. 再发 `@finance_main 分析一下平安银行`
6. 看是否能正常返回分析结果

如果这 6 步都通过，基本就说明：

- Agent 已加载
- 主 Agent bootstrap 已生效
- 子 Agent 路由可用
- 基础调用链正常

## 9. 常见问题与处理方式

### 9.1 安装脚本提示缺少 Python

请先安装 Python，并确保下面任意一个命令可用：

```bash
python --version
python3 --version
```

### 9.2 `openclaw config validate` 报错

这类错误分两种情况：

#### 情况 A：finance 包自身配置有问题

优先检查：

- 项目是否是最新版本
- `openclaw.json` 是否完整
- `workspace/` 与 `agents/` 是否被误删

#### 情况 B：宿主原配置就有历史问题

比如用户之前已经配置过失效的 plugin / channel。此时 finance 包通常已经导入成功，但宿主配置仍会报错。

建议执行：

```bash
openclaw doctor
```

如果需要自动修复，可尝试：

```bash
openclaw doctor --fix --yes
```

### 9.3 Agent 已出现，但聊天里不能正常调用

请按顺序检查：

1. 是否已经重启 OpenClaw
2. 是否新开了一个会话
3. `openclaw agents list` 里是否能看到 `finance_main`
4. `openclaw config validate` 是否通过
5. 是否使用了 `@finance_main` 而不是旧名字

### 9.4 CLI 能跑，桌面端不生效

这通常说明：

- CLI 读到的是新配置
- 桌面端还没重启，或者还停留在旧会话里

处理方式：

1. 完全退出桌面端
2. 重新打开
3. 新建会话
4. 再次测试 `@finance_main`

## 10. 升级与重装

如果仓库更新后需要升级：

```bash
git pull
```

然后重新执行安装脚本即可：

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\install-finance-opc.ps1
```

### macOS / Linux

```bash
./install.sh
```

脚本会重新覆盖 `domains/finance-opc` 下的项目文件，并重新合并配置。

## 11. 卸载说明

如果要移除本项目，请至少删除：

- `~/.openclaw/domains/finance-opc`
- 用户配置中对应的 `finance_*` Agent 条目

如果您是用脚本安装的，建议先使用安装时生成的配置备份进行恢复。

## 12. 一句话验收标准

交付是否成功，可以用这一条判断：

在重启 OpenClaw并新建会话后，输入

```text
@finance_main 分析一下平安银行
```

如果可以稳定返回一段像样的金融分析，而不是无响应、找不到 Agent 或空白回复，就说明部署链路已经打通。
