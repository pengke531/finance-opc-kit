# Data Processing Skill

## 概述
提供金融数据处理功能，包括数据清洗、转换、计算、存储等。

## 功能特性

### 数据清洗
- 去除重复数据
- 处理缺失值
- 异常值处理
- 数据格式统一

### 数据转换
- 时间序列处理
- 频率转换
- 数据聚合
- 格式转换

### 数据计算
- 技术指标计算
- 财务指标计算
- 统计指标计算
- 自定义计算

### 数据存储
- 高效存储
- 索引优化
- 数据压缩
- 快速检索

## API接口

### 清洗数据
```python
clean_data(raw_data, rules)
# rules: 清洗规则
# 返回: 清洗后的数据
```

### 转换数据
```python
transform_data(data, target_format)
# target_format: 目标格式
# 返回: 转换后的数据
```

### 计算指标
```python
calculate_indicator(data, indicator_type, params)
# indicator_type: 指标类型
# params: 计算参数
# 返回: 计算结果
```

### 存储数据
```python
store_data(data, storage_type, metadata)
# storage_type: 存储类型
# metadata: 元数据
# 返回: 存储结果
```

## 使用示例

### F02数据收集中使用
```python
# 清洗原始数据
def clean_market_data(raw_data):
    cleaned = []
    
    for item in raw_data:
        # 去除重复数据
        if is_duplicate(item, cleaned):
            continue
        
        # 处理缺失值
        if has_missing_values(item):
            item = fill_missing_values(item)
        
        # 处理异常值
        if has_outliers(item):
            item = handle_outliers(item)
        
        # 格式统一
        item = normalize_format(item)
        
        cleaned.append(item)
    
    return cleaned

# 转换时间序列数据
def convert_to_timeseries(data, frequency='daily'):
    # 确保按时间排序
    data.sort(key=lambda x: x['timestamp'])
    
    # 根据频率聚合
    if frequency == 'daily':
        return aggregate_by_day(data)
    elif frequency == 'weekly':
        return aggregate_by_week(data)
    elif frequency == 'monthly':
        return aggregate_by_month(data)
```

### 数据验证
```python
def validate_data_quality(data):
    quality_score = {
        'completeness': 0,  # 完整性
        'accuracy': 0,      # 准确性
        'consistency': 0,   # 一致性
        'timeliness': 0     # 及时性
    }
    
    # 检查完整性
    total_fields = len(data[0])
    complete_records = sum(1 for record in data if all(record.values()))
    quality_score['completeness'] = complete_records / len(data)
    
    # 检查准确性
    accuracy_errors = 0
    for record in data:
        if record['high'] < record['low']:
            accuracy_errors += 1
        if record['volume'] < 0:
            accuracy_errors += 1
    quality_score['accuracy'] = 1 - accuracy_errors / len(data)
    
    # 检查一致性
    consistency_errors = 0
    for i in range(1, len(data)):
        if data[i]['timestamp'] <= data[i-1]['timestamp']:
            consistency_errors += 1
    quality_score['consistency'] = 1 - consistency_errors / len(data)
    
    # 检查及时性
    latest_record = data[-1]['timestamp']
    current_time = datetime.now()
    time_diff = (current_time - latest_record).total_seconds()
    quality_score['timeliness'] = max(0, 1 - time_diff / 300)  # 5分钟内算及时
    
    # 计算总体质量分数
    overall_quality = sum(quality_score.values()) / len(quality_score)
    
    return {
        'overall_quality': overall_quality,
        'details': quality_score,
        'grade': 'A' if overall_quality > 0.9 else 'B' if overall_quality > 0.8 else 'C'
    }
```

### 数据压缩存储
```python
def compress_and_store(data, symbol, data_type):
    # 数据压缩
    compressed_data = compress_data(data)
    
    # 生成元数据
    metadata = {
        'symbol': symbol,
        'data_type': data_type,
        'record_count': len(data),
        'date_range': (data[0]['date'], data[-1]['date']),
        'compression_ratio': len(compressed_data) / len(str(data)),
        'stored_at': datetime.now().isoformat()
    }
    
    # 存储数据
    storage_path = f"data/{symbol}/{data_type}/{datetime.now().strftime('%Y%m%d')}.compressed"
    store_to_disk(compressed_data, storage_path)
    
    # 更新索引
    update_index(symbol, data_type, storage_path, metadata)
    
    return metadata
```

## 数据质量标准

### 完整性
- 必须字段完整率 > 95%
- 可选字段完整率 > 80%
- 时间序列连续性 > 90%

### 准确性
- 价格数据准确率 > 99.9%
- 成交量数据准确率 > 99.5%
- 财务数据准确率 > 99%

### 一致性
- 时间戳一致性
- 数据格式一致性
- 逻辑一致性 (如high >= low)

### 及时性
- 实时数据延迟 < 3秒
- 日终数据延迟 < 1小时
- 财务数据延迟 < 1天

## 性能优化

### 批量处理
```python
def batch_process_data(data_list, batch_size=1000):
    results = []
    
    for i in range(0, len(data_list), batch_size):
        batch = data_list[i:i+batch_size]
        processed_batch = process_single_batch(batch)
        results.extend(processed_batch)
    
    return results
```

### 并行处理
```python
from concurrent.futures import ThreadPoolExecutor

def parallel_process_data(data, workers=4):
    with ThreadPoolExecutor(max_workers=workers) as executor:
        results = list(executor.map(process_single_record, data))
    
    return results
```

### 缓存机制
```python
# 缓存常用计算结果
@cache_result(ttl=3600)  # 缓存1小时
def calculate_expensive_indicator(data):
    # 复杂计算逻辑
    return result
```

## 错误处理

### 数据异常处理
```python
def handle_data_errors(data):
    error_types = {
        'missing_values': 0,
        'outliers': 0,
        'format_errors': 0,
        'logical_errors': 0
    }
    
    for record in data:
        # 处理缺失值
        if check_missing_values(record):
            error_types['missing_values'] += 1
            record = fix_missing_values(record)
        
        # 处理异常值
        if check_outliers(record):
            error_types['outliers'] += 1
            record = fix_outliers(record)
        
        # 处理格式错误
        if check_format_errors(record):
            error_types['format_errors'] += 1
            record = fix_format_errors(record)
        
        # 处理逻辑错误
        if check_logical_errors(record):
            error_types['logical_errors'] += 1
            record = fix_logical_errors(record)
    
    return data, error_types
```

## 注意事项

1. **数据质量第一**: 宁可不要数据，也不要错误数据
2. **及时处理**: 数据及时处理，避免积压
3. **备份重要**: 重要数据必须备份
4. **版本控制**: 数据处理过程要有版本控制
5. **性能监控**: 监控数据处理性能
