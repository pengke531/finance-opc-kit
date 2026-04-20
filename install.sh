#!/bin/bash
# 金融OPC系统一键安装脚本

set -e

echo "🔧 金融OPC系统安装"
echo "================================"

OPENCLAW_ROOT="$HOME/.openclaw"
if [ ! -d "$OPENCLAW_ROOT" ]; then
    echo "❌ 错误: OpenClaw未安装"
    exit 1
fi

echo "✅ 检测到OpenClaw安装"

# 备份配置
BACKUP_FILE="$OPENCLAW_ROOT/openclaw.json.backup-finance-$(date +%Y%m%d_%H%M%S)"
cp "$OPENCLAW_ROOT/openclaw.json" "$BACKUP_FILE"
echo "✅ 已备份配置"

# 创建Agent目录
AGENT_BASE_DIR="$OPENCLAW_ROOT/agents"
echo "📁 创建Agent目录..."

for agent_id in finance_main finance_data finance_analysis finance_trading finance_monitor; do
    mkdir -p "$AGENT_BASE_DIR/$agent_id"/{agent,memory,sessions}
done

# 创建配置文件
echo "📝 创建Agent配置..."

cat > "$AGENT_BASE_DIR/finance_main/SOUL.md" << 'EOF'
# F01 Financial Commander
你是金融交易总指挥官，负责风险管理和最终决策。
EOF

cat > "$AGENT_BASE_DIR/finance_data/SOUL.md" << 'EOF'
# F02 Data Collector  
你是数据收集专家，负责获取市场数据。
EOF

cat > "$AGENT_BASE_DIR/finance_analysis/SOUL.md" << 'EOF'
# F03 Market Analyst
你是市场分析师，负责技术分析和投资建议。
EOF

cat > "$AGENT_BASE_DIR/finance_trading/SOUL.md" << 'EOF'
# F04 Trading Executor
你是交易执行专家，负责具体的交易操作。
EOF

cat > "$AGENT_BASE_DIR/finance_monitor/SOUL.md" << 'EOF'
# F05 Market Monitor
你是市场监控专家，负责实时监控和风险预警。
EOF

# 注册Agent
echo "🔧 注册Agent..."

cd "$OPENCLAW_ROOT"

python3 << 'ENDPY'
import json
import os

user_home = os.path.expanduser("~").replace("\\", "/")

with open('openclaw.json', 'r', encoding='utf-8') as f:
    config = json.load(f)

agents = [
    {"agentDir": f"{user_home}/.openclaw/agents/finance_main/agent", "id": "finance_main", "identity": {"emoji": "F01", "name": "F01 Financial Commander"}, "name": "finance_main", "subagents": {"allowAgents": ["finance_data", "finance_analysis", "finance_trading", "finance_monitor"]}, "tools": {"alsoAllow": ["read", "write", "sessions_spawn", "subagents", "web_search", "web_fetch", "memory_search", "memory_get", "memory_store", "agents_list"], "profile": "messaging"}, "workspace": f"{user_home}/.openclaw/workspace"},
    {"agentDir": f"{user_home}/.openclaw/agents/finance_data/agent", "id": "finance_data", "identity": {"emoji": "F02", "name": "F02 Data Collector"}, "name": "finance_data", "subagents": {"allowAgents": []}, "tools": {"alsoAllow": ["read", "write", "web_search", "web_fetch", "memory_search", "memory_get", "memory_store"], "profile": "minimal"}, "workspace": f"{user_home}/.openclaw/workspace"},
    {"agentDir": f"{user_home}/.openclaw/agents/finance_analysis/agent", "id": "finance_analysis", "identity": {"emoji": "F03", "name": "F03 Market Analyst"}, "name": "finance_analysis", "subagents": {"allowAgents": []}, "tools": {"alsoAllow": ["read", "write", "web_search", "web_fetch", "memory_search", "memory_get", "memory_store"], "profile": "minimal"}, "workspace": f"{user_home}/.openclaw/workspace"},
    {"agentDir": f"{user_home}/.openclaw/agents/finance_trading/agent", "id": "finance_trading", "identity": {"emoji": "F04", "name": "F04 Trading Executor"}, "name": "finance_trading", "subagents": {"allowAgents": ["finance_monitor"]}, "tools": {"alsoAllow": ["read", "write", "web_search", "web_fetch", "memory_search", "memory_get", "memory_store"], "profile": "minimal"}, "workspace": f"{user_home}/.openclaw/workspace"},
    {"agentDir": f"{user_home}/.openclaw/agents/finance_monitor/agent", "id": "finance_monitor", "identity": {"emoji": "F05", "name": "F05 Market Monitor"}, "name": "finance_monitor", "subagents": {"allowAgents": ["finance_main"]}, "tools": {"alsoAllow": ["read", "write", "web_search", "web_fetch", "memory_search", "memory_get", "memory_store"], "profile": "minimal"}, "workspace": f"{user_home}/.openclaw/workspace"}
]

for agent in agents:
    if not any(a.get('id') == agent['id'] for a in config['agents']['list']):
        config['agents']['list'].append(agent)

with open('openclaw.json', 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
ENDPY

echo ""
echo "🎉 安装完成！重启OpenClaw后使用 @finance_main 测试"
echo ""
