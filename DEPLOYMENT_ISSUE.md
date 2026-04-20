# 🚨 严重部署缺陷报告

## 问题发现

用户反馈指出金融OPC和法律OPC系统存在根本性部署缺陷：**导入后Agent无法被OpenClaw识别和调用**。

## 根本原因

经过分析OpenClaw系统的Agent加载机制，发现问题所在：

1. **配置未集成** - 提供的openclaw.json没有被合并到主配置
2. **目录结构缺失** - 没有创建~/.openclaw/agents/{agent_id}/目录
3. **路径配置错误** - 使用了未解析的变量和相对路径
4. **Agent未注册** - 没有在主配置的agents.list中注册

## 实际影响

用户"安装"后：
- ❌ OpenClaw无法识别新的Agent
- ❌ 无法调用任何Agent功能
- ❌ 只是无用的文件占用磁盘
- ❌ 系统完全不可用

## 修复方案

需要完全重新设计安装机制：

### 1. 创建Agent目录
```bash
~/.openclaw/agents/finance_main/
~/.openclaw/agents/finance_data/
~/.openclaw/agents/finance_analysis/
~/.openclaw/agents/finance_trading/
~/.openclaw/agents/finance_monitor/
```

### 2. 修改主配置文件
在~/.openclaw/openclaw.json的agents.list中添加Agent配置

### 3. 创建必要文件
每个Agent需要：SOUL.md, AGENTS.md, IDENTITY.md等

## 优先级: 🔴 Critical

这需要立即修复，所有用户都受影响。
