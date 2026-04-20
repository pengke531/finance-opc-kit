# 金融OPC系统容错机制设计

## 容错体系架构

### 多层容错保护
```
用户操作层 (User Operation Layer)
    ↓
交易权限控制层 (Trading Authority Control)
    ↓
Agent协作保护层 (Agent Collaboration Protection)
    ↓
数据源容错层 (Data Source Failover)
    ↓
系统稳定性保障层 (System Stability Assurance)
```

## 一、交易权限控制系统

### 1.1 全局交易开关

#### 配置参数
```bash
# 配置文件路径
~/.openclaw/domains/finance-opc/.env

# 核心配置
TRADING_ENABLED=true           # 全局交易开关
TRADING_MODE=simulation        # 交易模式：simulation/live
EMERGENCY_STOP=false           # 紧急停止标志
```

#### 使用控制工具
```bash
# 查看当前状态
bash workspace/scripts/trading_control.sh status

# 启用交易权限
bash workspace/scripts/trading_control.sh enable

# 禁用交易权限
bash workspace/scripts/trading_control.sh disable

# 紧急停止所有交易
bash workspace/scripts/trading_control.sh emergency
```

### 1.2 个股交易控制

#### 黑名单管理
```bash
# 添加个股到黑名单
bash workspace/scripts/trading_control.sh stock-add 000001.SZ

# 从黑名单移除
bash workspace/scripts/trading_control.sh stock-remove 000001.SZ

# 查看黑名单
bash workspace/scripts/trading_control.sh stock-list
```

### 1.3 时间窗口控制

系统支持配置交易时间窗口，只允许在指定时间段执行交易。

## 二、Agent协作保护机制

### 2.1 权限边界保护

#### 严格权限矩阵
- **F01 (总指挥)**: 可调用任何Agent，最终决策权
- **F02 (数据收集)**: 只被动响应，不主动调用
- **F03 (市场分析)**: 只被动响应，不主动调用
- **F04 (交易执行)**: 只被动响应，向F05汇报
- **F05 (市场监控)**: 主动监控，只向F01报告

### 2.2 决策链保护

三重验证机制确保所有交易决策：
1. F01决策完整性检查
2. 风险检查确认
3. 交易参数合法性验证

### 2.3 循环依赖防护

调用链深度限制防止系统死锁：
- 最大调用链深度：5层
- 自动检测和阻止循环调用
- 超时自动中断机制

## 三、数据源容错机制

### 3.1 主备数据源切换

#### 数据源配置
- **主数据源**: Eastmoney API
- **备用数据源**: Sina Finance, Tencent Finance
- **自动切换**: 主数据源失败时自动切换到备用源

### 3.2 数据质量监控

异常数据检测包括：
- 价格异常波动检测（超过20%变动）
- 成交量异常检测（超过10倍变化）
- 数据完整性验证
- 多源交叉验证

## 四、系统稳定性保障

### 4.1 Agent健康监控

心跳检测机制：
- 每30秒检查Agent状态
- 60秒超时自动告警
- 自动故障恢复流程

### 4.2 自动故障恢复

故障恢复策略：
1. 尝试软重启
2. 尝试硬重启
3. 进入安全模式
4. 通知用户介入

### 4.3 资源管理

系统资源监控：
- CPU使用率超过90%自动降级
- 内存使用率超过90%自动清理
- 磁盘空间不足自动清理日志

## 五、用户操作保护

### 5.1 重要操作确认

关键操作需要二次确认：
- 买入/卖出操作
- 紧急停止操作
- 配置变更操作

### 5.2 操作审计

完整操作记录：
- 所有操作记录到日志
- 关键操作记录到审计日志
- 支持操作回溯和分析

## 六、故障恢复流程

### 6.1 网络故障处理

网络连接故障时的处理流程：
1. 检查网络连接状态
2. 切换到离线模式
3. 暂停实时数据更新
4. 定期尝试重连

### 6.2 数据异常处理

数据异常时的处理流程：
1. 暂停异常股票交易
2. 提高风险等级
3. 启动数据质量调查
4. 通知用户处理

### 6.3 灾难恢复

系统严重故障时的恢复流程：
1. 系统状态备份
2. 停止所有交易活动
3. 保存当前状态
4. 重新初始化系统
5. 恢复关键数据
6. 验证系统完整性

## 七、监控告警系统

### 7.1 告警级别

- **INFO**: 信息级，仅记录
- **WARNING**: 警告级，通知用户
- **CRITICAL**: 严重级，暂停操作
- **EMERGENCY**: 紧急级，停止所有交易

### 7.2 系统健康报告

定期生成系统健康报告，包括：
- Agent状态检查
- 数据源可用性
- 资源使用情况
- 告警汇总

## 使用示例

### 日常使用
```bash
# 每日检查系统状态
bash workspace/scripts/trading_control.sh status

# 启动交易
bash workspace/scripts/trading_control.sh enable

# 结束后禁用交易
bash workspace/scripts/trading_control.sh disable
```

### 紧急情况
```bash
# 立即停止所有交易
bash workspace/scripts/trading_control.sh emergency

# 查看状态确认
bash workspace/scripts/trading_control.sh status

# 恢复正常（需要人工确认）
bash workspace/scripts/trading_control.sh restore
```

---

**容错机制总结：**
- ✅ 七层容错保护体系
- ✅ 交易权全面可控
- ✅ Agent协作安全可靠
- ✅ 数据源多重备份
- ✅ 系统自动恢复
- ✅ 操作全程审计

**版本信息**：v1.0.0  
**最后更新**：2026-04-21
