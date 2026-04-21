#!/bin/bash
# 金融OPC系统导入安全性验证脚本

echo "🔬 金融OPC系统导入安全性验证"
echo "================================"

PASSED=0
WARNINGS=0
FAILED=0

# 检查1: OpenClaw安装
echo ""
echo "🔍 检查1: OpenClaw安装"
if [ -d "$HOME/.openclaw" ]; then
    echo "✅ OpenClaw配置目录存在"
    ((PASSED++))
else
    echo "❌ OpenClaw未安装或配置目录不存在"
    ((FAILED++))
fi

# 检查2: 配置文件存在性
echo ""
echo "🔍 检查2: 配置文件验证"
if [ -f "openclaw.json" ]; then
    echo "✅ 配置文件存在"
    ((PASSED++))
else
    echo "❌ 配置文件不存在"
    ((FAILED++))
fi

# 检查3: 增量导入模式
echo ""
echo "🔍 检查3: 增量导入模式"
if grep -q '"mode".*"incremental-import"' openclaw.json 2>/dev/null; then
    echo "✅ 增量导入模式正确"
    ((PASSED++))
else
    echo "❌ 增量导入模式未设置"
    ((FAILED++))
fi

# 检查4: 安全隔离设置
echo ""
echo "🔍 检查4: 安全隔离设置"
if grep -q 'noUserConfigModification' openclaw.json 2>/dev/null; then
    echo "✅ 安全隔离设置已配置"
    ((PASSED++))
else
    echo "⚠️  安全隔离设置未明确"
    ((WARNINGS++))
fi

# 总结
echo ""
echo "================================"
echo "📊 验证结果总结"
echo "================================"
echo "✅ 通过: $PASSED"
echo "⚠️  警告: $WARNINGS"
echo "❌ 失败: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "🎉 验证通过！可以安全导入金融OPC系统"
    echo ""
    echo "📋 下一步操作:"
    echo "1. 导入系统: openclaw import $(pwd)"
    echo "2. 验证导入: openclaw agents list | grep finance"
    echo "3. 开始使用: openclaw chat finance_main"
    exit 0
else
    echo ""
    echo "⚠️  发现问题，请解决后再导入"
    exit 1
fi
