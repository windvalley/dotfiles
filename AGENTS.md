# 🤖 AGENTS.md

本文档为在当前代码库（`dotfiles`）中运行的 AI 编程助手（Agents）、Copilot 以及 Cursor 提供全局上下文、构建命令、代码规范和操作指南。请在执行任何读取或修改操作前仔细阅读并强制遵循本指南。

## 📦 项目背景与架构

本项目是一个高度定制化、基于 macOS 的现代终端开发环境配置文件集合。
- **核心工具栈**：Ghostty（终端容器）+ Zellij（终端复用与会话调度）+ Fish（友好的交互式 Shell）+ Helix（开箱即用的现代模态编辑器）+ Mise（全局与项目级环境/工具版本管理）。
- **部署方式**：所有配置均通过 Git 进行集中化版本控制，并使用 GNU Stow 创建符号链接（软链接）安全部署到 macOS 系统的对应目录（主要映射到 `~/.config/` 或 `~/.local/`）。
- **系统要求**：本项目仅适用于 macOS 环境，不兼容 Linux 或 Windows(WSL) 系统。请不要推荐或引入 Linux/Windows 特有的配置。

---

## 🛠️ 构建、测试与维护命令

由于这是一个 dotfiles 配置集合而非传统的业务代码库，本项目没有传统的单元测试框架（如 Jest/Pytest）。测试的本质是**语法检查 (Lint)** 和 **配置有效性集成验证 (Validate)**。所有的维护、安装与同步任务都通过根目录下的 `Makefile` 统一调度。

### 核心操作命令
- **`make install`**：运行 `./install.sh` 自动安装脚本。该脚本处理依赖并调用 stow 进行环境初始化。
- **`make stow`**：使用 GNU Stow 将所有子目录中的配置包软链接到系统目录。
- **`make restow`**：重新应用所有软链接。主要用于**首次部署、文件新增/删除/重命名、目录结构变更、软链接异常修复**等场景。对于已存在且已正确软链的文件，**仅修改内容通常无需执行**此命令。
- **`make unstow`**：删除当前所有由 Stow 管理的软链接映射。
- **`make lint`**：使用 `shellcheck` 对所有的 Shell 脚本（包括 `install.sh`, `bootstrap.sh`, `macos.sh` 以及 `bin/*` 下的所有命令）进行静态语法分析。（**这在本项目中等同于单元测试**）
- **`make validate`**：运行 `./bin/validate-configs all`。该命令会利用各工具自身提供的健康检查/配置检查命令，验证所有核心配置文件（Fish/Git/Zellij/Helix/Mise 等）的语法合法性。（**等同于集成测试**）
- **`make docs`**：使用 `doctoc` 重新生成 `README.md` 与 `README.en.md` 的目录结构。**如果在任何 PR 或提交中修改了 README / README.en.md 的标题（Markdown 标题层级），必须运行此命令**。
- **`make update`**：拉取最新的代码，并运行 `bin/dot-update` 更新底层工具链。
- **`make macos`**：应用 macOS 偏好设置脚本 (`macos.sh`)。

**⚠️ AI Agent 执行单次测试验证要求：**
- 场景 A：如果你新增或修改了 Bash/Shell 脚本，修改完成后**必须在后台运行**：`make lint`。
- 场景 B：如果你修改了某个工具（如 Helix, Zellij, Fish）的配置文件，修改完成后请尝试运行：`./bin/validate-configs <tool>` 或全局的 `make validate` 以确保无配置语法错误。

---

## 📝 代码风格与规范

### 1. Shell 脚本与命令规范
- **Shebang**：所有 Bash 脚本必须以 `#!/bin/bash` 开头，避免跨平台解释器行为差异。
- **安全执行模式**：所有 Bash 脚本在 Shebang 之后**必须**包含 `set -euo pipefail`。这确保了脚本在发生错误、访问未定义变量或管道任何一环失败时能够立即抛出异常并退出，避免产生破坏性后果。
- **日志输出约定**：绝对不要直接使用 `echo` 或 `printf` 打印普通信息文本。必须引入并使用项目中统一封装的彩色日志函数：
  - `info "..."` (蓝色，用于输出常规流程与提示)
  - `success "..."` (绿色，用于输出成功执行的结果)
  - `warn "..."` (黄色，用于输出警告与非致命异常)
  - `error "..."` (红色，用于输出致命错误，且通常伴随着 exit 1)
- **静态语法检查**：所有脚本代码在提交前，必须确保能 100% 通过 `shellcheck -S warning <file>` 的检查。严禁为了绕过检查而滥用 `# shellcheck disable=...`，除非能提供充分的理由。

### 2. 跨文件格式化规范 (EditorConfig)
项目根目录维护了一份严格的 `.editorconfig` 文件。作为 Agent，你生成的任何新文件或代码段**必须**遵循以下核心格式规则：
- **行尾序列 (End of Line)**：强制统一为 `LF`。
- **文件末尾空行**：所有文件末尾必须保留并插入一个空行（`insert_final_newline = true`）。
- **尾随空格**：每行末尾的多余空格必须移除（`trim_trailing_whitespace = true`）。
- **缩进规范**：
  - 大部分常规配置文件（`.md`, `.yml`, `.toml`, shell 脚本等）默认使用 **4个空格** 缩进。
  - 特殊文件如 `Makefile` 必须严格使用 **Tab** 作为缩进（`indent_style = tab`）。

