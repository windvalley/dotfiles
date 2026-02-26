# Changelog

本项目遵循 [Semantic Versioning](https://semver.org/) 和 [Keep a Changelog](https://keepachangelog.com/) 规范。

> **版本号约定（`0.MINOR.PATCH`）**：项目处于 `0.x` 阶段，尚未发布稳定 API。
> - `MINOR`（x）= 新增功能或行为变更
> - `PATCH`（y）= Bug 修复、文档完善、代码清理

## [Unreleased]

## [0.10.0] - 2026-02-26

### Added
- `zellij/config.kdl` 新增 `dracula-pro` 自定义主题：定义全部 UI 组件（`ribbon_*`、`frame_*`、`table_*`、`list_*`、`exit_code_*`、`multiplayer_user_colors`），自定义 `text_selected` 背景色以解决 Ghostty Dracula 配色下选中文本不可见的问题
- `.gitignore` 新增 `fish_variables` 规则：防止 Fish 自动管理的 universal 变量文件被意外提交

### Changed
- Git 配置迁移至 XDG 标准位置：`dot-gitconfig` → `dot-config/git/config`，`dot-gitignore` → `dot-config/git/ignore`，`excludesFile` 显式指向 `~/.config/git/ignore`
- `install.sh` 将 git 从 `STANDARD_PACKAGES` 移入 `CONFIG_PACKAGES`，统一走 `~/.config/` 目录级链接，消除 `$HOME` 直接映射的特例
- `bin/colorscheme` Delta 配置路径从 `$HOME/.gitconfig` 改为 `$config_home/git/config`
- `bin/validate-configs` Git 验证路径同步更新为 XDG 布局
- `bin/colorscheme` 将 dracula 的 Zellij 映射从内置 `dracula` 切换为自定义 `dracula-pro`，确保 `colorscheme dracula` 自动使用修复后的主题

## [0.9.0] - 2026-02-25

### Added
- `colorscheme` 扩展支持 Btop、Bat 和 Delta：THEMES 注册表从 4 列扩展为 6 列，新增 `btop` 和 `bat/delta`（共享 syntect 主题库）字段；`bat_cs_change` 通过 fish universal 变量设置 `BAT_THEME`；`delta_cs_change` 修改 `~/.config/git/config` 中的 `syntax-theme`
- `dot-gitconfig` 在 `[delta]` 区块下新增 `syntax-theme = Dracula`，由 `colorscheme` 脚本统一管理
- `b.fish` 新增 `b [query]` 函数：结合 `fzf` 模糊搜索与关键字精确过滤，选中后使用 `bat` 全屏语法高亮查看，与 `f` 函数设计风格完全一致

### Changed
- `colorscheme` 从 THEMES 注册表中移除 `catppuccin` 和 `rose-pine`（两者均无 btop 内置主题），预设主题数从 10 减为 8
- `colorscheme` 对 Bat/Delta 字段使用 `-` 作为"不支持"标记，遇到无内置 syntect 主题时静默跳过而非报错
- `btop/btop.conf` 设置 `save_config_on_exit = false`
- `config.fish` 移除 `abbr b bat`：`b` 已升级为交互式函数（`b.fish`），abbr 会产生冲突

## [0.8.0] - 2026-02-24

### Added
- 14 个全新的实用 Fish shell 函数，大幅提升终端工作流效率：
  - `f`: 结合 `fd`、`fzf` 和 `bat` 实现极速全屏文件搜索与预览，并直通 Helix 编辑器
  - `backup`: 为敏感文件或目录极速创建带有精确时间戳的安全备份
  - `copy`: 智能剪贴板工具，无缝将文件内容或管道流复制到 macOS 剪贴板
  - `extract`: 万能解压工具，自动识别压缩包后缀并调用对应命令解压
  - `gitignore`: 从 GitHub 官方库一键拉取标准 `.gitignore` 模板并输出
  - `lunar`: 使用 Python `zhdate` 库在终端渲染带生肖和干支的中国万年历
  - `mkcd`: 原生体验的创建目录并立即进入
  - `myip`: 获取本机局域网 IP 与公网 IP，并调用 `ipinfo.io` 获取精确地理位置
  - `port` / `ports`: 精确过滤并查看本地特定端口或所有正在监听的 TCP/UDP 进程
  - `proxy` / `unproxy`: 一键开启/关闭终端全局网络代理，加速通过终端访问外网
  - `rec`: 基于 `asciinema` 的极客录屏工具，支持一键安静录制、本地回放和网页分享
  - `wt`: 查询 3 日简易天气预报及风级指引
  - `c`: 命令发现入口，自动扫描 `functions/` 目录并提取 `-d` 描述，零维护列出所有自定义命令
  - `gtd`: 一键同时删除本地和远端的 Git Tag，避免手动执行两条命令

### Changed
- `README.md` 补充了全部新增实用函数的详细命令说明与用法

### Fixed
- Tide prompt vi_mode 指示符从错误的 `D` (Fish 内部名 default) 修正为 Vim 社区通用的 `N` (Normal)，并通过条件式 `set -U` 实现新机器自愈

## [0.7.0] - 2026-02-24

### Added
- `Makefile` 新增 `make lint` 目标：集成 shellcheck 对所有 `bin/` 脚本进行静态分析
- `Brewfile` 新增 `ripgrep`（极速正则搜索）和 `shellcheck`（Shell 脚本静态分析）
- `config.fish` 新增 `MANPAGER` 配置：通过 bat 实现 man 手册页语法高亮
- `dot-gitconfig` 新增 `rerere.enabled = true`：自动记忆冲突解决方案，提升 rebase 体验
- `validate-configs` 新增 Karabiner JSON 语法验证（`python3 -m json.tool`）
- `config.fish` 核心精简：将自定义函数（`d`, `nh`, `ch`）抽离为独立的 `functions/*.fish` 文件，利用按需加载（autoload）提升启动速度并在重构头部注释声明架构哲学

### Fixed
- `config.fish` 注释 typo 修正（`nvim` → `helix & zellij`）
- `install.sh` 移除 stow 后冗余的 `mkdir -p "$HOME/.config/fish"`
- `colorscheme` / `font-size` / `opacity` 修复 shellcheck SC2209 警告（`SED=sed` → `SED="sed"`）
- `validate-configs` 移除未使用的 `script_errors` 变量（shellcheck SC2034）
- `ghostty/config` 修复 `selection-word-chars` 因为缺少双引号导致的等号后导空格被丢弃 Bug，修改为仅保留制表符

### Changed
- `karabiner.json` 针对 HHKB 键盘（Vendor ID: 2131 PFU / 1278 Topre）自动禁用 Caps Lock 与 Left Control 的互换映射
- `config.fish` 清理残存的 `fish_config theme` 失效且产生误导的手动换题注释
- `README.md` 同步更新 Brew 依赖列表、Git 特性、validate-configs 描述、Makefile 命令表

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
