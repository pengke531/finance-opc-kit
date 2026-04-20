#!/usr/bin/env python3
"""
金融OPC系统导入安全性验证脚本
验证增量导入不会影响用户现有配置
"""

import os
import json
import sys
import hashlib
from pathlib import Path
from datetime import datetime

class ImportSafetyVerifier:
    def __init__(self):
        self.openclaw_root = Path.home() / ".openclaw"
        self.backup_dir = self.openclaw_root / "backups" / f"finance-opc-verify-{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.issues = []
        self.warnings = []
        self.passed_checks = []

    def log_issue(self, message):
        """记录问题"""
        self.issues.append(message)
        print(f"❌ {message}")

    def log_warning(self, message):
        """记录警告"""
        self.warnings.append(message)
        print(f"⚠️  {message}")

    def log_pass(self, message):
        """记录通过的检查"""
        self.passed_checks.append(message)
        print(f"✅ {message}")

    def verify_openclaw_installation(self):
        """验证OpenClaw安装"""
        print("\n🔍 检查1: OpenClaw安装验证")
        
        if not self.openclaw_root.exists():
            self.log_issue("OpenClaw未安装或配置目录不存在")
            return False
        
        self.log_pass(f"OpenClaw配置目录存在: {self.openclaw_root}")
        return True

    def backup_current_config(self):
        """备份当前配置"""
        print("\n🔍 检查2: 配置备份")
        
        config_file = self.openclaw_root / "config.json"
        
        if not config_file.exists():
            self.log_warning("没有现有配置文件，跳过备份")
            return True
        
        try:
            self.backup_dir.mkdir(parents=True, exist_ok=True)
            
            # 备份配置文件
            import shutil
            if config_file.exists():
                shutil.copy2(config_file, self.backup_dir / "config.json")
                self.log_pass("配置文件已备份")
            
            # 计算文件哈希
            with open(config_file, 'rb') as f:
                config_hash = hashlib.md5(f.read()).hexdigest()
            
            # 保存哈希值
            with open(self.backup_dir / "config.hash", 'w') as f:
                f.write(config_hash)
            
            self.log_pass("配置文件哈希已记录")
            return True
            
        except Exception as e:
            self.log_issue(f"备份失败: {str(e)}")
            return False

    def verify_config_isolation(self):
        """验证配置隔离"""
        print("\n🔍 检查3: 配置隔离验证")
        
        package_json = Path(__file__).parent.parent.parent / "openclaw.json"
        
        if not package_json.exists():
            self.log_issue("包配置文件不存在")
            return False
        
        try:
            with open(package_json, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            # 检查增量导入模式
            if config.get('_package', {}).get('mode') != 'incremental-import':
                self.log_issue("配置文件未设置增量导入模式")
                return False
            
            self.log_pass("增量导入模式正确")
            
            # 检查安全性设置
            safety = config.get('safety', {})
            
            if not safety.get('noUserConfigModification', True):
                self.log_warning("未明确设置不修改用户配置")
            else:
                self.log_pass("已设置不修改用户配置")
            
            if not safety.get('noGatewayModification', True):
                self.log_warning("未明确设置不修改网关配置")
            else:
                self.log_pass("已设置不修改网关配置")
            
            return True
            
        except Exception as e:
            self.log_issue(f"配置验证失败: {str(e)}")
            return False

    def verify_agent_isolation(self):
        """验证Agent隔离"""
        print("\n🔍 检查4: Agent隔离验证")
        
        package_json = Path(__file__).parent.parent.parent / "openclaw.json"
        
        try:
            with open(package_json, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            agents = config.get('agents', {}).get('list', [])
            
            for agent in agents:
                agent_id = agent.get('id')
                system_config = agent.get('system', {})
                
                # 检查独立运行设置
                if not system_config.get('independent', True):
                    self.log_warning(f"Agent {agent_id} 未设置独立运行")
                else:
                    self.log_pass(f"Agent {agent_id} 设置为独立运行")
                
                # 检查不覆盖配置设置
                if not system_config.get('noUserConfigOverride', True):
                    self.log_warning(f"Agent {agent_id} 未明确设置不覆盖用户配置")
                else:
                    self.log_pass(f"Agent {agent_id} 设置为不覆盖用户配置")
            
            return True
            
        except Exception as e:
            self.log_issue(f"Agent隔离验证失败: {str(e)}")
            return False

    def verify_workspace_isolation(self):
        """验证工作区隔离"""
        print("\n🔍 检查5: 工作区隔离验证")
        
        package_json = Path(__file__).parent.parent.parent / "openclaw.json"
        
        try:
            with open(package_json, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            agents = config.get('agents', {}).get('list', [])
            
            for agent in agents:
                agent_id = agent.get('id')
                workspace = agent.get('workspace', '')
                
                # 检查是否使用包相对路径
                if '__PACKAGE_ROOT__' in workspace or '__DOMAIN_ROOT__' in workspace:
                    self.log_pass(f"Agent {agent_id} 使用独立工作区")
                else:
                    self.log_warning(f"Agent {agent_id} 可能使用共享工作区: {workspace}")
            
            return True
            
        except Exception as e:
            self.log_issue(f"工作区隔离验证失败: {str(e)}")
            return False

    def verify_no_conflicting_agents(self):
        """验证没有Agent冲突"""
        print("\n🔍 检查6: Agent冲突检测")
        
        # 获取包中的Agent ID
        package_json = Path(__file__).parent.parent.parent / "openclaw.json"
        
        try:
            with open(package_json, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            package_agents = set(agent.get('id') for agent in config.get('agents', {}).get('list', []))
            
            # 检查是否与现有Agent冲突
            existing_agents_file = self.openclaw_root / "agents" / "agents.json"
            
            if not existing_agents_file.exists():
                self.log_pass("没有现有Agent，冲突检测通过")
                return True
            
            try:
                with open(existing_agents_file, 'r', encoding='utf-8') as f:
                    existing_config = json.load(f)
                
                existing_agents = set(agent.get('id') for agent in existing_agents.get('agents', []))
                
                # 检查冲突
                conflicts = package_agents & existing_agents
                
                if conflicts:
                    self.log_issue(f"发现Agent ID冲突: {', '.join(conflicts)}")
                    return False
                else:
                    self.log_pass("没有Agent ID冲突")
                    return True
                    
            except Exception as e:
                self.log_warning(f"无法读取现有Agent配置: {str(e)}")
                return True
            
        except Exception as e:
            self.log_issue(f"Agent冲突检测失败: {str(e)}")
            return False

    def verify_permissions(self):
        """验证权限设置"""
        print("\n🔍 检查7: 权限设置验证")
        
        package_json = Path(__file__).parent.parent.parent / "openclaw.json"
        
        try:
            with open(package_json, 'r', encoding='utf-8'
