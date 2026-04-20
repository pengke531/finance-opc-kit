# Eastmoney API Skill

## 概述
提供东方财富API的数据获取功能，支持实时行情、历史数据、财务数据等。

## 功能特性

### 实时行情数据
- 获取股票实时价格
- 获取指数实时数据
- 获取期货实时数据
- 获取外汇实时数据

### 历史数据
- 日K线数据
- 周K线数据
- 月K线数据
- 分钟K线数据

### 财务数据
- 财务报表数据
- 财务指标数据
- 业绩预告数据
- 股东数据

## API接口

### 获取实时行情
```python
get_realtime_quote(symbol)
# 返回: {'symbol': '000001.SZ', 'price': 12.50, 'change': 2.5, 'volume': 1500000}
```

### 获取历史K线
```python
get_kline_data(symbol, period='daily', start_date, end_date)
# period: daily, weekly, monthly, 1min, 5min, 15min, 30min, 60min
```

### 获取技术指标
```python
get_technical_indicators(symbol, indicators=['MA', 'MACD', 'RSI'])
```

## 使用示例

### F02数据收集中使用
```python
# 获取实时行情
quote = get_realtime_quote('000001.SZ')
# 获取历史数据  
kline = get_kline_data('000001.SZ', period='daily')
```

### F03分析中使用
```python
# 获取技术指标进行分析
indicators = get_technical_indicators('000001.SZ', indicators=['MA', 'MACD', 'RSI'])
```

### F05监控中使用
```python
# 实时监控价格
quote = get_realtime_quote('000001.SZ')
if quote['price'] > alert_threshold:
    send_alert('price_alert', quote)
```

## 注意事项

1. 所有数据来自东方财富，仅供参考
2. 请遵守API使用条款
3. 重要决策前请验证数据准确性
