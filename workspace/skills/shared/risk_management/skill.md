# Risk Management Skill

## 概述
提供风险管理和控制功能，包括仓位管理、止损止盈、风险计算等。

## 功能特性

### 仓位管理
- 计算合理仓位大小
- 集中度风险控制
- 资金分配优化

### 止损止盈
- 止损价格计算
- 止盈价格计算
- 动态止损调整

### 风险评估
- VaR (风险价值) 计算
- 最大回撤计算
- 波动率计算

### 风险监控
- 实时风险监控
- 风险预警
- 紧急止损

## API接口

### 计算仓位大小
```python
calculate_position_size(capital, risk_per_trade=0.02, stop_loss_price)
# capital: 总资金
# risk_per_trade: 单笔交易风险比例 (默认2%)
# stop_loss_price: 止损价格
# 返回: 建议仓位大小
```

### 计算止损价格
```python
calculate_stop_loss(entry_price, stop_loss_percent=0.08)
# entry_price: 买入价格
# stop_loss_percent: 止损百分比 (默认8%)
# 返回: 止损价格
```

### 计算止盈价格
```python
calculate_take_profit(entry_price, risk_reward_ratio=1.5)
# entry_price: 买入价格
# risk_reward_ratio: 风险收益比 (默认1.5)
# 返回: 止盈价格
```

### 计算组合风险
```python
calculate_portfolio_risk(positions)
# positions: 持仓列表
# 返回: 组合风险评估
```

## 使用示例

### F01决策中使用
```python
# 计算建议仓位
capital = 100000  # 总资金10万
entry_price = 12.50
stop_loss_price = 11.50

position_size = calculate_position_size(capital, 0.02, stop_loss_price)
# 假设止损1元，风险2%，则仓位 = 100000 * 0.02 / 1.0 = 2000元
# 可买股数 = 2000 / 12.50 = 160股

# 计算止损止盈
stop_loss = calculate_stop_loss(entry_price, 0.08)
# 12.50 * (1 - 0.08) = 11.50

take_profit = calculate_take_profit(entry_price, 1.5)
# 风险1元，收益1.5元，止盈 = 12.50 + 1.50 = 14.00
```

### F04执行中使用
```python
# 执行前风险检查
def validate_trade_risk(capital, position, portfolio):
    # 检查单笔仓位风险
    position_risk = position['value'] / capital
    if position_risk > 0.10:  # 单只股票不超过10%
        return False, "单笔仓位超过10%限制"
    
    # 检查行业集中度
    industry_risk = calculate_industry_concentration(portfolio, position['industry'])
    if industry_risk > 0.25:  # 单一行业不超过25%
        return False, "行业集中度超过25%限制"
    
    # 检查总仓位
    total_position = calculate_total_position(portfolio) + position['value']
    if total_position > capital * 0.80:  # 总仓位不超过80%
        return False, "总仓位超过80%限制"
    
    return True, "风险检查通过"
```

### F05监控中使用
```python
# 实时风险监控
def monitor_portfolio_risk(portfolio):
    for position in portfolio:
        current_price = get_realtime_price(position['symbol'])
        unrealized_pnl = calculate_unrealized_pnl(position, current_price)
        
        # 检查是否触发止损
        if current_price <= position['stop_loss']:
            send_urgent_alert('stop_loss_triggered', {
                'symbol': position['symbol'],
                'current_price': current_price,
                'stop_loss': position['stop_loss'],
                'action': 'immediate_sell'
            })
        
        # 检查是否达到止盈
        if current_price >= position['take_profit']:
            send_alert('take_profit_reached', {
                'symbol': position['symbol'],
                'current_price': current_price,
                'take_profit': position['take_profit'],
                'action': 'consider_selling'
            })
```

## 风险控制参数

### 仓位限制
- 单只股票最大仓位: 10%
- 单一行业最大仓位: 25%
- 总仓位上限: 80%
- 现金保留: 20%

### 止损止盈
- 默认止损: 8%
- 默认止盈: 15%
- 风险收益比: 最低1:1.5
- 动态止损: 盈利后调整为保本价

### 风险监控
- 最大日内回撤: 3%
- 最大月度回撤: 10%
- VaR限制: 95%置信度下不超过5%
- 波动率监控: 超过30%预警

## 风险计算方法

### 仓位计算
```
单笔风险金额 = 总资金 × 单笔风险比例 (2%)
仓位大小 = 单笔风险金额 / (买入价 - 止损价)
```

### 止损计算
```
固定止损: 止损价 = 买入价 × (1 - 止损比例)
ATR止损: 止损价 = 买入价 - ATR × 倍数
```

### 组合风险
```
总风险 = Σ(单笔仓位风险)
集中度风险 = Σ(同一行业仓位比例)
相关性风险 = 考虑股票相关性后的组合风险
```

## 注意事项

1. **风险第一**: 永远优先考虑风险控制
2. **严格执行**: 止损必须严格执行，不抱侥幸
3. **动态调整**: 根据市场情况调整风险参数
4. **分散投资**: 不要把鸡蛋放在一个篮子里
5. **定期评估**: 定期评估和调整风险策略

## 紧止情况处理

### 触发条件
- 单日亏损超过3%
- 黑天鹅事件
- 系统性风险爆发
- 流动性危机

### 处理措施
1. 立即停止所有交易
2. 评估当前风险状况
3. 必要时清仓避险
4. 事后分析和总结
