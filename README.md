# dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white) 
[![Ghostty](https://img.shields.io/badge/Ghostty-212121.svg?logo=ghostty&logoColor=white)](https://ghostty.org/) 
[![Zellij](https://img.shields.io/badge/Zellij-FF9800.svg)](https://zellij.dev/) 
[![Fish](https://img.shields.io/badge/Fish-4E5B3D.svg?logo=fishshell&logoColor=white)](https://fishshell.com/) 
[![Helix](https://img.shields.io/badge/Helix-5A5D7A.svg?logo=helix&logoColor=white)](https://helix-editor.com/) 
[![Mise](https://img.shields.io/badge/Mise-3e1e5b.svg)](https://mise.jdx.dev/) 
[![Stow](https://img.shields.io/badge/Stow-005090.svg?logo=gnu&logoColor=white)](https://www.gnu.org/software/stow/) 
[![CI](https://github.com/windvalley/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/windvalley/dotfiles/actions/workflows/ci.yml) 
[![License](https://img.shields.io/github/license/windvalley/dotfiles)](https://github.com/windvalley/dotfiles/blob/main/LICENSE)


[中文](README.md) | [English](README.en.md)

本项目是一套 **现代、高效、开箱即用** 的 macOS 终端开发环境，所有配置集中版本控制，通过 GNU Stow 一键部署。

核心工具栈：Ghostty（终端）+ Zellij（复用器）+ Fish（Shell）+ Helix（编辑器）+ Mise（版本管理）+ AIChat（终端 AI 助手），视觉与交互风格全栈统一。

**核心设计理念：**
1. **配置即代码**：所有配置通过 Git 追踪与 Stow 符号链接管理，支持一键幂等重置。
2. **终端即容器**：终端仅作渲染容器（Ghostty），会话与布局调度收敛于复用器（Zellij），代码编辑则交由开箱即用的现代编辑器（Helix），彻底消除插件拼凑的心智负担。
3. **环境即沙箱**：终结全局变量污染与多版本管理器的混乱，依靠统一基座在一处声明全部语言沙箱（Mise）。
4. **注释即文档**：本项目的每一个配置文件本身就是最详尽的说明书，包含深度的中文注释、设计取舍与最佳实践指引。
5. **AI驱动提效**：将AI大模型能力内建到命令行与常用工作流中，使终端环境具有AI原生能力，帮助提效。

> [!NOTE]
> 此 dotfiles 仅适用于 macOS，不兼容 Linux 或 Windows (WSL)，且没有跨平台适配计划。

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [0. TL;DR (快速开始)](#0-tldr-%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B)
- [1. 项目结构](#1-%E9%A1%B9%E7%9B%AE%E7%BB%93%E6%9E%84)
- [2. AI 能力](#2-ai-%E8%83%BD%E5%8A%9B)
- [3. 安装步骤](#3-%E5%AE%89%E8%A3%85%E6%AD%A5%E9%AA%A4)
  - [3.1 一键安装 (推荐)](#31-%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85-%E6%8E%A8%E8%8D%90)
  - [3.2 手动安装步骤 (可选)](#32-%E6%89%8B%E5%8A%A8%E5%AE%89%E8%A3%85%E6%AD%A5%E9%AA%A4-%E5%8F%AF%E9%80%89)
  - [3.3 卸载与恢复指南 (Uninstallation)](#33-%E5%8D%B8%E8%BD%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E6%8C%87%E5%8D%97-uninstallation)
- [4. 配置指南](#4-%E9%85%8D%E7%BD%AE%E6%8C%87%E5%8D%97)
  - [4.1 配置 fish](#41-%E9%85%8D%E7%BD%AE-fish)
  - [4.2 从 zsh 迁移](#42-%E4%BB%8E-zsh-%E8%BF%81%E7%A7%BB)
  - [4.3 本地私有配置 (不入库)](#43-%E6%9C%AC%E5%9C%B0%E7%A7%81%E6%9C%89%E9%85%8D%E7%BD%AE-%E4%B8%8D%E5%85%A5%E5%BA%93)
  - [4.4 配置 fisher](#44-%E9%85%8D%E7%BD%AE-fisher)
  - [4.5 配置 tide](#45-%E9%85%8D%E7%BD%AE-tide)
  - [4.6 macOS 系统偏好 (macos.sh) (可选)](#46-macos-%E7%B3%BB%E7%BB%9F%E5%81%8F%E5%A5%BD-macossh-%E5%8F%AF%E9%80%89)
  - [4.7 配置 Git](#47-%E9%85%8D%E7%BD%AE-git)
  - [4.8 配置 AIChat](#48-%E9%85%8D%E7%BD%AE-aichat)
- [5. 使用方法](#5-%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95)
  - [5.1 Ghostty 终端](#51-ghostty-%E7%BB%88%E7%AB%AF)
  - [5.2 Zellij 终端复用器](#52-zellij-%E7%BB%88%E7%AB%AF%E5%A4%8D%E7%94%A8%E5%99%A8)
  - [5.3 Fish Shell](#53-fish-shell)
  - [5.4 Helix 编辑器](#54-helix-%E7%BC%96%E8%BE%91%E5%99%A8)
  - [5.5 Mise 工具版本管理](#55-mise-%E5%B7%A5%E5%85%B7%E7%89%88%E6%9C%AC%E7%AE%A1%E7%90%86)
  - [5.6 Git 配置用法](#56-git-%E9%85%8D%E7%BD%AE%E7%94%A8%E6%B3%95)
  - [5.7 stow 的用法说明](#57-stow-%E7%9A%84%E7%94%A8%E6%B3%95%E8%AF%B4%E6%98%8E)
  - [5.8 自定义命令（bin/）](#58-%E8%87%AA%E5%AE%9A%E4%B9%89%E5%91%BD%E4%BB%A4bin)
  - [5.9 OrbStack（可选）](#59-orbstack%E5%8F%AF%E9%80%89)
- [6. 与官方默认的关键差异](#6-%E4%B8%8E%E5%AE%98%E6%96%B9%E9%BB%98%E8%AE%A4%E7%9A%84%E5%85%B3%E9%94%AE%E5%B7%AE%E5%BC%82)
  - [6.1 Karabiner 全局键位改造](#61-karabiner-%E5%85%A8%E5%B1%80%E9%94%AE%E4%BD%8D%E6%94%B9%E9%80%A0)
  - [6.2 Shottr 集成说明](#62-shottr-%E9%9B%86%E6%88%90%E8%AF%B4%E6%98%8E)
  - [6.3 Ghostty 终端行为与键位](#63-ghostty-%E7%BB%88%E7%AB%AF%E8%A1%8C%E4%B8%BA%E4%B8%8E%E9%94%AE%E4%BD%8D)
  - [6.4 Zellij 快捷键与会话架构](#64-zellij-%E5%BF%AB%E6%8D%B7%E9%94%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E6%9E%B6%E6%9E%84)
  - [6.5 Fish Shell 行为与键位](#65-fish-shell-%E8%A1%8C%E4%B8%BA%E4%B8%8E%E9%94%AE%E4%BD%8D)
  - [6.6 Helix 编辑器键位与显示](#66-helix-%E7%BC%96%E8%BE%91%E5%99%A8%E9%94%AE%E4%BD%8D%E4%B8%8E%E6%98%BE%E7%A4%BA)
  - [6.7 Git 工作流增强](#67-git-%E5%B7%A5%E4%BD%9C%E6%B5%81%E5%A2%9E%E5%BC%BA)
  - [6.8 macOS 系统偏好与触控板手势](#68-macos-%E7%B3%BB%E7%BB%9F%E5%81%8F%E5%A5%BD%E4%B8%8E%E8%A7%A6%E6%8E%A7%E6%9D%BF%E6%89%8B%E5%8A%BF)
- [7. 常用维护命令 (Makefile)](#7-%E5%B8%B8%E7%94%A8%E7%BB%B4%E6%8A%A4%E5%91%BD%E4%BB%A4-makefile)
- [8. 常见问题 (FAQ / Troubleshooting)](#8-%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98-faq--troubleshooting)
- [9. 致谢 (Acknowledgments)](#9-%E8%87%B4%E8%B0%A2-acknowledgments)
- [10. 开源协议 (License)](#10-%E5%BC%80%E6%BA%90%E5%8D%8F%E8%AE%AE-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 0. TL;DR (快速开始)

最简单的方法是使用一键安装脚本（Bootstrap），该脚本**专为首次安装设计**：

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/windvalley/dotfiles/main/bootstrap.sh)"
```

> [!NOTE]
> 如果目标目录 `~/dotfiles` 已存在，脚本出于安全保护会主动报错退出。
> 如需重新安装，建议先将旧目录备份移走（或自行决定删除）：`mv ~/dotfiles ~/dotfiles.bak`
> 如需安装到其他位置，可指定环境变量：`export DOTFILES_DIR=~/custom_path; curl ... | bash`

该脚本会自动安装 Homebrew（如果缺失）、ghostty、fish、zellij、helix、mise、stow, 并完成配置链接以及 Fish Shell 的初始化。

> [!TIP]
> 如果你的 `~/dotfiles` 已经克隆到本地，你可以放心地多次执行它里面的 `./install.sh`，它是幂等的，常用于更新依赖或修复软链接。
> 如果你想手动精准控制安装过程，请参考下面的详细步骤。


## 1. 项目结构

本仓库包含以下配置包及核心文件：

- `ghostty/`: [Ghostty](https://ghostty.org/)（/ˈɡoʊs.ti/，Ghost + ty）终端配置（现代、快速、GPU 加速）。
- `fish/`: [Fish](https://fishshell.com/)（/fɪʃ/，**F**riendly **I**nteractive **SH**ell）Shell 配置（友好、交互式、开箱即用）。
- `zellij/`: [Zellij](https://zellij.dev/)（/ˈzɛl.ɪdʒ/，源自阿拉伯语，马赛克瓷砖拼贴艺术）终端复用器配置（易于配置，支持多种布局）。
- `helix/`: [Helix](https://helix-editor.com/)（/ˈhiː.lɪks/，螺旋）现代模态编辑器配置（基于 Rust，极致响应，内置 LSP 支持）。
- `karabiner/`: [Karabiner-Elements](https://karabiner-elements.pqrs.org/)（/ˌkær.əˈbiː.nər/，德语，登山扣）键位映射（交换 Caps Lock 与 Left Control）。
- `git/`: Git 基础配置（包含高频别名、Delta 现代 Diff 美化、全局忽略、以及多账号隔离架构）。
- `mise/`: [Mise](https://mise.jdx.dev/)（/miːz/，源自法语 mise en place，就位准备）工具版本管理器配置（统一管理 Go、Node、Bun、Python、Lua、Rust 运行时及对应的 LSP / Formatter 工具链）。
- `aichat/`: [AIChat](https://github.com/sigoden/aichat) 终端 AI 客户端（集成多模型支持、命令生成/排错及工作流增强）。
- `bat/`: [bat](https://github.com/sharkdp/bat) 语法高亮分页器的自定义主题资源（供 `colorscheme` 同步 Bat / Delta 的 syntect 主题）。
- `btop/`: [btop](https://github.com/aristocratos/btop) 现代系统资源监控配置。
- `bin/`: 自定义命令脚本（自动链接到 `~/.local/bin`）
- `local/`: 本地环境私有配置模板（用于 Fish 环境变量脱敏、Git 多账号隔离及 Ghostty 私有配置）
- `Makefile`: 自动化构建与维护脚本
- `.editorconfig`: 跨编辑器格式化标准。内置了严格的格式控制（例如缩进模式、行尾序列 LF 强制设定、文件末空行保护等），确保项目源码整洁、消除跨平台和跨编辑器带来的格式问题。


## 2. AI 能力

本项目将 AI 大模型能力收敛到 **命令行编辑区**、**Git 工作流** 与 **日常效率工具**，形成统一入口和可复用的工具链（而不是零散 alias）。当前同时提供：

- `q`：直接走 Ollama 原生 CLI 的本地模型入口，默认关闭 thinking 输出
- 统一 AI 调度层：`Ctrl+y`、`?`、`??`、`aic`、`aipr`、`ait`、`t` 等工作流会按照 `~/.fish.local.fish` 中 `AI_CHAT_BACKENDS` 的顺序选择后端（例如 `q,aichat` 或 `aichat,q`）

AIChat 仍然负责 provider 聚合，支持 OpenAI / Claude / Gemini / 通义千问 / 智谱 / Moonshot 等主流模型；如果你愿意，也可以把它配置为通过 Ollama 的 `local-llm:` provider 使用本地模型。

**命令行智能体**：

| 入口 | 功能 | 说明 |
|------|------|------|
| `Ctrl+y` | 命令解释 | 输入命令后按下，bat 分页展示解释（仅解释不执行） |
| `# <描述>` + `Ctrl+y` | 命令生成 | 自然语言描述意图，生成多条候选命令，fzf 选择后写回命令行 |
| `?` | 快速生成 | 将自然语言交给统一 AI 调度层生成一条可执行命令（默认 `q -> aichat`） |
| `??` | 故障诊断 | 自动捕获上一条失败命令及终端输出，交给统一 AI 调度层诊断并给出修复建议（依赖 Zellij dump-screen） |
| `q [prompt]` | 本地直连 | 直接通过 Ollama 调用本地模型；默认模型来自 `AI_LOCAL_MODEL`，thinking 默认遵循 `AI_LOCAL_THINK`（未设置时为 `false`） |

**Git 工作流**：

| 命令 | 功能 | 说明 |
|------|------|------|
| `aic` | 提交信息 | 分析暂存区 diff，生成 Conventional Commits 风格消息，支持重写/微调/中英切换 |
| `aipr` | PR 描述 | 比较分支差异生成结构化 PR 描述，可复制到剪贴板或通过 `gh` 直接创建 PR |
| `ait` | 发版日志 | 分析上次 tag 以来的 commit，生成版本号与 CHANGELOG.md，自动提交并打 tag |

**日常效率**：

| 命令 | 功能 | 说明 |
|------|------|------|
| `t <text>` | 智能翻译 | 自动识别：英文单词→词典释义（音标+中英解释）；中文短词→英文候选；段落→互译 |
| `aip` | 指令库 | 交互式选择常用 AI 编程指挥语，支持 fzf 多选、按编号/关键词筛选，自动复制到剪贴板 |

**配置**：在 `~/.fish.local.fish` 中设置 `AI_CHAT_BACKENDS`、`AI_LOCAL_MODEL`、`AI_LOCAL_THINK`、`AICHAT_MODEL` 及 API Key，详见 [4.8 配置 AIChat](#48-配置-aichat)。


## 3. 安装步骤

### 3.1 一键安装 (推荐)

仓库根目录下提供了一个 `install.sh` 脚本，可以自动化完成绝大部分安装和配置工作。

**该脚本将执行以下操作：**
1. **环境准备**：检查并自动安装 **Homebrew**（如果尚未安装）。
2. **核心依赖**：读取 `Brewfile`，安装所有 CLI 工具（stow, zellij, fish, helix, mise, fzf 等）与 GUI 应用（Ghostty, OrbStack, Shottr, JetBrains Mono 字体等）。
3. **字体安装**：默认已通过 Brew 安装 JetBrains Mono，并**询问是否安装**其他扩展字体（Maple Mono, Geist Mono）。
4. **Shottr 快捷键（可选）**：如果检测到 `Shottr`，安装脚本会**询问是否写入**推荐的全局截图热键 `Shift + Cmd + 1/2/A/S`，避免静默覆盖你已有的快捷键习惯。
5. **软链配置**：自动识别已存在的配置并备份，然后使用 `stow` 将所有配置（含 `bin` 脚本）软链到对应的系统目录。
6. **AI 模型同步**：自动执行 `aichat --sync-models`，将默认配置引用的模型同步到本地索引。
7. **本地模型后端（可选）**：交互安装时会**询问是否安装并启动** `Ollama`；非交互模式默认跳过，可通过 `--with-ollama` 显式开启。脚本不会自动拉取任何本地模型。
8. **运行时安装**：通过 **Mise** 安装核心语言运行时（Go, Node, Bun, Python, Lua, Rust）、常用语言服务器与格式化工具（如 gopls、pyright、lua-language-server、stylua、vtsls 等），以及开箱即用的基础 CLI 工具（gh, bat, eza, fd, ripgrep, glow, shellcheck 等）。
9. **隐私配置模板**：自动在用户目录创建 Git 信息模板（`.gitconfig.local`/`.work`）、Fish 私密环境变量模板（`.fish.local.fish`）和 Ghostty 私有配置模板（`.ghostty.local`）。
10. **Shell 初始化**：将 **Fish** 设为默认 Shell，并在检测到明确 Zsh 使用痕迹时，按需迁移原 Zsh 的 PATH 环境变量到 Fish 中。
11. **插件配置**：安装 **Fisher** 插件管理器并同步所有 Fish 插件。
12. **系统优化**：提示是否应用 **macOS 常用系统偏好设置**（通过 `macos.sh`）。

**使用方法：**
```sh
git clone --depth=1 https://github.com/windvalley/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
./install.sh
```

> [!TIP]
> **非交互模式**：如果在自动化环境（如 CI/CD 等）中执行，可追加 `-y` 或 `--unattended` 标志跳过所有确认，并自动采用每个提示的默认答案：`./install.sh -y`
>
> 如需在非交互模式下同时安装本地模型后端，可显式追加 `--with-ollama`：`./install.sh -y --with-ollama`
>
> 若当前会话没有可复用的 `sudo` 凭证，`karabiner-elements` 会在 `-y` 模式下被自动跳过，以避免 Homebrew 的密码提示卡住安装流程；后续可在交互式终端中手动执行：`brew install --cask karabiner-elements`

**安装过程说明：**
- 如果系统未安装 Homebrew，脚本默认会**询问是否安装**
- 在 `-y` 模式下，默认值为 `y` 的步骤（如 Homebrew 安装）会自动执行，默认值为 `n` 的可选项（如扩展字体、`macos.sh`、Ollama）会自动跳过
- 如需手动安装 Homebrew，请访问 https://brew.sh
- 脚本会自动检测并迁移 zsh 的 PATH 设置到 fish


---

### 3.2 手动安装步骤 (可选)

如果你更倾向于手动操作，请按以下顺序执行：

#### 3.2.1 安装依赖项

```sh
# 软链管理工具
brew install stow

# 终端
brew install --cask ghostty@tip

# 多窗口管理
brew install zellij

# 交互 Shell
brew install fish

# 文本编辑器(替代 vim/neovim)
brew install helix

# 软件版本管理工具
brew install mise

# Git 美化工具 (Diff 语法高亮)
brew install git-delta

# 终端 AI 全能助手 (集成大模型与 Shell 辅助)
brew install aichat

# 现代、跨平台的系统资源监控工具
brew install btop

# 轻量级 macOS 截图标注工具
brew install --cask shottr

# 全局键位映射工具
brew install --cask karabiner-elements

# 字体
brew install --cask font-jetbrains-mono-nerd-font

# 常用工具
brew install fzf zoxide grc gawk gnu-sed grep

# 音量控制
brew install switchaudio-osx
```

**说明：**
- `aichat`: 终端上的大模型原生客户端，支持多模态及本地/云端模型。本配置提供 `Ctrl+y` 一键解释/生成命令（以 `#` 开头表示“描述 -> 生成命令”）。
- `zoxide`: 智能目录跳转工具，替代传统的 `cd`。用法：`z <关键词>` 跳转目录，`zi <关键词>` 交互式选择（需 fzf）。
- `gnu-sed`: 提供 `gsed`，用于 `colorscheme` / `font-size` / `opacity` 等脚本。
- `switchaudio-osx`: 提供 `SwitchAudioSource`，用于 `audio-volume`。
- `grc`: 通用彩色输出查看器 (Generic Colouriser)，配合 fish 插件为 `ping` / `ls` / `docker` / `diff` 等命令提供彩色输出增强。
- `shottr`: 默认集成的 macOS 截图标注工具，本身就是一套独立的截图与标注工作流，支持长截图、OCR 与贴图固定；根据 `Shottr` 官方当前授权条款，个人用途免费，商业用途需购买许可证。若想一键写入仓库建议的全局热键，可在拉取仓库后执行：`"$HOME/dotfiles/bin/configure-shottr-hotkeys" --force`

#### 3.2.2 拉取仓库

```sh
git clone --depth=1 https://github.com/windvalley/dotfiles.git "$HOME/dotfiles"

# 更新
cd "$HOME/dotfiles"
git pull --rebase
```

#### 3.2.3 链接配置（stow）

> [!TIP]
> 如果你的系统已安装 `make`，常规重同步可以直接运行 `make stow`。但首次安装，或 `~/.config/*` 下已存在真实目录时，优先使用 `install.sh`，因为目录备份与迁移保护逻辑在安装脚本中更完整。

如果坚持手动链接配置，为了确保 stow 能为 GUI 应用（如 Btop、Karabiner）以及扩展性强的工具创建纯净的**目录级软链**，需要对所有目标配置目录进行防御性清理：

```sh
# 如果目标工具的配置目录已经是真实目录（非软链），必须将其重命名或删除，切忌保留！
# 目的：确保 stow 时发现目标目录"不存在"，从而直接把整个目录映射为一个【纯目录级软链】。
# 否则 stow 会进入真实目录执行【文件级】软链，导致后续工具在本地新生成的文件脱离版本控制。
for pkg in ghostty helix zellij mise karabiner bat btop fish git aichat; do
    if [ -d ~/.config/$pkg ] && [ ! -L ~/.config/$pkg ]; then
        mv ~/.config/$pkg ~/.config/$pkg.bak
    elif [ -L ~/.config/$pkg ]; then
        unlink ~/.config/$pkg
    fi
done
```

然后执行统一链接映射：

```sh
cd "$HOME/dotfiles"

# 统一链接所有标准配置包（全部遵循 XDG 规范，映射到 ~/.config/ 下）
stow --restow --target="$HOME" --dir="$HOME/dotfiles" --dotfiles ghostty helix zellij mise karabiner bat btop fish git aichat

# 单独链接需要特定前置结构的包（例如将自定义命令放置在 ~/.local/bin 下）
mkdir -p "$HOME/.local/bin"
stow --restow --target="$HOME/.local/bin" --dir="$HOME/dotfiles" bin
```

#### 3.2.4 安装运行时与 CLI 工具（Mise）

依赖链接完成后，通过 `mise` 统一拉取所有配置好的工具链：

```sh
# 自动读取 ~/.config/mise/config.toml 并安装全部工具
mise install
```

### 3.3 卸载与恢复指南 (Uninstallation)

如果你在尝试后觉得本套配置不符合你的习惯，可通过以下步骤干净地卸载并恢复系统默认环境：

1. **取消所有软链接**：
   ```sh
   cd ~/dotfiles
   make unstow
   ```
2. **恢复系统默认 Shell**（例如改回 zsh）：
   ```sh
   chsh -s /bin/zsh
   ```
3. **还原备份的配置**：
   在最初执行 `install.sh` 时，脚本会自动将你原有的配置目录重命名为 `*.bak`（例如 `~/.config/fish.bak`）。你可以找到它们并把后缀去掉，以恢复原状。

---

## 4. 配置指南

### 4.1 配置 fish

将 fish 设为默认 shell：

```sh
which fish | sudo tee -a /etc/shells
chsh -s $(which fish)
```

重启终端后（或执行 `exec fish -l`），在 fish 里执行：

```fish
# 检查是否已经切换成功
echo $SHELL

# 生成命令补全（自动从 man 页面解析）
fish_update_completions

# 主题（只影响语法高亮，不影响 prompt；prompt 由 tide 控制）
fish_config theme choose dracula
```

> [!TIP]
> Homebrew 的 `bin/sbin` 路径已由仓库中的 `config.fish` 自动处理，通常不需要再手动执行 `fish_add_path (brew --prefix)/bin`。

### 4.2 从 zsh 迁移

> [!IMPORTANT]
> 从 zsh 切换到 fish 后，zsh 配置文件（`~/.zshrc`、`~/.zprofile` 等）中的 PATH 不会自动继承，可能导致已安装软件的命令找不到。

**自动迁移（推荐）**：`install.sh` 会先检查是否存在明确的 Zsh 使用痕迹（例如当前 shell 就是 zsh，或存在非空的 `~/.zshenv` / `~/.zprofile` / `~/.zshrc` / `~/.zlogin`）。只有命中这些信号时，才会提示是否把 zsh 中额外的 PATH 写入 `~/.fish.local.fish` 的托管区块里。

如果你当前已经长期使用 Fish，安装脚本会默认跳过这一步；这样路径来源依然可见、可编辑，也不会落到 `fish_user_paths` 这种仓库外的隐式 state。

如需复盘迁移覆盖率，可执行 `make path-audit`（或已同步到 `~/.local/bin` 后直接运行 `path-audit`）。该工具会同时对比 `zsh -l`、`zsh -il` 和 `fish -l` 的 PATH，明确标出哪些路径只存在于 `.zshrc` / 交互插件链里，因此不会被安装脚本自动迁移。

**手动迁移**：如需手动添加路径，建议也写进 `~/.fish.local.fish`：

```fish
# ~/.fish.local.fish
test -d "$HOME/.cargo/bin"; and fish_add_path --append --path "$HOME/.cargo/bin"
test -d "$HOME/.local/bin"; and fish_add_path --append --path "$HOME/.local/bin"
```

> [!TIP]
> 配置更新后执行 `exec fish -l` 即可生效。
> 可用 `printf '%s\n' $PATH` 查看当前所有路径。

### 4.3 本地私有配置 (不入库)

在实际使用中，我们经常需要配置一些**仅属于当前机器**或**包含敏感信息**的环境变量（例如 `OPENAI_API_KEY`、公司内网代理、特定机器别名等）。

为了防止这些信息被 Git 追踪并泄露到公开仓库中，本 dotfiles 已预设了本地分离机制：

#### Fish Shell 本地配置

1. 将本仓库中的示例模板复制到对应目录并去除 `.example` 后缀：
   ```fish
   cp ~/dotfiles/local/config.local.fish.example ~/.fish.local.fish
   ```
2. 将你所有的私密配置写入新生成的文件（下例中的模型名、API Key 和命令仅为占位示例，请替换为你自己的值，且不要把真实凭证提交回仓库）：
   ```fish
   # ~/.fish.local.fish
   # set -gx AICHAT_MODEL "gemini:gemini-3-flash-preview"
   # set -gx OPENAI_API_KEY "sk-xxxxxxxxx"
   # abbr -a -g work-vpn "sudo launchctl restart com.corp.vpn"
   ```

#### Ghostty 终端本地配置

1. 将本仓库中的示例模板复制到对应目录并去除 `.example` 后缀：
   ```bash
   cp ~/dotfiles/local/ghostty.config.local.example ~/.ghostty.local
   ```
2. 在新生成的文件中添加你的私密或特定机器配置（如快捷键、字体等）：
   ```ini
   # ~/.ghostty.local
   # 示例：按下 ctrl+backspace 自动输入占位文本并回车
   keybind = ctrl+backspace=text:<your-secret>\r
   ```

#### Git 本地多账号隔离配置

本项目 Git 配置采用“基础+本地覆盖”模式，通过 `include` 指令在不污染主仓库的前提下支持多身份：

1. **设置个人全局身份**：
   ```bash
   cp ~/dotfiles/local/dot-gitconfig.local.example ~/.gitconfig.local
   # 编辑 ~/.gitconfig.local 填入你的常用 Name 和 Email
   ```
2. **设置工作/特定目录身份**（可选）：
   ```bash
   cp ~/dotfiles/local/dot-gitconfig.work.example ~/.gitconfig.work
   # 编辑 ~/.gitconfig.work 填入工作邮箱，该配置仅对 ~/work/ 下的仓库生效
   ```

> [!NOTE]
> Fish 与 Ghostty 的本地私有文件现在直接放在 `$HOME` 根目录（`~/.fish.local.fish`、`~/.ghostty.local`），物理上独立于 dotfiles 仓库，不会随着 Stow 软链写回仓库工作树。

### 4.4 配置 fisher

fisher 是 fish 的插件管理器。
通过在 `config.fish` 中设置 `fisher_path`，所有插件相关的文件会被**彻底隔离**在 `~/.local/share/fisher` 下，避免污染 `~/.config/fish` 目录。

```fish
# ⚠️ 重要：安装前先清理 fisher_path 目录，避免残留数据导致安装冲突
rm -rf ~/.local/share/fisher

# 安装 Fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# 安装插件 (将从 dotfiles 配置列表中同步安装)
fisher install (cat ~/.config/fish/fish_plugins)
```

更多见：`fish/dot-config/fish/README.md`

### 4.5 配置 tide

tide 是 fish 的 prompt 插件。

```fish
# 一键自动化配置
tide configure --auto \
--style=Lean \
--prompt_colors='16 colors' \
--show_time='24-hour format' \
--lean_prompt_height='Two lines' \
--prompt_connection=Disconnected \
--prompt_spacing=Compact \
--icons='Many icons' \
--transient=Yes

# 或者交互式按照个人喜好配置
tide configure
```

### 4.6 macOS 系统偏好 (macos.sh) (可选)

根目录下提供了 `macos.sh` 脚本，利用 `defaults write` 一键配置符合开发者习惯的深层系统偏好：

- **键盘体验**：设置极速的键盘重复率（KeyRepeat），禁用长按显示特殊字符。
- **访达 (Finder)**：显示所有文件扩展名、状态栏、路径栏，按名称排序时文件夹置顶，禁用 `.DS_Store` 在网络/USB驱动器上的生成。
- **触控板/鼠标**：开启“轻点来点按”，关闭“用力点按”，并启用“三指拖移”（可用于文本选择与窗口拖动）。
- **程序坞 (Dock)**：开启自动隐藏，不显示最近使用的应用程序。

你可以随时通过运行以下命令来应用或重新应用这些设置：

```bash
make macos
# 或者 ./macos.sh
```

> [!WARNING]
> 该脚本包含了高度个人主观偏好的系统设定。
> **强烈建议你在执行前，先打开 `macos.sh` 快速浏览一遍带有详细中文解释的源码**。你可以轻松地注释掉任何与你习惯不符的 `defaults write` 命令。

### 4.7 配置 Git

**1. 配置用户信息及多账号分离 (Local Overrides)**

为了防止工作邮箱和个人邮箱混用，或意外泄露身份信息，本仓库的 `~/.config/git/config` 中**移除了硬编码的用户信息**，采用基于 `include` 特性的分离机制。

**设置个人全局身份（必须）：**
在你的 Home 目录创建被 Git 忽略的本地配置文件（可以将模板直接复制过去修改）：
```bash
cp ~/dotfiles/local/dot-gitconfig.local.example ~/.gitconfig.local
# 然后编辑 ~/.gitconfig.local，填入你的个人信息
```

**设置公司工作隔离身份（可选）：**
如果你在某台电脑上需要同时处理公司代码，假设你的工作目录全在 `~/work/` 及其子目录下，复制模板作为专属的工作配置：
```bash
cp ~/dotfiles/local/dot-gitconfig.work.example ~/.gitconfig.work
# 然后编辑 ~/.gitconfig.work，填入你的公司邮箱
```
只要你在这个目录进行 `git commit`，Git 会利用配置中的 `includeIf "gitdir:~/work/"` 条件自动切换到你的公司邮箱，彻底杜绝身份错误。

**2. 自定义全局忽略文件**

仓库中已包含通用的 `~/.config/git/ignore`（Git XDG 标准位置，自动发现）。如果你有特定的文件需要全局忽略（例如 IDE 配置、临时文件等），可以直接编辑该文件：

```bash
# 添加自定义忽略规则 (例如忽略所有 .log 文件)
echo "*.log" >> ~/.config/git/ignore
```

> [!TIP]
> 上述修改会直接更新 `~/dotfiles/git/dot-config/git/ignore`，建议将这些变更提交到你自己的 dotfiles 仓库中。

### 4.8 配置 AIChat

本项目已内置 AIChat 配置包，Stow 后会映射到 `~/.config/aichat/config.yaml`。

**1. 配置文件位置与职责**

- 仓库源文件：`~/dotfiles/aichat/dot-config/aichat/config.yaml`
- 生效路径：`~/.config/aichat/config.yaml`
- 职责边界：
  - `config.yaml` 负责行为策略（如 `stream`、`function_calling`、`save_session`、`keybindings` 等）
  - `install.sh` 会在 Stow 完成后自动执行一次 `aichat --sync-models`，避免默认配置引用的模型尚未同步到本地索引时出现“模型不存在”错误
  - API Key 与模型覆盖优先通过 Fish 本地私有文件注入（避免明文入库）

**2. 在本地私有文件中注入模型与密钥（推荐）**

```fish
# ~/.fish.local.fish
# 共享 AI 工作流默认优先顺序：本地 q -> aichat
set -gx AI_CHAT_BACKENDS "q,aichat"

# q 命令默认使用的本地 Ollama 模型
set -gx AI_LOCAL_MODEL "qwen3.5:35b"

# 本地 q / 本地优先工作流默认关闭 thinking；支持 false / true / low / medium / high
set -gx AI_LOCAL_THINK "false"

# provider 前缀示例：claude: / qianwen: / zhipuai: / moonshot: / openai: / gemini: / local-llm:
set -gx AICHAT_MODEL "gemini:gemini-3-flash-preview"
set -gx GEMINI_API_KEY "YOUR_API_KEY_HERE"
```

> [!IMPORTANT]
> 不要把任何 API Key 直接写入仓库中的 `aichat/dot-config/aichat/config.yaml`。私密信息只放 `~/.fish.local.fish`。

**3. 使用 Ollama 作为本地后端（可选）**

仓库现在同时提供 `q` 公共命令和统一 AI 调度层：

- `q` 直接走 Ollama 原生 CLI，适合你明确要本地模型且希望稳定关闭 thinking 的场景
- `Ctrl+y`、`?`、`??`、`aic`、`aipr`、`ait`、`t` 等共享工作流默认按 `AI_CHAT_BACKENDS` 指定的顺序尝试（默认推荐 `q,aichat`）
- 如果你希望 `aichat` 本身也使用某个本地 Ollama 模型，可以把 `AICHAT_MODEL` 设为 `local-llm:<model>`

```bash
# 交互安装时脚本会询问是否启用 Ollama；
# 无人值守安装可显式打开：
./install.sh -y --with-ollama

# 若只想单独手动安装，也可以直接执行：
brew install ollama
brew services start ollama

# 安装完成后，再按需拉取一个本地模型
ollama pull llama3.2
```

```fish
# ~/.fish.local.fish
# 本地 Ollama 无需 API Key
set -gx AI_CHAT_BACKENDS "q,aichat"
set -gx AI_LOCAL_MODEL "llama3.2"

# 可选：让 aichat 本身也使用某个本地 Ollama 模型
set -gx AICHAT_MODEL "local-llm:llama3.2"
```

如果你拉取的是其他模型，请先执行 `ollama list` 查看准确名称。只有当你希望 `aichat` 也能识别并使用该本地模型时，才需要确认模型名是否包含在 `~/.config/aichat/config.yaml` 的 `local-llm.models` 列表中；若不在，请按相同格式追加。

**4. 验证配置是否生效**

```fish
# 重载 fish 环境变量
exec fish

# 检查 AIChat 目录与数据隔离路径（由 fish/config.fish 统一设置）
aichat --info

# 如果启用了本地 Ollama，再检查 q 命令解析到的模型并直接调用
# 如果你只使用云端 aichat，可以跳过这一步
q --list-models
q hi

# 手动刷新官方模型索引
aichat --sync-models

# 检查模型清单
aichat --list-models

# 如果使用本地 Ollama，顺手确认本地服务与模型状态
ollama list

# 检查 aichat 本身是否可用
aichat hi
```

## 5. 使用方法

### 5.1 Ghostty 终端

**配置文件**：`~/.config/ghostty/config`

**注意**：标签页功能已禁用（由 Zellij 统一管理），多窗口功能仍可用。

**快捷键**：
| 快捷键 | 功能 |
|--------|------|
| `Cmd + Shift + ,` | 重载配置（修改配置文件后按此快捷键生效） |
| `Cmd + ;` | 打开 Quick Terminal（自定义快捷键）|
| `Cmd + n` | 新建窗口（纯 Fish 裸终端，不触发 Zellij 自动启动） |
| `Cmd + 点击` | 在裸 Ghostty（未进入 Zellij）中打开屏幕上的 URL |

> [!NOTE]
> 建议使用 Zellij 的标签页和面板功能替代 Ghostty 原生标签页和分屏功能，以获得更灵活的布局控制和跨会话保持能力。

---

### 5.2 Zellij 终端复用器

**配置文件**：`~/.config/zellij/config.kdl`

**自动启动**：本配置在 Ghostty 中（通过 `initial-command`）集成了 Zellij 启动逻辑，打开**首个**窗口时会自动启动或挂载到 Zellij 会话。若系统未安装 Zellij，则会自动 fallback 到纯 Fish 终端。通过 `Cmd + n` 新建的额外 Ghostty 窗口将保持为纯 Fish 裸终端，不会再次触发自动挂载，方便按需使用。

**模式系统**：Zellij 有多个模式，按 `Ctrl + p/t/n/h/s/o/a` 直接进入对应模式，按 `Ctrl + g` 进入锁定模式（禁用所有快捷键）。

**常用快捷键**：

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + g` | 进入/退出锁定模式（禁用所有快捷键） |
| `Ctrl + p` | 进入面板模式 |
| `Ctrl + t` | 进入标签页模式 |
| `Ctrl + n` | 进入调整大小模式 |
| `Ctrl + h` | 进入移动模式 |
| `Ctrl + s` | 进入滚动模式 |
| `Ctrl + o` | 进入会话管理模式 |
| `Ctrl + a` | 进入 TMUX 兼容模式 |

**面板模式 (Ctrl + p)**：
| 快捷键 | 功能 |
|--------|------|
| `h/j/k/l` | Vim 风格切换面板 |
| `d` | 向下拆分面板 |
| `r` | 向右拆分面板 |
| `n` | 新建面板 |
| `x` | 关闭当前面板 |
| `f` | 全屏/退出全屏 |

**标签页模式 (Ctrl + t)**：
| 快捷键 | 功能 |
|--------|------|
| `n` | 新建标签页 |
| `x` | 关闭当前标签页 |
| `1-9` | 切换到指定标签页 |
| `h/k` | 前一个标签页 |
| `l/j` | 后一个标签页 |

**调整大小模式 (Ctrl + n)**：
| 快捷键 | 功能 |
|--------|------|
| `h/j/k/l` | 增大对应方向的面板大小 |
| `H/J/K/L` | 缩小对应方向的面板大小 |
| `+/-` | 等比放大/缩小 |

**全局快捷键（无需进入模式）**：
| 快捷键 | 功能 |
|--------|------|
| `Cmd + 1-9` | 切换到指定标签页 |
| `Shift + Cmd + 点击` | 在 Zellij 会话中打开屏幕上的 URL（`Shift` 将鼠标点击交还给终端） |

**布局**：
- **默认布局**：`dev-workspace`（定义于 `~/.config/zellij/layouts/dev-workspace.kdl`），不绑定固定仓库路径，所有 pane 默认继承启动 Zellij 时的当前目录。
- **内置特定语言布局**：内置了 `layout-go`, `layout-rust`, `layout-python`, `layout-node`, `layout-cpp`, `layout-fullstack` 等专属工作区布局，提供开箱即用的分屏与功能标签页。
- **智能启动器**：使用本套配置定制的 `zj` 命令可在任意目录一键启动。它会自动探测当前目录特征并智能选择专属布局进行会话创建或挂载，同时基于当前工作上下文生成稳定会话名：如果当前目录位于 Git 仓库内，会自动归并到仓库级会话；普通目录则按当前目录区分会话。本命令已实现**深度终端感知**：在**裸终端**中直接启动；在**已有的 Zellij 会话内部**执行时，它会自动通过 Ghostty AppleScript API **打开一个全新的终端窗口**并在其中完成创建/挂载，优雅地避开了会话嵌套限制。通过此方式创建的多个 Ghostty 窗口/会话，可以使用 `Ctrl + \`` 快捷键进行快速来回切换。
- **手动加载布局**：`zellij --layout <布局名>`

---

### 5.3 Fish Shell

**配置文件**：`~/.config/fish/config.fish`

**Fish 常用命令**：
| 命令 | 功能 |
|------|------|
| `fish_update_completions` | 更新命令补全 |
| `fish_add_path <path>` | 添加路径 |
| `fish_config` | 打开交互配置 |

**自定义函数**（输入 `c` 查看函数列表，输入 `a` 查看缩写列表）：

| 命令 | 功能 |
|------|------|
| `c` | 【元命令】列出所有 Fish 自定义函数及其功能说明 |
| `a` | 【元命令】列出所有内置缩写 (Abbreviations) 及其功能说明 |
| `d` | 快速显示当前日期时间 |
| `nh <cmd>` | 后台运行命令，丢弃输出 (nohup 简写) |
| `ch <cmd>` | 查询 cheat.sh 快速获取命令帮助 |
| `wt [city]` | 查询 15 日详细天气预报表格（含 PM2.5/空气质量）。支持 `all` 参数并行查询多个城市摘要 |
| `lunar [date]` | 万年历，查询公历+农历+生肖+干支 (支持指定日期如 2025-01-29) |
| `myip` | 获取本机局域网 IP、公网 IP 及地理位置 |
| `port <num>` | 查看本地特定端口的 TCP/UDP 监听状态及进程情况 |
| `ports` | 查看本机所有正在监听的 TCP 端口及进程列表 |
| `extract <file>` | 万能解压缩工具，自动识别压缩包格式（zip, tar, gz, rar, 7z...）并解压 |
| `mkcd <dir>` | 创建目录并使用 cd 直接跳转进入 |
| `proxy` / `unproxy` | 一键开启/关闭终端全局网络代理 (用于解决代码拉取缓慢) |
| `gitignore <语言>` | 从 GitHub 模板快速输出标准项目 .gitignore 内容 (例: `gitignore Node`) |
| `backup <file/dir>` | 为敏感文件或目录极速创建带有精确时间戳的完整备份副本 |
| `copy [file]` | 将文件内容或前一个命令的标准输出(`\| copy`)极速复制到 Mac 剪贴板 |
| `f [query]` | 搜索文件并使用 Helix 打开。若关键字匹配唯一结果则直接打开 |
| `t <text>` | 智能翻译/释义：中文转英文；英文单词返回美式音标与中英释义；英文短文翻译成中文 |
| `aic` | 根据代码变更自动生成 Git 提交信息。底座为统一 AI 调度层，支持重写/微调 |
| `aipr` | 根据分支变更自动生成 Pull Request 描述。使用大模型分析 commit 和 diff |
| `ait` | 自动根据 Git 变更历史生成 Changelog 并提交打 Tag |
| `aip` | AI 即插即用指令库。交互式选择常用开发指挥语并自动复制到剪贴板 |
| `q [prompt]` | 直接通过 Ollama 运行 `AI_LOCAL_MODEL` 指定的本地模型；thinking 默认遵循 `AI_LOCAL_THINK`（未设置时为 `false`）；不带参数时进入交互会话 |
| `b [query]` | 搜索文件并使用 bat 查看。若关键字匹配唯一结果则直接打开 |
| `s [query]` | 从 `~/.ssh/config` 中解析 Host 列表，通过 fzf 交互选择并建立 SSH 连接 |
| `rec [name]` | 极简终端操作录屏工具 (基于 asciinema)，支持录制、回放(`rec play`)与网页分享(`rec upload`) |
| `gtd <tag>` | 一键同时删除本地和远端的 Git Tag |
| `gdoctor` | Git 仓库健康诊断工具：检测中断操作、工作区状态、远程同步、冗余分支、松散对象及数据完整性，并给出修复建议 |
| `lg` | 开启 `lazygit` 终端交互式管理器 |
| `zj` | 智能项目感知型 Zellij 启动器。会基于当前工作上下文生成稳定会话名；Git 项目内自动归并到仓库级会话，普通目录按当前目录区分。在 Zellij 内部运行时会自动打开新窗口以避开嵌套冲突 |

> [!TIP]
> **FZF 性能优化**：本项目已将 `fd` 集成为 `fzf` 的默认搜索后端。这意味着使用 `zi` 跳转或模糊搜索时不仅速度极快，且会自动遵循 `.gitignore` 规则。

**内置缩写 (Abbreviations)**：

缩写在输入后按空格时**自动展开**为完整命令。

| 缩写 | 展开为 | 实际含义 |
|------|--------|----------|
| `mkdir` | `mkdir -p` | 级联创建多级目录 (如果父目录不存在自动创建) |
| `ls` / `ll` | `eza` / `eza -l` | 现代版的文件列表显示 / 附带详细权限尺寸等信息 |
| `...` / `....` | `../..` / `../../..` | 极速向上跳转两层、三层父级目录 |
| `vi` / `vim` / `h` | `hx` | 统一唤起 Helix 现代文本编辑器 |
| `r` | `exec fish` | 重新加载当前 Fish 会话，快速使配置变更生效 |
| `cs`... | `colorscheme`... | 详情见自定义命令 `colorscheme`/`font-size`/`opacity`/`audio-volume` |
| `?` / `??` | `__ai_cmd` / `ai_diag_last` | 自然语言快速转命令（默认 `q -> aichat`） / 诊断上一条失败命令（依赖 Zellij dump-screen 捕获输出） |
| `g` | `git` | Git 基础命令调用入口 |
| `lg` | `lazygit` | 开启 `lazygit` 终端交互式管理器 |
| `ga` / `gs` | `git add` / `git_status_stats` | 添加文件到暂存区 / 查看状态并附带暂存区与未暂存区增删统计 |
| `gd` / `gds` | `git diff` / `git diff --staged` | 查看工作区尚未暂存的修改 / 查看暂存区里尚未提交的差异 |
| `gb` / `gba` / `gbd` | `git branch`... | 查看本地分支 / 查看全部(含远程)分支 / 强制删除分支 |
| `gc` / `gca` | `git commit` / `git commit --amend` | 提交代码 / 追加或修改最后一次提交 |
| `gcm` / `gcam` | `git commit -m` / `git commit -a -m` | 带信息提交代码 / 暂存所有已跟踪文件并提交代码 |
| `gp` / `gpl` | `git push` / `git pull` | 推送代码到远程仓库 / 拉取远程代码 |
| `gm` / `gms` | `git merge` / `git merge --squash` | 合并分支 / 将整条开发分支的多次提交合并压缩为一次改动 |
| `grb` / `grbc` / `grbi` | `git rebase`... | 变基分支 / 解决冲突后继续跑变基 / 交互式手工挑选、压缩变基 |
| `gco` / `gcl` | `git checkout` / `git clean -fd` | 检出分支或文件 (传统方式) / 清理未跟踪文件和目录（危险操作，请确认后使用） |
| `gsw` / `gswc` | `git switch` / `git switch -c` | 切换分支 / 创建并切换分支 (推荐的现代分支方式) |
| `gr` / `grh` | `git reset` / `git reset HEAD` | 重置暂存区或 HEAD 状态 / 仅重置暂存区 (撤销 add) |
| `gro` / `gros` | `git restore`... | 撤销工作区修改 / 撤销暂存区修改 (推荐的现代重置方式) |
| `gsta` / `gstp` | `git stash` / `git stash pop` | 雪藏当前未提交改动清空工作区 / 弹出并恢复雪藏内容 |
| `gt` / `gts` | `git tag` / `git tag -s` | 查看本地所有标签 / 创建带本地 GPG 签名的标签 |
| `gg` | `git log` | 查看原始 Git 提交日志 |
| `gl` | `git log --oneline --decorate --graph` | 【高频】带分支图谱路径、彩色树状结构的美化历史日志 |
| `glo` / `gls` | `git log --oneline` / `git log --stat` | 单行极简日志 / 附带每次提交具体增删文件统计信息的日志 |

> [!TIP]
> 忘记缩写了？随时输入 **`a`** 即可查看所有缩写及其对应的完整命令与功能描述。

**Vi 模式**：

Fish 支持 Vi 风格编辑模式，本配置已默认启用；以下按 normal 模式与 insert 模式分别列出。

**Normal 模式**：

进入 Vi normal 模式：按 `Esc` 或 `Ctrl+[`。

| 快捷键 | 功能 |
|--------|------|
| `i`/`a` | 进入插入模式 (光标前/光标后) |
| `h`/`l` | 光标左/右移动 |
| `k`/`j` | 上一条/下一条命令历史（基于输入过滤） |
| `w`/`b` | 下一个/上一个单词 |
| `0`/`$` | 行首/行尾 |
| `d` | 删除 (配合移动命令，如 dw, dd) |
| `y` | 复制 (配合移动命令，如 `yw`, `yy`) |
| `<Space>y` | 显式复制整条当前命令行到 macOS 系统剪贴板 |
| `p` | 粘贴 |
| `u` | 撤销 |
| `Ctrl+e` | 在普通模式下，使用当前默认编辑器 (hx) 全屏编辑当前命令行 |

**Insert 模式**：

| 快捷键 | 功能 |
|--------|------|
| `Esc` / `Ctrl+[` | 返回 Vi 普通模式 |
| `Ctrl+a` | 跳到行首 |
| `Ctrl+e` | 跳到行尾 |
| `Ctrl+f` / `Ctrl+b` | 光标右移 / 左移 |
| `Ctrl+n` / `Ctrl+p` | 下一条 / 上一条命令历史 |
| `Ctrl+h` / `Backspace` | 删除光标前一个字符 |
| `Ctrl+d` | 命令行有内容时删除光标所在字符；命令行为空时触发双击确认退出（500ms 内再按一次才退出，防止误关终端或 Zellij 面板） |
| `Ctrl+u` | 删除从光标到行首的内容 |
| `Ctrl+k` | 删除从光标到行尾的内容 |
| `Ctrl+w` | 删除光标前一个单词 |

---

### 5.4 Helix 编辑器

**配置文件**：`~/.config/helix/config.toml`

**新手指南**：[Helix 快速上手指南 (Neovim 用户版)](helix/dot-config/helix/README.md)

**模式**：Normal（正常）、Insert（插入）、Select（选择）

**核心快捷键**：

| 快捷键 | 功能 |
|--------|------|
| `i` | 进入插入模式 |
| `Esc` | 返回正常模式 |
| `v` | 进入/退出选择模式 |
| `h/j/k/l` | 左/下/上/右 |
| `w/b` | 下一个/上一个单词 |
| `gg/ge` | 文件开头/结尾 |
| `x` | 选中当前行 |
| `y/p` | 复制/粘贴 |
| `u/U` | 撤销/重做 |
| `/` | 搜索 |
| `n/N` | 下一个/上一个匹配 |
| `:w` | 保存 |
| `:q` | 退出 |
| `:wq` | 保存并退出 |

**LSP 功能**：
| 快捷键 | 功能 |
|--------|------|
| `gd` | 跳转到定义 |
| `gy` | 跳转到类型定义 |
| `gr` | 查看引用 |
| `gi` | 跳转到实现 |
| `Space+k` | 显示悬浮文档 |
| `Space+a` | 代码操作 |
| `Space+r` | 重命名符号 |
| `Space+s` | 文档符号列表 |
| `Space+S` | 工作区符号列表 |
| `Space+d` | 显示诊断信息 |
| `]d` / `[d` | 跳转到下/上一个诊断 |
| `Space+m` | Markdown 预览 (Glow) |

**LSP 配置**：
- **语言配置**：`~/.config/helix/languages.toml`
- **检查健康状态**：`hx --health` 或 `hx --health go`
- **安装 LSP**：
  本项目采用 `mise` 集中管理所有语言服务器，详情请参考 [5.5 Mise 工具版本管理](#55-mise-工具版本管理)。
- **重启 LSP**：`:lsp-restart`
- **查看文档**：`:config-open` 打开配置，`:config-reload` 重载

---

### 5.5 Mise 工具版本管理

**核心理念：**
摒弃传统通过 `npm i -g`, `pip install`, `go install` 全局滥装工具导致的系统污染和版本冲突。
本配置将常用运行时（Go/Node/Bun/Python/Lua/Rust）以及语言服务器、Formatter 等开发工具链**全部统一收敛交由 mise 管理**，实现两层优雅隔离：
1. **全局防灾保底**：全局配置 (`~/.config/mise/config.toml`) 中声明了常用语言的后备运行时，以及以 `@latest` 为主的 LSP / Formatter 工具链，保证了在任何普通目录打开编辑器都有充足的补全与格式化能力。
2. **纯净的项目级沙盒**：进入特定项目时，使用 `mise use` 可生成只对当前目录生效的 `.mise.toml` 进行精准隔离。
    - **关于 Runtime（运行环境）**：强烈建议锁定具体版本（如 `node@16`）以保证团队构建一致性。
    - **关于 LSP（语言服务器）**：通常建议在项目中也使用 `@latest` 获取最新的代码高亮、提示和性能优化；仅当最新版 LSP 与古董级老项目出现不兼容时，才妥协锁定 LSP 的旧版本。

**配置文件**：`~/.config/mise/config.toml`

> [!NOTE]
> **关于特殊 LSP 的说明**：
> 部分底层工具由于平台依赖较强或构建极其复杂（如 `rust-analyzer` 和 `clangd`），本配置**未通过 mise 管理**，仍建议通过 `brew` 安装以获得最佳稳定性和补全体验：
> - **Rust**: `brew install rust-analyzer`
> - **C/C++**: `brew install llvm` (包含 `clangd`)

**常用命令**：
| 命令 | 功能 |
|------|------|
| `mise install` | 根据当前目录 `.mise.toml` 或全局配置安装所有缺失工具 |
| `mise ls` | 列出当前生效及已安装的工具版本 |
| `mise ls-remote <tool>` | 查看该工具可配置的所有远程版本 |
| `mise use <tool>@<version>` | **在当前项目生成 `.mise.toml` 并使用特定版本** |
| `mise use -g <tool>@<version>` | 修改全局默认版本 |
| `mise current <tool>` | 查看当前环境实际激活的版本来源（本地/全局） |
| `mise prune` | 释放磁盘，清理不再使用的旧版本缓存 |
| `mise doctor` | 环境变量诊断，排查不生效的原因 |

**实战示例**：
```bash
# 查询可用版本并安装
mise ls-remote go
mise use -g go@latest

# 项目内实战最佳实践：锁定特定版 Runtime + 最新版 LSP
cd my-old-project
mise use node@16
mise use npm:@vtsls/language-server@latest

# 极端情况：由于项目太老，最新的 LSP 解析报错，被迫降级锁定特定版 LSP
cd my-ancient-project
mise use npm:@vtsls/language-server@1.0.0
```

---

### 5.6 Git 配置用法

> Git 初始配置（用户信息、多账号隔离等）请参见 [4.7 配置 Git](#47-配置-git)。

**配置文件**：
- `~/.config/git/config`: 核心行为配置（XDG 标准位置）
- `~/.config/git/delta-theme.conf`: Delta 视觉主题配置，由 `colorscheme` 统一维护
- `~/.config/git/ignore`: 全局忽略文件（XDG 标准位置）

**核心特性**：
- **Delta 集成**：使用 `git-delta` 进行 Diff 语法高亮，支持行号、并排显示和颜色优化；`syntax-theme` 与 Delta feature 已拆分到独立的 `delta-theme.conf` 中，由 `colorscheme` 脚本统一管理。
- **智能默认值**：
  - `pull.rebase = true`: 保持提交历史线性整洁。
  - `push.autoSetupRemote = true`: 自动关联远程分支。
  - `init.defaultBranch = main`: 默认分支名为 main。
  - `rerere.enabled = true`: 自动记忆冲突解决方案，提升 rebase 体验。

**常用别名**：
| 别名 | 命令 | 说明 |
|------|------|------|
| `git lg` | `log --graph ...` | 显示漂亮的提交图谱（精简版） |
| `git lga` | `log --graph ...` | 显示漂亮的提交图谱（详细版，含时间） |
| `git last` | `log -1 HEAD` | 查看最后一次提交 |
| `git cleanup` | `branch --merged \| xargs -n1 branch -d` | 清理已合并的本地分支 |

---

### 5.7 stow 的用法说明

```sh
# 安装或重新安装
#
#  -nv 模拟安装（查看会做什么，但不实际执行）;
#  --restow 重新安装（即重新创建符号链接，先删除再创建）;
#  --target 指定符号链接目标目录;
#  --dir 指定 dotfiles 源文件目录;
#  --dotfiles 将 dot- 开头的包名转换为 . 开头的隐藏文件
#
# 示例：
stow -nv --restow --target=$HOME --dir=$HOME/dotfiles --dotfiles ghostty

# 卸载
stow -nv --delete --target=$HOME --dir=$HOME/dotfiles --dotfiles ghostty
```

---

### 5.8 自定义命令（bin/）

这些命令会在 stow `bin` 后出现在 `~/.local/bin`：

- `colorscheme [name]`: 同步切换 Ghostty、Helix、Zellij、Btop、Bat 和 Delta 主题。无参数时显示当前主题和可用主题列表，内置 14 个预设（dracula / catppuccin / catppuccin-latte / rose-pine / tokyonight / gruvbox / gruvbox-light / kanagawa / nord / solarized / one-dark / everforest / everforest-light / dayfox）；其中 `catppuccin` 统一映射到 `Macchiato` 变体，`catppuccin-latte` 统一映射到 `Latte` 变体，`rose-pine`、`kanagawa`、`one-dark`、`everforest`、`everforest-light` 与 `dayfox` 都会为 Bat / Delta 启用仓库内置主题资源；`tokyonight` 会为 Bat 使用仓库内置的自定义 syntect 主题，并为 Delta 启用官方 Tokyo Night feature；`solarized` 预设会统一映射到各工具对应的深色 Solarized 变体。额外支持 `-i` / `--interactive`（依赖 `fzf`，默认定位到当前预设，移动光标即可实时切换主题，按回车或 `Esc` 退出）、`--current`、`--list`、`--help`。**配合 Git Clean Filter，切换主题不会导致仓库变脏。**
- `dot-theme-filter`: **Git 内部过滤器（非直接执行）**。配合 `.gitattributes` 使用，在 `git add` 时自动将主题、Ghostty 字体大小、Ghostty 背景透明度等本地显示偏好还原为默认值，实现配置文件的“逻辑解耦”。
- `font-size <1-200>`: 设置 Ghostty 字体大小；配合 Git Clean Filter 不会让 dotfiles 仓库变脏
- `opacity <0.0-1.0>`: 设置 Ghostty 背景透明度；配合 Git Clean Filter 不会让 dotfiles 仓库变脏
- `audio-volume`: 音量控制与输出设备切换（需要 `switchaudio-osx`）
- `preview-md <file>`: 在 Zellij 浮动窗口中预览 Markdown 文件（需要 `glow`）
- `colors-print`: 打印终端 256 色板
- `print-256-hex-colors`: 打印 256 色的十六进制色值
- `validate-configs [tool|all]`: 验证配置文件语法和完整性（支持 fish/git/zellij/helix/mise/ghostty/karabiner）
- `dot-update`: 一键聚合更新所有核心依赖包（包含 Homebrew, Mise 工具链, Fisher 插件, 以及 Helix Tree-sitter 语法库）

> [!TIP]
> **变更生效方式：**
> - `colorscheme`：Zellij 实时生效；如果 Ghostty 正在运行，脚本会在切换后自动触发配置重载，使主题立即生效；若 Ghostty 未运行，则会在下次启动时生效。Helix 仍需执行 `:config-reload` 使已打开的 buffer 生效；Btop、Bat 与 Delta 下次执行命令时生效。`colorscheme -i` / `--interactive` 会通过 `fzf` 打开主题列表，并在光标焦点变化时立即触发切换，适合快速试色。首次切换到仓库内置的自定义 syntect 主题（当前为 `tokyonight`、`rose-pine`、`kanagawa`、`one-dark`、`everforest`、`everforest-light` 和 `dayfox`）时，脚本会自动执行 `bat cache --build`；Delta 对 `tokyonight` 会启用官方 Tokyo Night feature，对 `rose-pine`、`kanagawa`、`one-dark`、`everforest`、`everforest-light` 和 `dayfox` 会启用仓库内置的 Delta feature；若 Ghostty 自动重载失败，再手动按 `Cmd + Shift + ,` 即可。
> - `font-size` / `opacity`：如果 Ghostty 正在运行，脚本会在修改后自动触发配置重载，使字号或透明度立即生效；若 Ghostty 未运行，则会在下次启动时生效。若 Ghostty 自动重载失败，再手动按 `Cmd + Shift + ,` 即可；配合 Git Clean Filter，这些本地显示偏好不会让 dotfiles 仓库变脏。

---
### 5.9 OrbStack（可选）

**定位**：本项目通过 Homebrew 安装 `OrbStack`，将其作为 macOS 上轻量、现代的容器与 Linux 开发环境。

**当前边界**：本仓库目前**不托管** `OrbStack` 的 GUI 偏好、虚拟机参数、网络、卷、镜像源等应用内配置；这里只提供安装与终端侧兼容。

**为什么和 SSH 有关系**：`OrbStack` 里的 Linux machine 可以被当成一台可通过 SSH 访问的本地 Linux 主机来使用；因此它和普通远程服务器在终端兼容性、连接方式、工具接入方式上基本是同一类问题。

**已做集成**：
- Fish 会自动将 `~/.orbstack/bin` 加入 `PATH`，因此安装完成后可直接使用 `docker`、`docker compose`、`orb` 等命令。
- Fish 中的 `ssh` / `orb` 已做 `TERM=xterm-256color` 动态降级，避免从 Ghostty 进入 SSH / OrbStack 远端环境时出现 `unknown terminal type`。
- `s` 命令现在会递归解析 `~/.ssh/config` 里的 `Include`，因此也能识别 `OrbStack` 自动生成的 SSH 主机配置。

**如何接入 SSH**：
- 首次安装后先手动打开一次 `OrbStack`，确认后台服务已启动。
- 在 `~/.ssh/config` 中加入一行：`Include ~/.orbstack/ssh/config`
- 完成后即可把 `OrbStack` 的 Linux machine 当成普通 SSH 主机使用，也可以直接通过本仓库的 `s` 命令进行选择连接。

**最常见用法**：
- 如果你主要跑容器，日常基本直接在终端中使用：`docker ps`、`docker compose up -d`、`docker exec -it <container> /bin/bash`。
- 如果你需要一台完整的 Linux 开发机，可在 `OrbStack` 图形界面中新建一个 Linux machine（通常选 `Ubuntu` 即可）。
- 创建完成后可直接进入该机器：`orb -m <machine_name>`；也可以走 SSH 方式，例如 `ssh <user>@<machine_name>@orb`。
- 常见场景包括：本地复现更接近服务器的 Linux 环境、隔离旧项目依赖、在独立机器里跑数据库/服务端程序。
- 需要查看容器、镜像、卷或 Linux 机器状态时，再打开 `OrbStack` 图形界面操作即可。

---

## 6. 与官方默认的关键差异

本项目对各工具的默认配置做了若干有意识的定制。以下是**所有偏离官方默认值的关键改动**，帮助你快速了解本 dotfiles 的"个性化"部分。

### 6.1 Karabiner 全局键位改造

| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| Caps Lock ↔ Left Control 互换 | 保持原位置 | 交换位置（已排除 HHKB 键位的键盘）| Caps Lock 位置更适合高频的 Ctrl 操作（Emacs/Zellij/Helix/Vim 等均重度依赖 Ctrl） |
| `Right Command + a` | 无绑定 | 区域截图（映射到 `Cmd + Shift + 4`） | 用右侧 Command 作为截图前缀，不污染终端里高频的 Ctrl / Alt 组合 |
| `Right Command + f` | 无绑定 | 全屏截图（映射到 `Cmd + Shift + 3`） | 全屏抓取走统一心智模型，避免记忆系统原生组合 |
| `Right Command + r` | 无绑定 | 打开截图 / 录屏工具栏（映射到 `Cmd + Shift + 5`） | 截图与录屏共用一个入口，覆盖更完整的系统能力 |
| `Right Command + c` | 无绑定 | 区域截图到剪贴板（映射到 `Ctrl + Cmd + Shift + 4`） | 直接进入剪贴板，适合聊天、文档和 AI 多模态输入场景 |
| `Right Command + s` | 无绑定 | 停止系统录屏（映射到 `Ctrl + Cmd + Esc`） | 给系统录屏补一个更顺手、更一致的结束动作 |

**使用说明：**
- `Right Command + a`：按下后鼠标会变成十字准星。拖拽选择区域，松开即可截图；按 `Esc` 取消。
- 窗口截图：先按 `Right Command + a`，再按一次 `Space` 切换到窗口模式；把鼠标移动到目标窗口上，窗口高亮后单击即可截图。
- `Right Command + f`：按下后立即执行全屏截图。
- `Right Command + r`：打开 macOS 原生截图 / 录屏工具栏。这里可以切换区域截图、窗口截图、全屏截图、整屏录制和选区录制，也可以设置保存位置、倒计时和是否显示鼠标指针。
- 开始录制：在工具栏里选中“整屏录制”或“选区录制”后，点击 `Record` 开始；如果是“录制整个屏幕”，也可以按 Apple 官方说明直接点击屏幕开始。实测按 `Enter` 也可以启动录制，适合纯键盘操作。
- 结束录制：点击菜单栏右上角的停止按钮，或直接按 `Right Command + s`。它映射的是系统原生停止录制快捷键 `Control + Command + Esc`。
- `Right Command + c`：进入区域截图到剪贴板模式。拖拽选区并松开后，不会落地成文件，直接粘贴到聊天窗口、文档或 AI 输入框即可。

**截图后的默认行为：**
- 如果系统开启了截图缩略图预览，截图后右下角会短暂弹出缩略图。点它可以立刻进入标注、裁剪、分享或删除。
- 如果不点缩略图，系统会按当前 macOS 截图设置自动保存到默认位置（通常是桌面，或你在 `Cmd + Shift + 5` 工具栏里指定的位置）。
- 想改保存位置、关闭缩略图预览或调整计时器，直接按 `Right Command + r` 打开工具栏，再进入 `选项` 调整即可。
- 录屏停止后，右下角同样会出现缩略图。点进去可以预览、裁剪或分享；如果不点，系统会自动保存为 `.mov` 文件。

### 6.2 Shottr 集成说明

- 本仓库会通过 Homebrew 默认安装 `Shottr`，作为默认集成的截图标注工具。
- 如果你需要长截图、OCR、贴图固定，或者想统一使用 `Shottr` 自己的标注界面，可以直接使用它自己的全局快捷键。
- 出于全局快捷键会抢占按键事件的考虑，安装脚本不会静默覆盖你现有的 `Shottr` 设置，而是显式询问是否写入推荐值 `Shift + Cmd + 1/2/A/S`。如果想事后补上，也可以手动执行：`"$HOME/dotfiles/bin/configure-shottr-hotkeys" --force`
- 如果首次启动或首次触发热键时遇到 macOS 权限弹窗，按系统提示授予 `Shottr` 所需权限后，再重新测试截图或 OCR 流程即可。
- 根据 `Shottr` 官方当前授权条款，个人用途免费，商业用途需购买许可证。

### 6.3 Ghostty 终端行为与键位

**键位变更：**
| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| `Cmd + ;` → Quick Terminal | 无绑定 | `global:cmd+;=toggle_quick_terminal` | 全局一键唤出/隐藏终端 |
| `Cmd + 1~9` | 切换 Ghostty 标签页 | `unbind`（解绑） | 让出给 Zellij 管理标签页切换 |
| 选中即复制 | `copy-on-select = true` | `copy-on-select = clipboard` | 同时复制到主选区和系统剪贴板 |

**行为变更：**
| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| 窗口状态恢复 | `default` | `window-save-state = never` | 避免与 Zellij 会话恢复冲突 |
| 打字时隐藏鼠标 | `false` | `mouse-hide-while-typing = true` | 减少视觉干扰 |
| 背景模糊 | `false` | `background-blur = 25` | 半透明时的毛玻璃效果 |
| 未聚焦分屏不透明度 | `0.7` | `unfocused-split-opacity = 0.3` | 更明显区分聚焦/非聚焦面板 |
| 环境变量 | 无 | `env = GHOSTTY_RUNTIME=1` | 供 Fish 判断是否在 Ghostty 中运行 |

### 6.4 Zellij 快捷键与会话架构

**架构变更：**
| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| 快捷键体系 | 内置默认快捷键 | `keybinds clear-defaults=true` 全部重建 | 精简并统一 Vim 风格导航，移除未使用的绑定 |
| 默认布局 | `default` | `default_layout "dev-workspace"` | 使用自定义的通用开发工作区布局，并继承启动目录 |
| 会话名 | 随机生成 | `session_name "main"` | 固定会话名，方便 attach |
| 自动附加 | `false` | `attach_to_session true` | 打开新终端自动连接已有会话 |
| 主题 | `default` | `theme "dracula-pro"` | 自定义 Dracula 变体，修复文本选中色的兼容问题 |

**键位增强：**
| 改动 | 说明 |
|------|------|
| `Cmd + 1~9` 全局切换标签页 | 无需进入 tab 模式，配合 Ghostty 的 unbind 实现 |
| 所有模式添加 `h/j/k/l` 导航 | 面板/标签页/调整大小/移动/滚动均支持 Vim 风格 |
| `Ctrl + a` 进入 tmux 兼容模式 | 为 tmux 用户提供肌肉记忆兼容层 |

### 6.5 Fish Shell 行为与键位

**行为变更：**
| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| 欢迎语 | 显示版本信息 | `fish_greeting ""` (关闭) | 保持终端启动干净 |
| 编辑模式 | Emacs 模式 | Vi 混合模式 (Vi + Emacs insert) | Vi 键位为主，保留 Ctrl-a/e 等 Emacs 快捷键 |
| 默认编辑器 | 无 | `EDITOR=hx` / `VISUAL=hx` | 统一使用 Helix |
| 分页器 | 无 | `MANPAGER` 使用 bat 语法高亮 | Man 手册页更易读 |
| Homebrew 自动更新 | 启用 | `HOMEBREW_NO_AUTO_UPDATE=1` | 避免每次安装包时卡在更新 |
| Fisher 插件路径 | `~/.config/fish` | `~/.local/share/fisher` | 隔离第三方插件，保持配置目录纯净 |
| Zellij 自动启动 | 不自动启动 | 在 Ghostty 中自动启动 | Ghostty 原生接管启动，无需手动输入 `zellij`，未安装时自动 fallback 到纯 Fish |

**键位变更：**
| 改动 | 说明 |
|------|------|
| `Ctrl + d` (insert/normal) | 命令行为空时双击确认退出（500ms 内再按一次才退出），防止误关终端或 Zellij 面板；命令行有内容时保持 delete-char |
| `Ctrl + e` (normal mode) | 用 Helix 全屏编辑当前命令行 |
| `<Space>y` (normal mode) | 显式复制整条当前命令行到 macOS 系统剪贴板，避免污染默认 yank 语义 |
| Vi 光标形状 | normal=block, insert=line, replace=underscore |
| Tide vi_mode 标识 | `D` → `N`（对齐 Vim 社区的 Normal 缩写习惯） |

### 6.6 Helix 编辑器键位与显示

**键位变更：**
| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| `Ctrl + r` | 无绑定 | `:reload` 重载当前文件 | 快速重载被外部修改的文件 |
| `Space + m` | 无绑定 | 使用 glow 预览 Markdown | 在浮动窗口中渲染 Markdown |
| `Space + o/i` | 无绑定 | `expand_selection` / `shrink_selection` | 替代 `Alt-o/i`，避免 Alt 键冲突 |
| 插入模式 `Ctrl + f/b/n/p/a/e` | 无绑定 | Emacs 风格光标移动 | 无需退出插入模式即可快速移动光标 |
| `j` / `k` | 按视觉行移动 | 按物理行移动 (`move_line_down/up`) | 配合软折行和行号跳转，避免 `6j` 跳转到错误位置 |
| `gj` / `gk` | 按物理行移动 | 按视觉行移动 (`move_visual_line_down/up`) | 需要逐视觉行移动时使用 |

**显示变更：**
| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| 行号 | 绝对行号 | `line-number = "relative"` | 配合 Vim 动作快速跳转 |
| 光标行/列高亮 | 均关闭 | `cursorline = true` / `cursorcolumn = true` | 快速定位光标位置 |
| 标签栏 | `never` | `bufferline = "multiple"` | 多文件时显示缓冲区标签 |
| 色彩模式指示器 | `false` | `color-modes = true` | 不同模式不同颜色 |
| Inlay hints | `false` | `display-inlay-hints = true` | 显示类型提示等内联信息 |
| 行尾诊断 | `disable` | `end-of-line-diagnostics = "warning"` | 行尾直接显示警告 |
| 内联诊断 | `disable` | `cursor-line = "warning"` / `other-lines = "warning"` | 所有行内联显示诊断 |
| 保存时清理 | 均关闭 | `trim-final-newlines` / `trim-trailing-whitespace = true` | 保持文件整洁 |
| 软换行 | 关闭 | `soft-wrap.enable = true` | 长行自动换行 |

### 6.7 Git 工作流增强

| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| 默认编辑器 | `vim` | `core.editor = hx` | 统一使用 Helix |
| 分页器 | `less` | `core.pager = delta` | Diff 语法高亮 |
| Pull 策略 | `merge` | `pull.rebase = true` | 保持提交历史线性 |
| Push 行为 | 需手动设置上游 | `push.autoSetupRemote = true` | 省去 `--set-upstream` |
| 冲突风格 | `merge` | `merge.conflictstyle = diff3` | 同时显示 base/ours/theirs 三方 |
| 分支名 | `master` | `init.defaultBranch = main` | 现代社区规范 |
| 重用冲突解决 | 关闭 | `rerere.enabled = true` | 自动记忆冲突解决方案 |
| 用户信息 | 硬编码在配置中 | 通过 `include` 引入本地文件 | 防止敏感信息入库 |
| 主题解耦 | 切换配色会导致仓库变脏 | 使用 Git Clean Filter 自动处理 | 确保 local 配色变更不产生 unstaged changes |

### 6.8 macOS 系统偏好与触控板手势

| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| 轻点来点按 | 默认关闭，需要按下触控板才算点击 | 开启 | 降低点击负担，让交互更轻量 |
| 用力点按与触感反馈 | 默认开启 | 关闭 | 避免误触查词/预览等系统动作，统一为轻点交互 |
| 三指拖移 | 默认关闭 | 开启 | 文本选择与应用窗口拖动更顺手，减少按压拖拽带来的手指负担 |

---

## 7. 常用维护命令 (Makefile)

本项目引入了 `Makefile` 来标准化日常维护任务，集成了安装、同步、验证和清理等操作。

| 命令 | 说明 |
|------|------|
| `make help` | 显示帮助菜单（默认） |
| `make install` | 运行 `install.sh` 安装脚本 |
| `make stow` | 建立所有配置文件的软链接 |
| `make unstow` | 删除所有软链接（卸载配置） |
| `make restow` | 修复/重建所有软链接 |
| `make stow-<package>` | 仅同步指定包 (如 `make stow-fish`, `make stow-ghostty`) |
| `make fish` | 将 Fish 设置为默认 Shell |
| `make plugins` | 更新 Fisher 插件 |
| `make macos` | 配置 macOS 系统偏好设置 |
| `make validate` | 运行完整的配置验证（包含工具检查） |
| `make lint` | 静态分析仓库中的 Shell 脚本（含 `bootstrap.sh`、`install.sh`、`macos.sh` 和 `bin/*`） |
| `make docs` | 生成或更新 README 的目录 (TOC) |
| `make update` | 拉取远程代码并更新所有核心工具链体系 (`dot-update`) |

## 8. 常见问题 (FAQ / Troubleshooting)

如果在安装或使用过程中遇到问题，请先参考以下常见高频问题的解决办法：


**Q: 如何脱离鼠标将命令行拷贝到 macOS 系统剪贴板？**
> **A:** 在 Fish 交互式环境中（本项目已默认开启 Vi 模式），为你提供了以下极简的纯键盘方式：
> - 按 `Esc`（或 `Ctrl+[`）进入 Normal 模式，然后按下 `<Space>y`（空格键后跟 y），当前整条命令行就会瞬间拷贝到 macOS 系统剪贴板，随后就可以通过 `Cmd+v` 进行粘贴了。

**Q: 如何脱离鼠标拷贝 Zellij 面板 (pane) 中的指定内容？**
> **A:** 在 Zellij 中，你可以通过以下纯键盘组合技完成精准拷贝：
> 1. 按 `Ctrl + s` 进入 Scroll（滚动）模式。
> 2. 按 `e` 将当前整个面板的输出缓冲区内容在 Helix 编辑器中打开。
> 3. 在 Helix 中，使用 `v` 进入选择模式并配合方向键（或 `w/b`、`/` 搜索）精准选中所需内容。
> 4. 按 `<Space>y` 将选中内容直接拷贝到 macOS 系统剪贴板。
> 5. 按 `:q` 退出 Helix，即可无缝回到 Zellij 面板。

**Q: 打开 VS Code 集成终端无法正常显示图标，看到一堆豆腐块/乱码/问号，如何解决？**
> **A:** 这通常是因为 VS Code 没有正确配置支持完整图标的 Nerd Font 和连字。你可以在终端里执行 `hx ~/Library/Application\ Support/Code/User/settings.json`（或通过命令面板打开用户设置 JSON），在其中加入以下配置来解决：
> ```json
> {
>   "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font', 'FiraCode Nerd Font', monospace",
>   "editor.fontFamily": "'JetBrainsMono Nerd Font', 'FiraCode Nerd Font', Menlo, Monaco, 'Courier New', monospace",
>   "editor.fontLigatures": true
> }
> ```

**Q: 在 VS Code 集成终端中执行 `zi` 命令（或任何 fzf 交互）时，按 `Ctrl + j/k/n/p` 无法上下选择，反而输出乱码怎么办？**
> **A:** 这是因为 VS Code 默认拦截了这些控制键，没有直接传递给底层的 Shell 应用程序。你可以通过命令面板打开“用户设置 JSON”（或执行 `hx ~/Library/Application\ Support/Code/User/settings.json`），额外加入以下配置并重启 VS Code 即可解决：
> ```json
> {
>   "terminal.integrated.sendKeybindingsToShell": false
> }
> ```

**Q: 终端里的很多快捷键（如分屏、翻页）突然失效了，毫无反应？**
> **A:** 这往往是因为不小心按下了 `Ctrl + g` 进入了 Zellij 的 **Locking 模式（锁定模式）**。在锁定模式下，Zellij 会拦截自身的所有快捷键绑定以便将其“透传”给内部程序。只需再次按下 `Ctrl + g` 即可解锁并恢复正常。

**Q: 使用 `aichat` 的快捷键或者命令时，提示找不到模型或网络超时？**
> **A:** 请检查两点：
> 1. 请确认您在 `~/.fish.local.fish` 中正确配置了模型名称（如 `AICHAT_MODEL`）和对应的 API Key。配置后务必执行 `exec fish` 重新加载环境或重启终端。
> 2. 如果您使用的是本地 Ollama，请确认 `ollama serve` 已启动、目标模型已通过 `ollama pull <model>` 下载，且模型名已包含在 `~/.config/aichat/config.yaml` 的 `local-llm.models` 列表中。
> 3. 如果您使用的模型 API 访问受限（如访问 OpenAI），您可能需要在终端开启全局代理。本配置内置了 `proxy` 和 `unproxy` 快捷指令来帮助你一键开关终端代理。

**Q: 为什么在 Fish 中执行完命令后，还要等一会儿下一个 prompt 才出现？**
> **A:** 这通常不是 Fish 本身卡顿，而是 `mise` 的自动激活在刷新当前目录环境。若 `~/.config/mise/config.toml` 或当前项目里的 `.mise.toml` 声明了未安装工具，`mise` 在 prompt 阶段检查这些工具时就可能明显变慢。
> - 先执行 `mise current` 查看当前目录实际生效的工具来源与版本；如果看到 `is specified ... but not installed` 一类提示，通常就是缺失工具导致。
> - 再执行 `mise install` 安装当前目录与全局配置中声明的缺失工具，然后用 `mise ls` 复查安装状态。
> - 如果只想快速确认是否由 `mise` 触发，可临时运行 `env MISE_FISH_AUTO_ACTIVATE=0 fish` 启动一个不自动激活 `mise` 的新 Shell；如果卡顿消失，再回头检查 `mise` 配置。
> - 若问题仍未定位，可继续执行 `mise doctor` 检查激活状态与环境配置。

**Q: 在 Helix 编辑器里写代码时，为什么没有语法提示或代码检查？**
> **A:** Helix 依赖各种语言服务器（LSP）来提供智能补全能力。本项目通过 `mise` 统一管理 LSP：
> - 请确保在终端里执行过 `mise install` 获取最新版本的 LSP 工具链。
> - 在 Helix 内输入 `:log` 查阅日志，或在终端执行 `hx --health` 确认对应语言的 LSP 启动是否报错。
> - 特定语言（如 C/C++ 或 Rust）的 LSP 推荐使用 brew 独立安装以获得最稳定支持（例如 `brew install llvm` 或 `brew install rust-analyzer`）。

---

## 9. 致谢 (Acknowledgments)

本项目的诞生离不开现代开源社区的繁荣生态，特别感谢以下卓越的项目构建了这套工作流的基石：

- [Homebrew](https://brew.sh/) / [GNU Stow](https://www.gnu.org/software/stow/)
- [Ghostty](https://ghostty.org/) / [Zellij](https://zellij.dev/)
- [Fish](https://fishshell.com/) / [Fisher](https://github.com/jorgebucaran/fisher) / [Tide](https://github.com/IlanCosman/tide) / [fzf.fish](https://github.com/PatrickF1/fzf.fish)
- [Helix](https://helix-editor.com/) / [Mise](https://mise.jdx.dev/)
- [AIChat](https://github.com/sigoden/aichat) / [GitHub CLI](https://cli.github.com/)
- [fzf](https://github.com/junegunn/fzf) / [fd](https://github.com/sharkdp/fd) / [zoxide](https://github.com/ajeetdsouza/zoxide) / [ripgrep](https://github.com/BurntSushi/ripgrep)
- [bat](https://github.com/sharkdp/bat) / [eza](https://github.com/eza-community/eza) / [git-delta](https://github.com/dandavison/delta) / [glow](https://github.com/charmbracelet/glow)
- [grc](https://github.com/garabik/grc) / [shellcheck](https://github.com/koalaman/shellcheck) / [btop](https://github.com/aristocratos/btop) / [asciinema](https://github.com/asciinema/asciinema)
- [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) / [Maple Mono](https://github.com/subframe7536/maple-font) / [Geist Mono](https://github.com/vercel/geist-font) / [Nerd Fonts](https://www.nerdfonts.com/)
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) / [OrbStack](https://orbstack.dev/) / [switchaudio-osx](https://github.com/deweller/switchaudio-osx)

---

## 10. 开源协议 (License)

本项目采用 [MIT License](LICENSE) 开源协议。

你可以自由地使用、学习、修改和分发本项目的代码，将其作为你打造个人专属工作流的起点。
