#!/bin/bash
# 金融OPC交易权限控制工具

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_FILE="$HOME/.openclaw/domains/finance-opc/.env"
BACKUP_DIR="$HOME/.openclaw/domains/finance-opc/backups"

show_help() {
    echo "🔧 金融OPC交易权限控制工具"
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "可用命令: status, enable, disable, emergency, stock-add, stock-remove, stock-list, simulation, live, backup, restore"
}

check_config_file() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}❌ 配置文件不存在${NC}"
        exit 1
    fi
}

get_config() {
    local key=$1
    grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"'
}

set_config() {
    local key=$1
    local value=$2
    if grep -q "^${key}=" "$CONFIG_FILE" 2>/dev/null; then
        sed -i "s/^${key}=.*/${key}=${value}/" "$CONFIG_FILE"
    else
        echo "${key}=${value}" >> "$CONFIG_FILE"
    fi
}

show_status() {
    echo -e "${BLUE}📊 金融OPC交易权限状态${NC}"
    trading_enabled=$(get_config "TRADING_ENABLED")
    if [ "$trading_enabled" = "true" ]; then
        echo -e "交易权限: ${GREEN}✅ 已启用${NC}"
    else
        echo -e "交易权限: ${RED}❌ 已禁用${NC}"
    fi
    echo ""
}

case "$1" in
    status) show_status ;;
    enable) set_config "TRADING_ENABLED" "true" && echo -e "${GREEN}✅ 交易权限已启用${NC}" ;;
    disable) set_config "TRADING_ENABLED" "false" && echo -e "${GREEN}✅ 交易权限已禁用${NC}" ;;
    help|--help|-h) show_help ;;
    *) echo "用法: $0 [命令]"; show_help ;;
esac