### 3. 配置包封装与 Stow 目录结构设计
- **高度内聚**：所有需被管理的配置包均以独立目录存在于仓库根目录（如 `fish/`, `helix/`, `ghostty/`）。
- **路径映射**：配置包目录内的层级结构必须与目标操作系统的相对路径**绝对一致**。
- **点文件转换 (Dotfiles)**：本项目使用 GNU Stow 的 `--dotfiles` 参数特性。因此，代表隐藏文件或隐藏目录前缀的 `.` 需统一替换为 `dot-` 前缀。
  - *例如*：我们期望将 `fish` 配置映射到 `~/.config/fish/config.fish`。在仓库中，它的结构应当是 `fish/dot-config/fish/config.fish`。
- **约束边界**：**绝对禁止**将某一个工具的配置放入其专属包目录以外的地方。保持包级别的高度独立性，以便支持单独安装或单独卸载。

### 4. 敏感信息与隐私数据脱敏
- **禁止硬编码**：**绝对禁止**将系统级密码、API Keys（如 `OPENAI_API_KEY`, `GITHUB_TOKEN`）、个人的全名、真实邮箱或公司内部的敏感域名和内网信息硬编码在仓库中并提交。
- **私有隔离配置**：所有的隐私信息必须通过 `local/` 目录下的 `.example` 模板机制进行分离：
  - Git 用户相关隐私配置在 `~/.gitconfig.local` 或 `~/.gitconfig.work` 中进行重写。
  - Fish 环境下的私密环境变量、特定系统的 alias 均配置在 `~/.config/fish/config.local.fish` 文件内。
- 上述由模板生成的 `.local` 文件和后缀名已被项目根目录的 `.gitignore` 与全局的 `~/.config/git/ignore` 彻底忽略，保证了配置上云时的隐私安全。

### 5. 开发环境与工具版本管理 (Mise)
- **禁止全局污染**：**绝对禁止**在安装脚本、Makefile 或是命令别名中使用 `npm install -g`, `pip install`, `go install` 等方式全局安装工具。
- **基于沙箱的管理**：所有的语言运行时环境（如 Node, Python, Go, Ruby）和各个语言底层的语言服务器（LSP：例如 `vtsls`, `pyright`, `gopls`）**必须且只能**交由统一基座 `mise` 来集中管理。
- **Mise 全局配置位置**：修改全局工具请编辑 `mise/dot-config/mise/config.toml`。
- **例外约定**：仅针对与 macOS 系统平台紧密绑定的 C/C++/Rust 生态底层构建工具（如 llvm/clangd，或 rust-analyzer），才允许通过 Homebrew 进行系统级安装。

### 6. 命名约定与代码风格
- 变量命名尽量使用 `UPPER_SNAKE_CASE` (针对环境变量) 或 `lower_snake_case` (针对局部变量和函数)。
- 提供清晰的中文注释，注释不仅需要说明“是什么”，更重要的是说明“为什么”。
- 遵守开源社区常用的 Conventional Commits 规范来撰写 `git commit`。

---

## 🚦 AI Agent 与 Copilot 核心执行准则 (强制要求)

1. **先搜索定位，再进行修改**：在你准备向任何配置追加 alias（别名）、设置环境变量、或添加新的快捷键之前，**你必须**先使用 `Grep` 或工具内嵌搜索来检查代码库中是否已存在相似或冲突的定义。
   - *例如*：在增加新的 Fish alias 时，请先 grep 检索 `fish/dot-config/fish/` 目录；在给 Zellij 增加快捷键时，先检索 `zellij/dot-config/zellij/config.kdl`。
2. **遵守现有的生态习惯与极简主义设计**：
    - **关于布局**：终端的标签页 (Tab) 和面板 (Pane) 调度统一由 Zellij 负责管理，我们在 Ghostty 层面已废弃或不推荐使用原生标签功能。请不要配置冲突的行为。
    - **关于键位**：项目的快捷键设计倾向于 Vim 操作哲学与 Helix 现代编辑器风格，请保持键位映射的一致性。
    - **克制引入**：永远不要为了单纯实现某个特性而向用户推荐极其臃肿或花哨的第三方插件。本项目始终追求**开箱即用和极简主义**，依赖越少越好。
3. **Stow 软链映射的安全意识**：当需要修改配置时，务必注意文件所处的挂载状态。因为该环境可能已经执行过 `make stow`，很多 `~/.config/` 下的文件仅仅是软链接！
   - 你在修改配置时，**必须且只能**直接修改 dotfiles 仓库内（即 `/Users/xg/dotfiles/`）对应的原始源码文件。
4. **提交变更前的闭环验证**：在你向用户宣称代码或配置修改完成前，确保自己已经在后台静默执行过对应的 `make lint` 或是具体的 `validate-configs` 验证。
5. **项目文档双语同步**：根目录项目文档默认以中文 `README.md` 为主，同时维护与之 1:1 对应的英文版 `README.en.md`。**凡是修改项目说明、安装步骤、功能列表、命令说明、章节结构等 README 内容时，必须同步更新中英文两份文档，禁止只改其中一份**。若变更涉及标题层级或 TOC，完成后必须运行 `make docs` 以同步刷新中英文目录。
6. **任务完成后的用户引导**：请根据变更类型给出精确建议，而不是一律要求 `make restow`：
   - 若仅修改了已存在且已正确软链文件的内容：通常无需 `make restow`，提示用户按工具特性执行重载（如 `exec fish -l`、Ghostty 重载配置、重启对应进程）。
   - 若涉及新增/删除/重命名文件、包结构变更，或发现软链接异常：提示用户执行 `make restow` 重新应用映射。
