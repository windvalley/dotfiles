.PHONY: help install stow unstow restow test clean validate fish plugins update lint

# 默认目标
.DEFAULT_GOAL := help

# 颜色定义
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
NC := \033[0m # No Color

# 配置
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
BIN_DIR := $(HOME)/.local/bin

# 标准包（通过 --dotfiles 选项处理）
STOW_PACKAGES := ghostty helix zellij mise git karabiner btop
# Fish 需要特殊处理
FISH_PACKAGE := fish
# Bin 目录特殊目标
BIN_PACKAGE := bin

help: ## 显示帮助信息
	@echo "$(BLUE)Dotfiles 管理工具$(NC)"
	@echo ""
	@echo "$(GREEN)安装:$(NC)"
	@echo "  $(YELLOW)make install$(NC)    运行安装脚本"
	@echo ""
	@echo "$(GREEN)同步配置:$(NC)"
	@echo "  $(YELLOW)make stow$(NC)       创建所有软链接（安装配置）"
	@echo "  $(YELLOW)make unstow$(NC)     删除所有软链接（卸载配置）"
	@echo "  $(YELLOW)make restow$(NC)     重新创建软链接（更新配置）"
	@echo ""
	@echo "$(GREEN)单独操作:$(NC)"
	@echo "  $(YELLOW)make stow-fish$(NC)  仅同步 Fish 配置"
	@echo "  $(YELLOW)make stow-bin$(NC)   仅同步 bin 脚本"
	@echo "  $(YELLOW)make stow-<pkg>$(NC) 同步指定包 (如: make stow-ghostty)"
	@echo ""
	@echo "$(GREEN)Fish Shell:$(NC)"
	@echo "  $(YELLOW)make fish$(NC)       设置 Fish 为默认 Shell"
	@echo "  $(YELLOW)make plugins$(NC)    安装/更新 Fisher 插件"
	@echo ""
	@echo "$(GREEN)macOS:$(NC)"
	@echo "  $(YELLOW)make macos$(NC)      配置 macOS 系统偏好设置"
	@echo ""
	@echo "$(GREEN)维护:$(NC)"
	@echo "  $(YELLOW)make validate$(NC)   验证所有配置文件语法"
	@echo "  $(YELLOW)make lint$(NC)       静态分析 bin/ 脚本 (shellcheck)"
	@echo "  $(YELLOW)make update$(NC)     更新 dotfiles 仓库"
	@echo "  $(YELLOW)make clean$(NC)      清理临时文件"
	@echo ""

install: ## 运行安装脚本
	@echo "$(BLUE)🚀 运行安装脚本...$(NC)"
	@./install.sh

stow: stow-packages stow-fish stow-bin ## 创建所有软链接
	@echo "$(GREEN)✅ 所有配置已同步$(NC)"

# 忽略常见系统文件
STOW_IGNORE := --ignore='\.DS_Store' --ignore='Thumbs\.db' --ignore='.*\.swp'

stow-packages: ## 同步标准包配置
	@echo "$(BLUE)📦 同步标准包配置...$(NC)"
	@for pkg in $(STOW_PACKAGES); do \
		if [ -d "$$pkg" ]; then \
			echo "  同步 $$pkg..."; \
			stow --restow --target=$(HOME_DIR) --dir=$(DOTFILES_DIR) $(STOW_IGNORE) --dotfiles $$pkg; \
		fi \
	done
	@echo "$(GREEN)  ✅ 标准包同步完成$(NC)"

stow-fish: ## 同步 Fish 配置
	@echo "$(BLUE)🐟 同步 Fish 配置...$(NC)"
	@stow --restow --target=$(HOME_DIR) --dir=$(DOTFILES_DIR) $(STOW_IGNORE) --dotfiles $(FISH_PACKAGE)
	@echo "$(GREEN)  ✅ Fish 配置同步完成$(NC)"

stow-bin: ## 同步 bin 脚本
	@echo "$(BLUE)🔧 同步 bin 脚本...$(NC)"
	@mkdir -p $(BIN_DIR)
	@stow --restow --target=$(BIN_DIR) --dir=$(DOTFILES_DIR) $(STOW_IGNORE) $(BIN_PACKAGE)
	@echo "$(GREEN)  ✅ bin 脚本同步完成$(NC)"
	@echo "  $(YELLOW)提示:$(NC) 确保 $(BIN_DIR) 在 PATH 中"

# 动态生成单独包的 stow 目标
$(foreach pkg,$(STOW_PACKAGES),stow-$(pkg)): ## 同步指定包
	@pkg=$(subst stow-,,$@); \
	if [ -d "$$pkg" ]; then \
		echo "$(BLUE)📦 同步 $$pkg...$(NC)"; \
		stow --restow --target=$(HOME_DIR) --dir=$(DOTFILES_DIR) $(STOW_IGNORE) --dotfiles $$pkg; \
		echo "$(GREEN)  ✅ $$pkg 同步完成$(NC)"; \
	else \
		echo "$(RED)  ❌ 包 $$pkg 不存在$(NC)"; \
		exit 1; \
	fi

unstow: ## 删除所有软链接
	@echo "$(BLUE)🗑️  删除所有软链接...$(NC)"
	@for pkg in $(STOW_PACKAGES) $(FISH_PACKAGE); do \
		if [ -d "$$pkg" ]; then \
			echo "  删除 $$pkg..."; \
			stow --delete --target=$(HOME_DIR) --dir=$(DOTFILES_DIR) --dotfiles $$pkg 2>/dev/null || true; \
		fi \
	done
	@echo "  删除 bin..."
	@stow --delete --target=$(BIN_DIR) --dir=$(DOTFILES_DIR) $(BIN_PACKAGE) 2>/dev/null || true
	@echo "$(GREEN)✅ 所有软链接已删除$(NC)"

restow: ## 重新创建所有软链接
	@echo "$(BLUE)🔄 重新创建软链接...$(NC)"
	@$(MAKE) unstow > /dev/null 2>&1
	@$(MAKE) stow
	@echo "$(GREEN)✅ 所有配置已更新$(NC)"

fish: ## 设置 Fish 为默认 Shell
	@echo "$(BLUE)🐟 设置 Fish 为默认 Shell...$(NC)"
	@if ! command -v fish > /dev/null 2>&1; then \
		echo "$(RED)  ❌ Fish 未安装$(NC)"; \
		exit 1; \
	fi
	@fish_path=$$(which fish); \
	if ! grep -q "$$fish_path" /etc/shells; then \
		echo "  添加 Fish 到 /etc/shells..."; \
		echo "$$fish_path" | sudo tee -a /etc/shells > /dev/null; \
	fi; \
	chsh -s "$$fish_path"
	@echo "$(GREEN)✅ Fish 已设置为默认 Shell$(NC)"
	@echo "  $(YELLOW)提示:$(NC) 重新登录后生效"

macos: ## 配置 macOS 系统偏好设置
	@echo "$(BLUE)🍎 配置 macOS 系统偏好设置...$(NC)"
	@./macos.sh

plugins: ## 安装/更新 Fisher 插件
	@echo "$(BLUE)🔌 安装/更新 Fisher 插件...$(NC)"
	@if ! command -v fish > /dev/null 2>&1; then \
		echo "$(RED)  ❌ Fish 未安装$(NC)"; \
		exit 1; \
	fi
	@if ! fish -c "type -q fisher" 2>/dev/null; then \
		echo "  安装 Fisher..."; \
		tmp=$$(mktemp); \
		curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish -o "$$tmp" && \
		fish -c "source '$$tmp' && fisher install jorgebucaran/fisher"; \
		rm -f "$$tmp"; \
	fi
	@if [ -f fish/dot-config/fish/fish_plugins ]; then \
		fish -c "fisher install (cat fish/dot-config/fish/fish_plugins)"; \
	fi
	@echo "$(GREEN)✅ Fisher 插件已更新$(NC)"

validate: ## 验证所有配置文件语法
	@echo "$(BLUE)🔍 运行工具验证...$(NC)"
	@./bin/validate-configs all 2>&1 || exit 1
	@echo "$(GREEN)✅ 所有配置文件验证通过$(NC)"

lint: ## 静态分析 bin/ 脚本 (shellcheck)
	@echo "$(BLUE)🔍 运行 shellcheck 静态分析...$(NC)"
	@if ! command -v shellcheck > /dev/null 2>&1; then \
		echo "$(RED)  ❌ shellcheck 未安装，请运行 'brew install shellcheck'$(NC)"; \
		exit 1; \
	fi
	@errors=0; \
	for script in bin/*; do \
		if [ -f "$$script" ] && head -1 "$$script" | grep -q "^#!.*bash"; then \
			if shellcheck -S warning "$$script" 2>/dev/null; then \
				echo "$(GREEN)  ✓$(NC) $$script"; \
			else \
				errors=$$((errors + 1)); \
			fi; \
		fi; \
	done; \
	if [ "$$errors" -eq 0 ]; then \
		echo "$(GREEN)✅ 所有脚本通过 shellcheck 检查$(NC)"; \
	else \
		echo "$(RED)❌ $$errors 个脚本存在问题$(NC)"; \
		exit 1; \
	fi

update: ## 更新 dotfiles 仓库
	@echo "$(BLUE)🔄 更新 dotfiles...$(NC)"
	@git pull --rebase
	@echo "$(GREEN)✅ 更新完成$(NC)"
	@echo "  $(YELLOW)提示:$(NC) 运行 'make restow' 应用最新配置"

clean: ## 清理临时文件
	@echo "$(BLUE)🧹 清理临时文件...$(NC)"
	@find . -type f -name '*.bak' -delete
	@find . -type f -name '*.tmp' -delete
	@find . -type f -name '*~' -delete
	@echo "$(GREEN)✅ 清理完成$(NC)"
