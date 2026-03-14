# Changelog

本项目遵循 [Semantic Versioning](https://semver.org/) 和 [Keep a Changelog](https://keepachangelog.com/) 规范。

> **版本号约定（`0.MINOR.PATCH`）**：项目处于 `0.x` 阶段，尚未发布稳定 API。
> - `MINOR`（x）= 新增功能或行为变更
> - `PATCH`（y）= Bug 修复、文档完善、代码清理

## [Unreleased]

## [0.24.0] - 2026-03-14

### Added
- 新增 Shottr 截图工具支持，并集成至全局快捷键体系
- 为 Karabiner-Element 添加右 Command 键截图快捷操作
- 为 macOS 环境添加触控板手势配置及多设备同步功能

### Changed
- 重构 Delta 主题配置，将主题文件拆分为独立配置文件
- 更新 mise 安装源为 GitHub Backend
- 优化 macOS 偏好设置与 Fish 别名配置
- 完善开发者 Agent 的编码标准与规则文档

### Fixed
- 修复 Fish Shell 中缺失 asciinema 依赖导致的录制功能异常


## [0.23.0] - 2026-03-13

### Added
- 全新的配色管理系统，支持交互式主题选择器，并深度集成至 Ghostty, Bat, Delta 及 Zellij。
- 丰富的预设主题库，新增 Catppuccin, Everforest, Dayfox, Kanagawa, One-dark, Rose-pine 等多套配色方案。
- 引入本地 AI 能力，通过集成 Ollama 为 AI PR 差异采样和 aichat 功能提供本地模型支持。
- Ghostty 终端增强功能，实现字体大小、透明度调节及主题变更的实时自动重载。
- Fish Shell 体验优化，增强 `gs` 别名以支持 Git 变更行数统计，并改进了主机提示信息。
- 自动化安装流程增强，新增对 `fd-find` 和 `karabiner-elements` 等工具的支持。

### Changed
- 架构重构：将本地配置文件统一迁移至 Home 根目录，提升配置的可移植性。
- 环境解耦：使 Zellij 工作区配置与具体路径无关，并标准化了所有 Shell 脚本的执行基准。
- 脚本强化：全面升级 `validate-configs` 验证脚本，确保配置的一致性与正确性。
- 文档体系重组：重构 README 结构，更新安装指南，并增加 AI 助手相关的软链接指引。

### Fixed
- 修复了 Gruvbox 主题在 Zellij 环境下的显示兼容性问题。
- 优化了配色方案的过滤机制，解决 Bat 与 Delta 在配置切换时的冲突。
- 修复了透明度数值验证逻辑及 Git 仓库根目录的检测算法。


## [0.22.0] - 2026-03-11

### Added
- 增强 Zellij 启动器 `zj`，新增支持在新终端窗口中创建或 attach session。
- Fish 终端新增双击 `Ctrl+D` 才会关闭 fish 会话的功能，避免默认的 Ctrl+D 直接关闭会话导致的误操作。
- 新增 Git 健康诊断工具 `gdoctor`，用于快速检查仓库状态。
- 扩展 Helix 编辑器功能，新增 Fish shell、Vue 以及 Docker Compose 的 LSP 语言服务支持。
- Fish 终端新增 `p` 命令，支持快速访问和管理剪贴板历史。

### Changed
- 优化 CLI 工具链管理架构，将依赖管理从 Homebrew 迁移至 mise。
- 改进 Fish 终端 `s` 搜索函数，优化了查询逻辑与结果选择体验。
- 优化 `zj` 命令的帮助输出信息，使其更加清晰易读。
- 规范化 README 文档结构，为第七章节标题增加了标准化编号。

### Fixed
- 修复 Fish 终端 `myip` 命令在特定网络环境下本地 IP 检测失效的问题。
- 修复天气查询工具 `wt` 对城市参数及全量显示参数的处理逻辑。


## [0.21.0] - 2026-03-10

### Added
- 深度重构 Fish Shell `s` 工具：引入子命令扩展框架，新增连接历史记录管理功能，并为所有核心函数集成了详尽的交互式帮助与用法说明。
- 增强 Zellij 终端集成：新增智能启动器（Smart Launcher）与项目布局（Project Layouts）支持，提升工作流环境切换效率。
- 完善用户手册：在 README 中补充了卸载指南、键盘驱动模式下的复制技巧以及常见问题（FAQ）汇总。

### Fixed
- 优化引导脚本：支持通过 `DOTFILES_DIR` 环境变量自定义配置目录，提升了在非标准路径下的安装灵活性。


## [0.20.0] - 2026-03-09

### Added
- 针对 macOS 平台下的 Fish shell 增加了命令行内容一键复制快捷键。
- 新增英文 README 文档并重构了全局目录索引，提升国际化支持。

### Changed
- 优化 Fish shell 交互体验，完善命令解析逻辑、输入校验及彩色输出反馈。
- 重构工具启动逻辑，将 Zellij 自动启动配置迁移并整合至 Ghostty 终端配置。
- 升级安装脚本与 CI 工作流，并同步更新安装指南和 Vi 模式快捷键说明文档。


## [0.19.0] - 2026-03-06

### Added
- 新增基于 Fish Shell 的交互式 SSH 主机选择器。
- 新增 AI 智能翻译工具函数 `t`。

### Changed
- 深度整合 AI 开发工作流，重构了 AI 客户端配置、快捷指令及 `aic` Git 提交辅助工具。
- 增强 Fish Shell 核心脚本功能，实现 `s` 函数的递归包含支持并优化了 Shell 缩写。
- 优化系统环境管理，完善插件安装校验机制并同步更新 mise 核心运行时。
- 更新并完善了 AI Agent 操作指南与 aichat 配置文档。


## [0.18.0] - 2026-03-05

### Added
- 集成 aichat CLI 及 Shell 绑定，为终端环境提供原生的 AI 交互支持。
- 新增 AI 驱动的命令诊断系统与智能化工作流，实现命令纠错、分析及自动化执行建议。

### Changed
- 统筹并标准化 AI 脚本工具链，重构底层执行逻辑以提升脚本维护性与执行效率。


## [0.17.0] - 2026-03-04

### Added

- **Ghostty**: 新增本地配置文件支持，用于管理私密设置 (`config.local` 机制)
- **Fish**: 全新 Git 缩写系统
  - 添加核心 Git 工作流缩写：`gb`（分支）、`gba`（全部分支）、`gbd`（删除分支）、`gcam`（提交并推送）、`gsta`/`gstp`（储藏操作）
  - 扩展高级 Git 工作流缩写
  - 添加 `gsw`/`gswm` 等分支切换别名
  - 为所有缩写添加描述信息和辅助函数，支持 `abbr --show` 查看说明
- **AI PR 助手 (aipr)**: 全新 AI 驱动的 Pull Request 描述生成器
  - Fish 集成：通过 `aipr` 命令一键生成 PR 描述
  - 依赖管理：新增 GitHub CLI (`gh`) 到 Brewfile
  - 完整文档：README 中新增 `gh` CLI 和 `aipr` 命令使用说明

### Fixed

- **aipr**: 修复临时文件泄漏问题，优化清理逻辑


## [0.16.0] - 2026-03-04

### Added
- 新增 Fish shell 下的 `aip` 命令，提供针对 AI Agents 高度优化的专属提示词整合支持。


## [0.15.0] - 2026-03-03

### Added
- 新增 AI Agent 全局上下文与代码执行指南文档，规范自动化辅助与开发流程。

### Changed
- 优化 Fish Shell 的 `wt` 命令，升级至高级 API 并提供全城市天气查询支持。
- 精简 Helix 编辑器键位配置，移除冗余的 `Ctrl+;` 快捷键映射。
- 重构并简化全局系统初始化配置，优化底层安装脚本与工具链的调度逻辑。

### Fixed
- 修复并增强核心构建脚本的执行健壮性与容错机制。


## [0.14.0] - 2026-02-28

### Added
- 集成 OpenCode 作为 mise 环境下的默认 AI 命令行工具。
- 升级 Fish shell 智能助手工具集 (aic/ait) 并同步更新配套文档。

### Changed
- 优化 GNU Stow 配置文件管理逻辑及系统更新自动化脚本。
- 调整 Helix 编辑器核心移动指令映射，交换 j/k 与 gj/gk 的绑定以优化操作流。

### Fixed
- 修复安装脚本在 CI/CD 等非交互式环境下因执行 shell 切换 (chsh) 导致的构建失败问题。


## [0.13.0] - 2026-02-27

### Added
- 新增 GitHub Actions CI 自动化工作流，持续集成部署能力全面升级
- 新增 `dot-update` 和 `bootstrap` 脚本，提供标准化的安装和更新流程
- 新增 Git clean filter 过滤器，实现主题配置的解耦管理

### Changed
- 重构 CI 任务结构，优化 fisher 安装逻辑
- 扩展 Makefile 的 shellcheck 检查范围，覆盖所有 shell 脚本
- 优化 macos.sh 中关于键盘重复、Finder 搜索和软件更新设置的注释说明

### Documentation
- README 添加项目徽章，并将 macos.sh 明确标记为可选组件


## [0.12.1] - 2026-02-27

### Fixed

- 修复 AI 命令执行中的命令注入漏洞


## [0.12.0] - 2026-02-27

### Added

- 新增 `aic` 命令，AI 辅助生成 Git 提交信息
- 新增 `ait` 命令，AI 辅助发布工作流，支持智能版本分析与 CHANGELOG 生成

### Changed

- 重构 Fish Shell 配置结构，提升可维护性


## [0.11.0] - 2026-02-26

### Added
- `Brewfile` 新增 `orbstack`：现代、轻量的 macOS 容器开发环境（替代 Docker Desktop/VirtualBox）
- `Makefile` 新增 `make docs` 自动化命令：通过使用 `npx markdown-toc -i README.md` 原地为过长的项目主文档生成且维护一层精美的高亮跳转大纲
- `README.md` 新增“与官方默认的关键差异”章节：系统梳理并公开了 Karabiner、Ghostty、Zellij、Fish、Helix、Git 六大核心工具的全部非默认定制，极大降低新用户的理解成本
- `README.md` 新增“配置即文档”核心理念：强调基于深度的中文注释实现配置即文档的立意，并澄清 `mise` 全局兜底与特定项目沙盒隔离的 LSP 管理版本观

### Changed
- `install.sh` 彻底移除 `-m`/`--minimal` 最小化安装模式，统一执行完整依赖安装与配置链接，大幅降低维护心智负担并保持体验一致性
- `config.fish` 针对通过 SSH 或 OrbStack 登入未配置相应 terminfo 的远程 Linux 时执行 `clear` 等程序报错 `unknown terminal type` 的问题，新增动态降级 `TERM` 为标准 `xterm-256color` 的命令别名 (alias) 修复方案；同时说明并保留了 `ghostty/config` 中默认的 `xterm-ghostty` 设置，以支持彩色波浪下划线等原生高级特性
- `helix/config.toml` 移除 Normal/Select 模式下 `C-h`/`C-l`（`extend_to_line_start`/`extend_to_line_end`）自定义快捷键绑定，选中到行首/行尾可用 Helix 内置 `vgh`/`vgl`
- `helix/config.toml` Normal/Select 模式新增 `Space + o`/`Space + i` 映射 `expand_selection`/`shrink_selection`（语法树节点扩展/收缩），替代被 Hammerspoon 占用的 `A-o`/`A-i`
- `.gitignore` 扩大 `fish_variables` 忽略范围为 `fish_variables*`，彻底隔离 Fish 并发落盘带来的持久化临时文件（僵尸文件）污染

### Removed
- `helix/languages.toml` 及 `mise/config.toml` 中彻底移除 `marksman`（基于 .NET 的重量级 Markdown LSP）：剥离过度臃肿的知识库链接能力，退回由 Tree-sitter 主导的轻盈纯正纯文本编辑体验

## [0.10.0] - 2026-02-26

### Added
- `zellij/config.kdl` 新增 `dracula-pro` 自定义主题：定义全部 UI 组件（`ribbon_*`、`frame_*`、`table_*`、`list_*`、`exit_code_*`、`multiplayer_user_colors`），自定义 `text_selected` 背景色以解决 Ghostty Dracula 配色下选中文本不可见的问题
- `.gitignore` 新增 `fish_variables` 规则：防止 Fish 自动管理的 universal 变量文件被意外提交

### Changed
- Git 配置迁移至 XDG 标准位置：`dot-gitconfig` → `dot-config/git/config`，`dot-gitignore` → `dot-config/git/ignore`，`excludesFile` 显式指向 `~/.config/git/ignore`
- `fish/dot-config/fish/completions/` 及 `conf.d/`：移除冗余静态补全文件并将其从 Git 中忽略，改为系统或运行时动态生成，保持仓库纯度
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
