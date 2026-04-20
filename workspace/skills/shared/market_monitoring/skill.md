# Market Monitoring Skill

## 概述
提供7×24小时市场监控功能，实时跟踪价格变化、成交量异常、市场情绪等。

## 功能特性

### 价格监控
- 实时价格跟踪
- 价格突破告警
- 价格波动监控
- 支撑阻力位监控

### 成交量监控
- 异常成交量检测
- 成交量放大告警
- 流动性监控
- 买卖盘监控

### 市场情绪
- 涨跌统计
- 市场热度
- 资金流向
- 恐慌指数

### 告警系统
- 分级告警
- 实时推送
- 告警确认
- 告警历史

## API接口

### 开始监控
```python
start_monitoring(symbol, alert_conditions)
# symbol: 股票代码
# alert_conditions: 告警条件
# 返回: 监控会话ID
```

### 设置告警条件
```python
set_alert_condition(symbol, condition_type, threshold)
# condition_type: price_above, price_below, volume_spike, volatility_alert
# threshold: 触发阈值
```

### 获取监控状态
```python
get_monitoring_status(session_id)
# 返回: 当前监控状态和告警信息
```

### 停止监控
```python
stop_monitoring(session_id)
```

## 使用示例

### F05监控中使用
```python
# 设置价格监控
def monitor_price_alerts(symbol):
    conditions = {
        'price_above': 12.80,  # 价格突破12.80元告警
        'price_below': 11.50,  # 价格跌破11.50元告警
        'volume_spike': 2.0,   # 成交量放大2倍告警
        'volatility_alert': 5.0  # 5分钟内波动超过5%告警
    }
    
    session_id = start_monitoring(symbol, conditions)
    return session_id

# 实时监控循环
def monitoring_loop(symbols):
    while True:
        for symbol in symbols:
            current_data = get_realtime_data(symbol)
            
            # 检查告警条件
            alerts = check_alert_conditions(symbol, current_data)
            
            if alerts:
                for alert in alerts:
                    send_alert_to_F01(alert)
        
        time.sleep(10)  # 每10秒检查一次
```

### 分级告警处理
```python
def handle_alert_by_level(alert):
    level = alert['level']
    
    if level == 'INFO':
        # 信息级告警，记录即可
        log_alert(alert)
    
    elif level == 'WARNING':
        # 警告级告警，通知F01
        send_alert_to_F01(alert)
        log_alert(alert)
    
    elif level == 'CRITICAL':
        # 严重级告警，立即通知F01
        send_urgent_alert_to_F01(alert)
        log_alert(alert)
    
    elif level == 'EMERGENCY':
        # 紧急级告警，立即处理
        send_emergency_alert_to_F01(alert)
        trigger_emergency_protocol(alert)
```

### 异常检测
```python
def detect_anomalies(symbol, current_data, historical_data):
    anomalies = []
    
    # 价格异常检测
    price_change = (current_data['price'] - current_data['prev_close']) / current_data['prev_close']
    if abs(price_change) > 0.05:  # 波动超过5%
        anomalies.append({
            'type': 'price_volatility',
            'severity': 'WARNING' if abs(price_change) < 0.08 else 'CRITICAL',
            'value': price_change,
            'message': f'价格波动{price_change*100:.2f}%'
        })
    
    # 成交量异常检测
    volume_ratio = current_data['volume'] / historical_data['avg_volume_20']
    if volume_ratio > 2.0:  # 成交量放大2倍以上
        anomalies.append({
            'type': 'volume_spike',
            'severity': 'WARNING',
            'value': volume_ratio,
            'message': f'成交量放大{volume_ratio:.1f}倍'
        })
    
    # 跌破支撑位检测
    if current_data['price'] < current_data['support_level']:
        anomalies.append({
            'type': 'support_break',
            'severity': 'CRITICAL',
            'value': current_data['price'],
            'message': f'跌破支撑位{current_data["support_level"]:.2f}元'
        })
    
    return anomalies
```

## 告警级别定义

### INFO (信息)
- 价格达到预设目标
- 成交量轻微放大
- 技术指标信号
- **处理**: 记录并监控

### WARNING (警告)
- 价格波动超过3%
- 成交量异常放大
- 技术指标背离
- **处理**: 通知F01评估

### CRITICAL (严重)
- 跌破止损线
- 系统性风险爆发
- 流动性危机
- **处理**: 立即通知F01，准备紧急措施

### EMERGENCY (紧急)
- 触发强平线
- 系统故障
- 极端市场事件
- **处理**: 紧急平仓，系统保护

## 监控策略

### 长期监控
- 持续跟踪关注股票
- 定期生成监控报告
- 趋势变化提醒

### 事件监控
- 公司公告监控
- 行业新闻监控
- 政策变化监控

### 技术监控
- 技术形态监控
- 突破破位监控
- 背离信号监控

## 性能优化

### 数据更新频率
- 实时价格: 10秒更新一次
- 成交量: 30秒更新一次
- 技术指标: 1分钟更新一次
- 市场情绪: 5分钟更新一次

### 资源优化
- 使用增量更新
- 缓存历史数据
- 批量处理告警
- 优先级队列

## 注意事项

1. **持续监控**: 确保7×24小时不间断监控
2. **及时告警**: 发现异常立即告警
3. **准确判断**: 避免误报和漏报
4. **分级处理**: 根据严重程度分级处理
5. **历史记录**: 保存告警历史用于分析

## 紧急协议

### 触发条件
- 单日跌幅超过8%
- 跌破关键止损位
- 系统性风险事件
- 流动性枯竭

### 处理流程
1. 立即升级告警至F01
2. F01确认紧急状态
3. 直接调用F04紧急平仓
4. 事后分析和总结
