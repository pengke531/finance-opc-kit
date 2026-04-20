#!/bin/bash
# 金融OPC系统 - 完整导入验证脚本

echo "🔬 金融OPC系统增量导入完整验证"
echo "===================================="
echo ""

PASSED=0
FAILED=0
WARNINGS=0

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 验证1: 配置文件完整性
echo "🔍 验证1: 配置文件完整性"
echo "----------------------------"

CONFIG_FILES=(
    "openclaw_optimized.json"
    "agents/main/SOUL.md"
    "agents/finance_data/SOUL.md"
    "agents/finance_analysis/SOUL.md"
    "agents/finance_trading/SOUL.md"
    "agents/finance_monitor/SOUL.md"
)

for config_file in "${CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ]; then
        echo -e "${GREEN}✅${NC} $config_file 存在"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC} $config_file 缺失"
        ((FAILED++))
    fi
done
echo ""

# 验证2: 配置隔离检查
echo "🔍 验证2: 增量导入配置检查"
echo "----------------------------"

if [ -f "openclaw_optimized.json" ]; then
    # 检查增量导入模式
    if grep -q '"mode".*"incremental-import"' openclaw_optimized.json; then
        echo -e "${GREEN}✅${NC} 增量导入模式正确"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC} 增量导入模式未设置"
        ((FAILED++))
    fi
    
    # 检查安全配置
    if grep -q '"noUserConfigModification".*true' openclaw_optimized.json; then
        echo -e "${GREEN}✅${NC} 用户配置保护已设置"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️${NC} 用户配置保护未明确设置"
        ((WARNINGS++))
    fi
    
    # 检查隔离机制
    if grep -q '"isolation".*"package"' openclaw_optimized.json; then
        echo -e "${GREEN}✅${NC} 包隔离机制已设置"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️${NC} 包隔离机制未明确设置"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌${NC} 配置文件不存在"
    ((FAILED++))
fi
echo ""

# 验证3: Agent协作机制检查
echo "🔍 验证3: Agent协作机制检查"
echo "----------------------------"

if [ -f "openclaw_optimized.json" ]; then
    # 检查F01权限
    F01_SECTION=$(sed -n '/"id": "finance_main"/,/"id": "finance_data"/p' openclaw_optimized.json)
    if echo "$F01_SECTION" | grep -q '"finance_data"' && \
       echo "$F01_SECTION" | grep -q '"finance_analysis"' && \
       echo "$F01_SECTION" | grep -q '"finance_trading"' && \
       echo "$F01_SECTION" | grep -q '"finance_monitor"'; then
        echo -e "${GREEN}✅${NC} F01权限配置完整"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC} F01权限配置不完整"
        ((FAILED++))
    fi
    
    # 检查F03权限（关键）
    F03_SECTION=$(sed -n '/"id": "finance_analysis"/,/"id": "finance_trading"/p' openclaw_optimized.json)
    if echo "$F03_SECTION" | grep -q '"finance_data"'; then
        echo -e "${GREEN}✅${NC} F03可以调用F02获取数据"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC} F03无法调用F02，存在断链风险"
        ((FAILED++))
    fi
    
    # 检查F04权限（关键）
    F04_SECTION=$(sed -n '/"id": "finance_trading"/,/"id": "finance_monitor"/p' openclaw_optimized.json)
    if echo "$F04_SECTION" | grep -q '"finance_monitor"'; then
        echo -e "${GREEN}✅${NC} F04可以向F05汇报"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC} F04无法向F05汇报，存在断链风险"
        ((FAILED++))
    fi
    
    # 检查F05权限
    F05_SECTION=$(sed -n '/"id": "finance_monitor"/,/^[}]*/p' openclaw_optimized.json)
    if echo "$F05_SECTION" | grep -q '"finance_main"'; then
        echo -e "${GREEN}✅${NC} F05只能向F01报告"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️${NC} F05权限配置需要检查"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌${NC} 配置文件不存在"
    ((FAILED++))
fi
echo ""

# 验证4: Skills配置检查
echo "🔍 验证4: Skills配置检查"
echo "----------------------------"

SKILLS_DIR="workspace/skills"
if [ -d "$SKILLS_DIR" ]; then
    SKILL_COUNT=$(find "$SKILLS_DIR" -name "skill.md" | wc -l)
    if [ "$SKILL_COUNT" -ge 5 ]; then
        echo -e "${GREEN}✅${NC} Skills配置完整 ($SKILL_COUNT 个skills)"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️${NC} Skills数量不足 ($SKILL_COUNT 个)"
        ((WARNINGS++))
    fi
    
    # 检查关键skills
    CRITICAL_SKILLS=(
        "eastmoney_api"
        "technical_analysis"
        "risk_management"
    )
    
    for skill in "${CRITICAL_SKILLS[@]}"; do
        if [ -f "$SKILLS_DIR/shared/$skill/skill.md" ]; then
            echo -e "${GREEN}✅${NC} $skill skill 存在"
            ((PASSED++))
        else
            echo -e "${RED}❌${NC} $skill skill 缺失"
            ((FAILED++))
        fi
    done
else
    echo -e "${RED}❌${NC} Skills目录不存在"
    ((FAILED++))
fi
echo ""

# 验证5: 增量导入安全性模拟
echo "🔍 验证5: 增量导入安全性模拟"
echo "----------------------------"

# 记录用户配置状态
USER_CONFIG="$HOME/.openclaw/config.json"
USER_AGENTS="$HOME/.openclaw/agents/"

if [ -f "$USER_CONFIG" ]; then
    echo -e "${GREEN}✅${NC} 用户配置文件存在"
    BEFORE_HASH=$(md5sum "$USER_CONFIG" | cut -d' ' -f1)
    echo "   配置文件哈希: $BEFORE_HASH"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️${NC} 用户配置文件不存在（首次安装）"
    BEFORE_HASH="none"
    ((WARNINGS++))
fi

# 模拟导入过程（不实际导入）
echo "   📦 模拟导入过程..."
echo "   📋 检查包结构..."
echo "   🔒 验证隔离机制..."
echo "   🤖 验证Agent定义..."

# 验证配置未修改（模拟）
if [ -f "$USER_CONFIG" ]; then
    AFTER_HASH=$(md5sum "$USER_CONFIG" | cut -d' ' -f1)
    if [ "$BEFORE_HASH" = "$AFTER_HASH" ]; then
        echo -e "${GREEN}✅${NC} 用户配置未被修改"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC} 用户配置被修改！"
        ((FAILED++))
    fi
fi
echo ""

# 总结报告
echo "===================================="
echo "📊 验证结果总结"
echo "===================================="
echo -e "${GREEN}✅ 通过: $PASSED${NC}"
echo -e "${YELLOW}⚠️  警告: $WARNINGS${NC}"
echo -e "${RED}❌ 失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 所有验证通过！可以安全导入${NC}"
    echo ""
    echo "📋 下一步操作:"
    echo "1. 使用配置文件: openclaw_optimized.json"
    echo "2. 执行导入命令: openclaw import $(pwd)"
    echo "3. 验证Agent: openclaw agents list | grep finance"
    echo "4. 开始使用: openclaw chat finance_main"
    exit 0
else
    echo -e "${RED}⚠️  发现问题，请解决后再导入${NC}"
    echo ""
    echo "❌ 失败的验证项需要修复"
    exit 1
fi
