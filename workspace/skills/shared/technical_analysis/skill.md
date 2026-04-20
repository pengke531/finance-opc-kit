# Technical Analysis Skill

## 概述
提供技术分析功能，支持各种技术指标计算和图表形态识别。

## 功能特性

### 趋势指标
- MA (移动平均线)
- EMA (指数移动平均线)
- MACD (指数平滑异同移动平均线)
- BOLL (布林带)

### 动量指标
- RSI (相对强弱指标)
- KDJ (随机指标)
- CCI (顺势指标)
- WR (威廉指标)

### 成交量指标
- VOL (成交量)
- OBV (能量潮)
- VR (成交量变异率)

### 形态识别
- 头肩顶/底
- 双顶/底
- 三角形整理
- 楔形形态

## API接口

### 计算移动平均线
```python
calculate_ma(prices, periods=[5, 10, 20, 30, 60])
# 返回: {5: [...], 10: [...], 20: [...], 30: [...], 60: [...]}
```

### 计算MACD
```python
calculate_macd(prices, fast=12, slow=26, signal=9)
# 返回: {'dif': [...], 'dea': [...], 'macd': [...]}
```

### 计算RSI
```python
calculate_rsi(prices, period=14)
# 返回: [...]
```

### 识别金叉死叉
```python
identify_cross_signal(fast_line, slow_line)
# 返回: 'golden_cross' 或 'death_cross' 或 'none'
```

## 使用示例

### F03市场分析中使用
```python
# 计算技术指标
prices = get_historical_prices('000001.SZ')
ma = calculate_ma(prices, periods=[5, 10, 20, 30, 60])
macd = calculate_macd(prices)
rsi = calculate_rsi(prices)

# 分析信号
if ma[5][-1] > ma[10][-1] and ma[10][-1] > ma[20][-1]:
    trend = "上升趋势"
elif ma[5][-1] < ma[10][-1] and ma[10][-1] < ma[20][-1]:
    trend = "下降趋势"
else:
    trend = "震荡趋势"

# MACD分析
signal = identify_cross_signal(macd['dif'], macd['dea'])
if signal == 'golden_cross':
    recommendation = "买入信号"
elif signal == 'death_cross':
    recommendation = "卖出信号"
```

### 综合分析
```python
def comprehensive_technical_analysis(symbol):
    # 获取价格数据
    prices = get_historical_prices(symbol)
    
    # 计算各类指标
    indicators = {
        'MA': calculate_ma(prices),
        'MACD': calculate_macd(prices),
        'RSI': calculate_rsi(prices),
        'BOLL': calculate_boll(prices)
    }
    
    # 综合判断
    signals = []
    
    # 趋势判断
    if indicators['MA'][5][-1] > indicators['MA'][20][-1]:
        signals.append('趋势向上')
    else:
        signals.append('趋势向下')
    
    # MACD判断
    if identify_cross_signal(indicators['MACD']['dif'], indicators['MACD']['dea']) == 'golden_cross':
        signals.append('MACD金叉')
    
    # RSI判断
    if indicators['RSI'][-1] > 70:
        signals.append('RSI超买')
    elif indicators['RSI'][-1] < 30:
        signals.append('RSI超卖')
    
    return {
        'symbol': symbol,
        'indicators': indicators,
        'signals': signals,
        'recommendation': generate_recommendation(signals)
    }
```

## 指标说明

### MA (移动平均线)
- 短期MA: 5日、10日
- 中期MA: 20日、30日
- 长期MA: 60日、120日、250日

### MACD
- DIF: 快线
- DEA: 慢线
- MACD: 柱状图
- 金叉: DIF上穿DEA，买入信号
- 死叉: DIF下穿DEA，卖出信号

### RSI
- 范围: 0-100
- 超买: RSI > 70
- 超卖: RSI < 30
- 强弱分界: 50

### BOLL (布林带)
- 上轨: 中轨 + 2倍标准差
- 中轨: 20日均线
- 下轨: 中轨 - 2倍标准差

## 注意事项

1. 技术指标存在滞后性，需结合其他分析
2. 不同市场环境下指标有效性不同
3. 需要综合考虑多个指标，不依赖单一指标
4. 注意假突破和假信号
