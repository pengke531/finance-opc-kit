# 金融OPC系统一键安装脚本 (Windows)

Write-Host "🔧 金融OPC系统安装" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# 检查OpenClaw安装
$openclawRoot = "$env:USERPROFILE\.openclaw"
if (-not (Test-Path $openclawRoot)) {
    Write-Host "❌ 错误: OpenClaw未安装" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 检测到OpenClaw安装" -ForegroundColor Green

# 备份配置
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$openclawRoot\openclaw.json.backup-finance-$timestamp"
Copy-Item "$openclawRoot\openclaw.json" $backupFile
Write-Host "✅ 已备份配置" -ForegroundColor Green

# 创建Agent目录
$agentBaseDir = "$openclawRoot\agents"
Write-Host "📁 创建Agent目录..." -ForegroundColor Cyan

$agentIds = @("finance_main", "finance_data", "finance_analysis", "finance_trading", "finance_monitor")
foreach ($agentId in $agentIds) {
    New-Item -ItemType Directory -Force -Path "$agentBaseDir\$agentId\agent" | Out-Null
    New-Item -ItemType Directory -Force -Path "$agentBaseDir\$agentId\memory" | Out-Null
    New-Item -ItemType Directory -Force -Path "$agentBaseDir\$agentId\sessions" | Out-Null
}

# 创建配置文件
Write-Host "📝 创建Agent配置..." -ForegroundColor Cyan

@"
# F01 Financial Commander
你是金融交易总指挥官。
"@ | Out-File "$agentBaseDir\finance_main\SOUL.md" -Encoding UTF8

@"
# F02 Data Collector
你是数据收集专家。
"@ | Out-File "$agentBaseDir\finance_data\SOUL.md" -Encoding UTF8

@"
# F03 Market Analyst
你是市场分析师。
"@ | Out-File "$agentBaseDir\finance_analysis\SOUL.md" -Encoding UTF8

@"
# F04 Trading Executor
你是交易执行专家。
"@ | Out-File "$agentBaseDir\finance_trading\SOUL.md" -Encoding UTF8

@"
# F05 Market Monitor
你是市场监控专家。
"@ | Out-File "$agentBaseDir\finance_monitor\SOUL.md" -Encoding UTF8

# 注册Agent
Write-Host "🔧 注册Agent..." -ForegroundColor Cyan

cd $openclawRoot

$pythonCode = @"
import json, os
user_home = os.path.expanduser('~').replace('\\', '/')
with open('openclaw.json', 'r', encoding='utf-8') as f: config = json.load(f)
agents = [
    {'agentDir': f'{user_home}/.openclaw/agents/finance_main/agent', 'id': 'finance_main', 'identity': {'emoji': 'F01', 'name': 'F01 Financial Commander'}, 'name': 'finance_main', 'subagents': {'allowAgents': ['finance_data', 'finance_analysis', 'finance_trading', 'finance_monitor']}, 'tools': {'alsoAllow': ['read', 'write', 'sessions_spawn', 'subagents', 'web_search', 'web_fetch', 'memory_search', 'memory_get', 'memory_store', 'agents_list'], 'profile': 'messaging'}, 'workspace': f'{user_home}/.openclaw/workspace'},
    {'agentDir': f'{user_home}/.openclaw/agents/finance_data/agent', 'id': 'finance_data', 'identity': {'emoji': 'F02', 'name': 'F02 Data Collector'}, 'name': 'finance_data', 'subagents': {'allowAgents': []}, 'tools': {'alsoAllow': ['read', 'write', 'web_search', 'web_fetch', 'memory_search', 'memory_get', 'memory_store'], 'profile': 'minimal'}, 'workspace': f'{user_home}/.openclaw/workspace'},
    {'agentDir': f'{user_home}/.openclaw/agents/finance_analysis/agent', 'id': 'finance_analysis', 'identity': {'emoji': 'F03', 'name': 'F03 Market Analyst'}, 'name': 'finance_analysis', 'subagents': {'allowAgents': []}, 'tools': {'alsoAllow': ['read', 'write', 'web_search', 'web_fetch', 'memory_search', 'memory_get', 'memory_store'], 'profile': 'minimal'}, 'workspace': f'{user_home}/.openclaw/workspace'},
    {'agentDir': f'{user_home}/.openclaw/agents/finance_trading/agent', 'id': 'finance_trading', 'identity': {'emoji': 'F04', 'name': 'F04 Trading Executor'}, 'name': 'finance_trading', 'subagents': {'allowAgents': ['finance_monitor']}, 'tools': {'alsoAllow': ['read', 'write', 'web_search', 'web_fetch', 'memory_search', 'memory_get', 'memory_store'], 'profile': 'minimal'}, 'workspace': f'{user_home}/.openclaw/workspace'},
    {'agentDir': f'{user_home}/.openclaw/agents/finance_monitor/agent', 'id': 'finance_monitor', 'identity': {'emoji': 'F05', 'name': 'F05 Market Monitor'}, 'name': 'finance_monitor', 'subagents': {'allowAgents': ['finance_main']}, 'tools': {'alsoAllow': ['read', 'write', 'web_search', 'web_fetch', 'memory_search', 'memory_get', 'memory_store'], 'profile': 'minimal'}, 'workspace': f'{user_home}/.openclaw/workspace'}
]
for agent in agents:
    if not any(a.get('id') == agent['id'] for a in config['agents']['list']):
        config['agents']['list'].append(agent)
with open('openclaw.json', 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
"@

$pythonCode | python

Write-Host ""
Write-Host "🎉 安装完成！重启OpenClaw后使用 @finance_main 测试" -ForegroundColor Green
Write-Host ""
