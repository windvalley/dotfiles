# Changelog

本项目遵循 [Semantic Versioning](https://semver.org/) 和 [Keep a Changelog](https://keepachangelog.com/) 规范。

> **版本号约定（`0.MINOR.PATCH`）**：项目处于 `0.x` 阶段，尚未发布稳定 API。
> - `MINOR`（x）= 新增功能或行为变更
> - `PATCH`（y）= Bug 修复、文档完善、代码清理

## [0.6.0] - 2026-02-24

### Added
- `install.sh` 新增 `--minimal` 模式：仅安装 fish + helix + git，跳过 GUI 应用和字体
- `colorscheme` 无参数时显示当前主题和可用主题列表
- `font-size` / `opacity` 无参数时显示当前设置值
- `config.fish` Zellij 自动启动增加 `zellij setup --check` 预检和失败逃生机制
- `CHANGELOG.md` 版本变更日志

### Fixed
- `.editorconfig` Shell 脚本 glob 语法修复（`[*.sh,bash,zsh}]` → `[*.{sh,bash,zsh}]`）
- `Makefile` 的 `STOW_PACKAGES` 补齐 `btop`
- `Makefile` 的 `plugins` 目标消除裸 `curl | source` 安全隐患
- `config.fish` 注释 typo 修正（"z 替代传统的 z" → "z 替代传统的 cd"）
- `colorscheme` 修正 4 个错误的 Ghostty 主题名（rose-pine / solarized-dark / one-dark / everforest）
- `install.sh` Fisher 安装改用临时文件下载，替代裸 `curl | source`

### Changed
- `colorscheme` 重构为数据驱动的 THEMES 数组，新增主题只需加一行（内置 10 个预设）
- `Makefile` 的 `stow-fish` 简化为与其他标准包一致的纯 `stow --restow`
- `macos.sh` sudo 保活机制改为 `trap EXIT` + `sudo -k` 主动吊销
- `macos.sh` 兼容 macOS 13+（System Settings / System Preferences 双重关闭）
- `README.md` 同步更新 `--minimal` 模式、colorscheme 新功能、Zellij 逃生机制文档

## [0.5.0] - 2026-02-24

### Added
- Fisher 插件路径隔离至 `~/.local/share/fisher`（`fisher_path`），保持 `~/.config/fish` 的 Git/Stow 纯洁性
- `install.sh` 中对所有 `CONFIG_PACKAGES` 统一执行目录级 stow 保护（backup + unlink）

### Changed
- `config.fish` 中 PATH 改用 `--path` 参数避免污染 Universal 变量
- EDITOR/VISUAL 改为可复刻的环境变量，不依赖 universal state

## [0.4.0] - 2026-02-22

### Added
- 核心设计哲学文档（配置即代码、终端即容器、声明式环境、心智减负）
- 本地私有配置分离机制（`.local.` 文件 + `includeIf` Git 多账号隔离）
- 致谢与 MIT 开源协议

### Changed
- 依赖检查与错误处理全面增强

## [0.3.0] - 2026-02-20

### Added
- `macos.sh` macOS 系统偏好设置脚本
- `install.sh` 非交互模式（`-y` / `--unattended`）
- `.editorconfig` 跨编辑器格式化标准
- `btop` 系统监控工具配置
- Helix `.conf` 文件语法高亮

### Changed
- TOML 验证脚本改进，增加 mise 配置注释

## [0.2.0] - 2026-02-19

### Added
- `Makefile` 集中化管理（stow/unstow/restow/validate/update/clean）
- `Brewfile` 声明式 Homebrew 依赖管理
- `validate-configs` 全工具链配置验证工具
- Nerd Fonts 集成

### Changed
- `bin/` 脚本统一迁移至 Bash
- 安装脚本安全性增强

## [0.1.0] - 2026-02-17

### Added
- 初始项目结构：Ghostty / Fish / Zellij / Helix / Mise / Git / Karabiner
- GNU Stow 软链管理
- Fisher 插件管理
- Tide prompt 配置
- Vi 模式与 Helix 插入模式绑定
- zoxide 智能目录跳转
- 自定义命令脚本（colorscheme / font-size / opacity / audio-volume / preview-md）
