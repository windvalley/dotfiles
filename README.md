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


本项目是一套 **现代、高效、开箱即用** 的 macOS 终端开发环境，所有配置集中版本控制，通过 GNU Stow 一键部署。

核心工具栈：Ghostty（终端）+ Zellij（复用器）+ Fish（Shell）+ Helix（编辑器）+ Mise（版本管理），视觉与交互风格全栈统一。

**核心设计理念：**
1. **配置即代码**：所有配置通过 Git 追踪与 Stow 符号链接管理，支持一键幂等重置。
2. **终端即容器**：终端仅作渲染容器（Ghostty），会话与布局调度收敛于复用器（Zellij），代码编辑则交由开箱即用的现代编辑器（Helix），彻底消除插件拼凑的心智负担。
3. **环境即沙箱**：终结全局变量污染与多版本管理器的混乱，依靠统一基座在一处声明全部语言沙箱（Mise）。
4. **注释即文档**：本项目的每一个配置文件本身就是最详尽的说明书，包含深度的中文注释、设计取舍与最佳实践指引。

> [!NOTE]
> 此 dotfiles 仅适用于 macOS，不兼容 Linux 或 Windows (WSL)，且没有跨平台适配计划。

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [0. TL;DR (快速开始)](#0-tldr-%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B)
- [1. 项目结构](#1-%E9%A1%B9%E7%9B%AE%E7%BB%93%E6%9E%84)
- [2. 安装步骤](#2-%E5%AE%89%E8%A3%85%E6%AD%A5%E9%AA%A4)
  - [2.1 一键安装 (推荐)](#21-%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85-%E6%8E%A8%E8%8D%90)
  - [2.2 手动安装步骤 (可选)](#22-%E6%89%8B%E5%8A%A8%E5%AE%89%E8%A3%85%E6%AD%A5%E9%AA%A4-%E5%8F%AF%E9%80%89)
- [3. 配置指南](#3-%E9%85%8D%E7%BD%AE%E6%8C%87%E5%8D%97)
  - [3.1 配置 fish](#31-%E9%85%8D%E7%BD%AE-fish)
  - [3.2 从 zsh 迁移](#32-%E4%BB%8E-zsh-%E8%BF%81%E7%A7%BB)
  - [3.3 本地私有配置 (不入库)](#33-%E6%9C%AC%E5%9C%B0%E7%A7%81%E6%9C%89%E9%85%8D%E7%BD%AE-%E4%B8%8D%E5%85%A5%E5%BA%93)
  - [3.4 配置 fisher](#34-%E9%85%8D%E7%BD%AE-fisher)
  - [3.5 配置 tide](#35-%E9%85%8D%E7%BD%AE-tide)
  - [3.6 macOS 系统偏好 (macos.sh) (可选)](#36-macos-%E7%B3%BB%E7%BB%9F%E5%81%8F%E5%A5%BD-macossh-%E5%8F%AF%E9%80%89)
  - [3.7 配置 Git](#37-%E9%85%8D%E7%BD%AE-git)
- [4. 使用方法](#4-%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95)
  - [4.1 Ghostty 终端](#41-ghostty-%E7%BB%88%E7%AB%AF)
  - [4.2 Zellij 终端复用器](#42-zellij-%E7%BB%88%E7%AB%AF%E5%A4%8D%E7%94%A8%E5%99%A8)
  - [4.3 Fish Shell](#43-fish-shell)
  - [4.4 Helix 编辑器](#44-helix-%E7%BC%96%E8%BE%91%E5%99%A8)
  - [4.5 Mise 工具版本管理](#45-mise-%E5%B7%A5%E5%85%B7%E7%89%88%E6%9C%AC%E7%AE%A1%E7%90%86)
  - [4.6 Git 配置用法](#46-git-%E9%85%8D%E7%BD%AE%E7%94%A8%E6%B3%95)
  - [4.7 stow 的用法说明](#47-stow-%E7%9A%84%E7%94%A8%E6%B3%95%E8%AF%B4%E6%98%8E)
  - [4.8 自定义命令（bin/）](#48-%E8%87%AA%E5%AE%9A%E4%B9%89%E5%91%BD%E4%BB%A4bin)
- [5. 常用维护命令 (Makefile)](#5-%E5%B8%B8%E7%94%A8%E7%BB%B4%E6%8A%A4%E5%91%BD%E4%BB%A4-makefile)
- [6. 与官方默认的关键差异](#6-%E4%B8%8E%E5%AE%98%E6%96%B9%E9%BB%98%E8%AE%A4%E7%9A%84%E5%85%B3%E9%94%AE%E5%B7%AE%E5%BC%82)
  - [🔑 Karabiner — 全局键位改造](#-karabiner--%E5%85%A8%E5%B1%80%E9%94%AE%E4%BD%8D%E6%94%B9%E9%80%A0)
  - [🖥️ Ghostty — 终端行为与键位](#-ghostty--%E7%BB%88%E7%AB%AF%E8%A1%8C%E4%B8%BA%E4%B8%8E%E9%94%AE%E4%BD%8D)
  - [🧩 Zellij — 快捷键与会话架构](#-zellij--%E5%BF%AB%E6%8D%B7%E9%94%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E6%9E%B6%E6%9E%84)
  - [🐟 Fish — Shell 行为与键位](#-fish--shell-%E8%A1%8C%E4%B8%BA%E4%B8%8E%E9%94%AE%E4%BD%8D)
  - [✏️ Helix — 编辑器键位与显示](#-helix--%E7%BC%96%E8%BE%91%E5%99%A8%E9%94%AE%E4%BD%8D%E4%B8%8E%E6%98%BE%E7%A4%BA)
  - [🔧 Git — 工作流增强](#-git--%E5%B7%A5%E4%BD%9C%E6%B5%81%E5%A2%9E%E5%BC%BA)
- [7. 致谢 (Acknowledgments)](#7-%E8%87%B4%E8%B0%A2-acknowledgments)
- [8. 开源协议 (License)](#8-%E5%BC%80%E6%BA%90%E5%8D%8F%E8%AE%AE-license)

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

- `ghostty/`: Ghostty（/ˈɡoʊs.ti/，Ghost + ty）终端配置
- `fish/`: Fish（/fɪʃ/，**F**riendly **I**nteractive **SH**ell）shell 配置
- `zellij/`: Zellij（/ˈzɛl.ɪdʒ/，源自阿拉伯语，马赛克瓷砖拼贴艺术）终端复用器，易于配置
- `helix/`: Helix（/ˈhiː.lɪks/，螺旋）现代模态编辑器，开箱即用
- `karabiner/`: Karabiner（/ˌkær.əˈbiː.nər/，德语，登山扣）键盘映射（交换 Caps Lock 和 Left Control）
- `git/`: Git 基础配置（别名、Delta 美化、全局忽略等）
- `mise/`: Mise（/miːz/，源自法语 mise en place，就位准备）工具版本管理器配置
- `btop/`: btop 现代系统资源监控工具配置
- `bin/`: 自定义命令脚本（自动链接到 `~/.local/bin`）
- `local/`: 本地环境私有配置模板（用于 Fish 环境变量脱敏、Git 多账号隔离及 Ghostty 私有配置）
- `Makefile`: 自动化构建与维护脚本
- `.editorconfig`: 跨编辑器格式化标准。内置了严格的格式控制（例如缩进模式、行尾序列 LF 强制设定、文件末空行保护等），确保项目源码整洁、消除跨平台和跨编辑器带来的格式问题。


## 2. 安装步骤

### 2.1 一键安装 (推荐)

仓库根目录下提供了一个 `install.sh` 脚本，可以自动化完成绝大部分安装和配置工作。

**该脚本将执行以下操作：**
1. **环境准备**：检查并自动安装 **Homebrew**（如果尚未安装）。
2. **核心依赖**：读取 `Brewfile`，安装所有 CLI 工具（stow, zellij, fish, helix, mise, gh, bat, eza, fzf, ripgrep 等）与 GUI 应用（Ghostty, OrbStack, JetBrains Mono 字体等）。
3. **字体安装**：默认已通过 Brew 安装 JetBrains Mono，并**询问是否安装**其他扩展字体（Maple Mono, Geist Mono）。
4. **软链配置**：自动识别已存在的配置并备份，然后使用 `stow` 将所有配置（含 `bin` 脚本）软链到对应的系统目录。
5. **隐私配置模板**：自动在用户目录创建 Git 信息模板（`.gitconfig.local`/`.work`）和私密环境变量模板（`config.local.fish`）。
6. **Shell 初始化**：将 **Fish** 设为默认 Shell，并**自动迁移原 Zsh 的 PATH 环境变量**到 Fish 中。
7. **插件配置**：安装 **Fisher** 插件管理器并同步所有 Fish 插件。
8. **系统优化**：提示是否应用 **macOS 常用系统偏好设置**（通过 `macos.sh`）。

**使用方法：**
```sh
cd "$HOME/dotfiles"
./install.sh
```

> [!TIP]
> **非交互模式**：如果在自动化环境（如 CI/CD 等）中执行，可追加 `-y` 或 `--unattended` 标志跳过所有确认自动安装：`./install.sh -y`

**安装过程说明：**
- 如果系统未安装 Homebrew，脚本默认会**询问是否安装**
- 如需手动安装 Homebrew，请访问 https://brew.sh
- 脚本会自动检测并迁移 zsh 的 PATH 设置到 fish


---

### 2.2 手动安装步骤 (可选)

如果你更倾向于手动操作，请按以下顺序执行：

#### 2.2.1 安装依赖项

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

# GitHub 官方 CLI (用于 PR 创建等 GitHub 交互)
brew install gh

# Git 美化工具 (Diff 语法高亮)
brew install git-delta

# 现代、跨平台的系统资源监控工具
brew install btop

# 字体
brew install --cask font-jetbrains-mono-nerd-font

# 常用工具
brew install bat eza fzf zoxide grc gawk gnu-sed grep glow

# 音量控制
brew install switchaudio-osx
```

**说明：**
- `gh`: GitHub 官方命令行工具，用于 PR 创建、Issue 管理等 GitHub 交互（`aipr` 命令依赖）。
- `zoxide`: 智能目录跳转工具，替代传统的 `cd`。用法：`z <关键词>` 跳转目录，`zi <关键词>` 交互式选择（需 fzf）。
- `gnu-sed`: 提供 `gsed`，用于 `colorscheme` / `font-size` / `opacity` 等脚本。
- `switchaudio-osx`: 提供 `SwitchAudioSource`，用于 `audio-volume`。
- `grc`: 通用彩色输出查看器 (Generic Colouriser)，配合 fish 插件为 `ping` / `ls` / `docker` / `diff` 等命令提供彩色输出增强。
- `glow`: 终端 Markdown 阅读器，用于 Helix 预览功能。

#### 2.2.2 拉取仓库

```sh
git clone --depth=1 https://github.com/windvalley/dotfiles.git "$HOME/dotfiles"

# 更新
cd "$HOME/dotfiles"
git pull --rebase
```

#### 2.2.3 链接配置（stow）

> [!TIP]
> 如果你的系统已安装 `make`，可以运行 `make stow` 一键链接，该命令及 `install.sh` 脚本均已内置了完善的目录保护机制，推荐直接使用，不用手动折腾。

如果坚持手动链接配置，为了确保 stow 能为 GUI 应用（如 Btop、Karabiner）以及扩展性强的工具创建纯净的**目录级软链**，需要对所有目标配置目录进行防御性清理：

```sh
# 如果目标工具的配置目录已经是真实目录（非软链），必须将其重命名或删除，切忌保留！
# 目的：确保 stow 时发现目标目录"不存在"，从而直接把整个目录映射为一个【纯目录级软链】。
# 否则 stow 会进入真实目录执行【文件级】软链，导致后续工具在本地新生成的文件脱离版本控制。
for pkg in ghostty helix zellij mise karabiner btop fish git; do
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
stow --restow --target="$HOME" --dir="$HOME/dotfiles" --dotfiles ghostty helix zellij mise karabiner btop fish git

# 单独链接需要特定前置结构的包（例如将自定义命令放置在 ~/.local/bin 下）
mkdir -p "$HOME/.local/bin"
stow --restow --target="$HOME/.local/bin" --dir="$HOME/dotfiles" bin
```

## 3. 配置指南

### 3.1 配置 fish

将 fish 设为默认 shell：

```sh
which fish | sudo tee -a /etc/shells
chsh -s $(which fish)
```

重启终端后（或执行 `exec fish -l`），在 fish 里执行：

```fish
# 检查是否已经切换成功
echo $SHELL

# 让 fish 识别 Homebrew 安装的程序
fish_add_path (brew --prefix)/bin

# 生成命令补全（自动从 man 页面解析）
fish_update_completions

# 主题（只影响语法高亮，不影响 prompt；prompt 由 tide 控制）
fish_config theme choose dracula
```

### 3.2 从 zsh 迁移

> [!IMPORTANT]
> 从 zsh 切换到 fish 后，zsh 配置文件（`~/.zshrc`、`~/.zprofile` 等）中的 PATH 不会自动继承，可能导致已安装软件的命令找不到。

**自动迁移（推荐）**：`install.sh` 会自动检测 zsh 的 PATH 并将缺失的路径添加到 fish，无需手动操作。

**手动迁移**：如需手动添加路径，使用 `fish_add_path`：

```fish
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
```

> [!TIP]
> `fish_add_path` 是持久化的（写入 universal 变量），只需执行一次，重启后仍然生效。
> 可用 `printf '%s\n' $PATH` 查看当前所有路径。

### 3.3 本地私有配置 (不入库)

在实际使用中，我们经常需要配置一些**仅属于当前机器**或**包含敏感信息**的环境变量（例如 `OPENAI_API_KEY`、公司内网代理、特定机器别名等）。

为了防止这些信息被 Git 追踪并泄露到公开仓库中，本 dotfiles 已预设了本地分离机制：

#### Fish Shell 本地配置

1. 将本仓库中的示例模板复制到对应目录并去除 `.example` 后缀：
   ```fish
   cp ~/dotfiles/local/config.local.fish.example ~/.config/fish/config.local.fish
   ```
2. 将你所有的私密配置写入新生成的文件：
   ```fish
   # ~/.config/fish/config.local.fish
   set -gx AI_CMD "opencode run"  # 配置全局 AI 命令，供 aic 等辅助工具使用
   set -gx OPENAI_API_KEY "sk-xxxxxxxxx"
   abbr -a -g work-vpn "sudo launchctl restart com.corp.vpn"
   ```

#### Ghostty 终端本地配置

1. 将本仓库中的示例模板复制到对应目录并去除 `.example` 后缀：
   ```bash
   cp ~/dotfiles/local/ghostty.config.local.example ~/dotfiles/ghostty/dot-config/ghostty/config.local
   ```
2. 在新生成的文件中添加你的私密或特定机器配置（如快捷键、字体等）：
   ```ini
   # ~/.config/ghostty/config.local
   # 示例：按下 ctrl+backspace 自动键入密码并回车
   keybind = ctrl+backspace=text:your_password\r
   ```

> [!NOTE]
> `config.local.fish` 以及 `*.local` 均已被 `.gitignore` 忽略，你可以安全地在本地使用它们，不用担心通过 `stow` 软链后被意外 `git push` 给共享出去。

### 3.4 配置 fisher

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

### 3.5 配置 tide

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

### 3.6 macOS 系统偏好 (macos.sh) (可选)

根目录下提供了 `macos.sh` 脚本，利用 `defaults write` 一键配置符合开发者习惯的深层系统偏好：

- **键盘体验**：设置极速的键盘重复率（KeyRepeat），禁用长按显示特殊字符。
- **访达 (Finder)**：显示所有文件扩展名、状态栏、路径栏，按名称排序时文件夹置顶，禁用 `.DS_Store` 在网络/USB驱动器上的生成。
- **触控板/鼠标**：开启“轻点来点按”。
- **程序坞 (Dock)**：开启自动隐藏，不显示最近使用的应用程序。
- **Safari**：开启“开发”菜单和网页检查器。

你可以随时通过运行以下命令来应用或重新应用这些设置：

```bash
make macos
# 或者 ./macos.sh
```

> [!WARNING]
> 该脚本在执行前可能会要求输入管理员密码（`sudo -v`），且包含了高度个人主观偏好的系统设定。
> **强烈建议你在执行前，先打开 `macos.sh` 快速浏览一遍带有详细中文解释的源码**。你可以轻松地注释掉任何与你习惯不符的 `defaults write` 命令。

### 3.7 配置 Git

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

## 4. 使用方法

### 4.1 Ghostty 终端

**配置文件**：`~/.config/ghostty/config`

**注意**：标签页功能已禁用（由 Zellij 统一管理），多窗口功能仍可用。

**快捷键**：
| 快捷键 | 功能 |
|--------|------|
| `Cmd + Shift + ,` | 重载配置（修改配置文件后按此快捷键生效） |
| `Cmd + ;` | 打开 Quick Terminal（自定义快捷键）|

> [!NOTE]
> 建议使用 Zellij 的标签页和面板功能替代 Ghostty 原生标签页和分屏功能，以获得更灵活的布局控制和跨会话保持能力。

---

### 4.2 Zellij 终端复用器

**配置文件**：`~/.config/zellij/config.kdl`

**自动启动**：本配置在 fish 中集成了 Zellij 自动启动逻辑，打开新终端窗口时会自动启动或挂载到 Zellij 会话。以下情况会自动跳过：
- 已在 Zellij 会话中
- 通过 SSH 连接
- 在 Ghostty 的 Quick Terminal 中
- 设置了环境变量 `ZELLIJ_AUTO_DISABLE`
- `zellij setup --check` 配置预检失败时（自动 fallback 到纯 fish 并提示修复方法）

> [!TIP]
> 如果 Zellij 出现问题导致终端无法正常打开，可在其他终端中执行 `set -Ux ZELLIJ_AUTO_DISABLE 1` 永久禁用自动启动。

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

**布局**：
- **默认布局**：`dev-workspace`
- **布局定义位置**：`~/.config/zellij/layouts/dev-workspace.kdl`
- **修改布局**：编辑上述文件，定义自己的分屏和标签页结构
- **手动加载布局**：`zellij --layout <布局名>`

---

### 4.3 Fish Shell

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
| `aic` | 根据代码变更自动生成 Git 提交信息。支持中英交互切换、Prompt 微调及重写功能 |
| `aipr` | 根据分支变更自动生成 Pull Request 描述。分析 commit 和 diff 后 AI 生成结构化 PR 描述，支持复制到剪贴板、编辑、重写、微调、中英切换，以及通过 gh CLI 直接创建 PR |
| `ait` | 自动根据 Git 变更历史生成 Changelog 并提交打 Tag。支持中英交互切换、Prompt 微调及重写功能 |
| `aip` | AI 即插即用指令库。交互式选择常用开发指挥语并自动复制到剪贴板。支持 fzf 多选预览、编号直跳、关键词过滤和随机模式 |
| `b [query]` | 搜索文件并使用 bat 查看。若关键字匹配唯一结果则直接打开 |
| `rec [name]` | 极简终端操作录屏工具 (基于 asciinema)，支持录制、回放(`rec play`)与网页分享(`rec upload`) |
| `gtd <tag>` | 一键同时删除本地和远端的 Git Tag |

> [!TIP]
> 更多自定义命令（如 `colorscheme`、`font-size`、`opacity` 等）见 [4.8 自定义命令（bin/）](#48-自定义命令bin)。

**内置缩写 (Abbreviations)**：

> [!TIP]
> 忘记缩写了？随时输入 **`a`** 即可查看所有缩写及其对应的完整命令与功能描述。

缩写在输入后按空格时**自动展开**为完整命令。

| 缩写 | 展开为 | 实际含义 |
|------|--------|----------|
| `mkdir` | `mkdir -p` | 级联创建多级目录 (如果父目录不存在自动创建) |
| `ls` / `ll` | `eza` / `eza -l` | 现代版的文件列表显示 / 附带详细权限尺寸等信息 |
| `...` / `....` | `../..` / `../../..` | 极速向下上级两层、三层目录跳转 |
| `vi` / `vim` / `h` | `hx` | 统一唤起 Helix 现代文本编辑器 |
| `cs`... | `colorscheme`... | 详情见自定义命令 `colorscheme`/`font-size`/`opacity`/`audio-volume` |
| `g` | `git` | Git 基础命令调用入口 |
| `ga` / `gs` | `git add` / `git status` | 添加文件到暂存区 / 查看工作区及合并状态 |
| `gd` / `gds` | `git diff` / `git diff --staged` | 查看工作区尚未暂存的修改 / 查看暂存区里尚未提交的差异 |
| `gb` / `gba` / `gbd` | `git branch`... | 查看本地分支 / 查看全部(含远程)分支 / 强制删除分支 |
| `gc` / `gca` | `git commit` / `git commit --amend` | 提交代码 / 追加或修改最后一次提交 |
| `gcm` / `gcam` | `git commit -m` / `git commit -a -m` | 带信息提交代码 / 暂存所有已跟踪文件并提交代码 |
| `gp` / `gpl` | `git push` / `git pull` | 推送代码到远程仓库 / 拉取远程代码 |
| `gm` / `gms` | `git merge` / `git merge --squash` | 合并分支 / 将整条开发分支的多次提交合并压缩为一次改动 |
| `grb` / `grbc` / `grbi` | `git rebase`... | 变基分支 / 解决冲突后继续跑变基 / 交互式手工挑选、压缩变基 |
| `gco` | `git checkout` | 检出分支或文件 (传统方式) |
| `gsw` / `gswc` | `git switch` / `git switch -c` | 切换分支 / 创建并切换分支 (推荐的现代分支方式) |
| `gr` / `grh` | `git reset` / `git reset HEAD` | 重置暂存区或 HEAD 状态 / 仅重置暂存区 (撤销 add) |
| `gro` / `gros` | `git restore`... | 撤销工作区修改 / 撤销暂存区修改 (推荐的现代重置方式) |
| `gsta` / `gstp` | `git stash` / `git stash pop` | 雪藏当前未提交改动清空工作区 / 弹出并恢复雪藏内容 |
| `gt` / `gts` | `git tag` / `git tag -s` | 查看本地所有标签 / 创建带本地 GPG 签名的标签 |
| `gg` | `git log` | 查看原始 Git 提交日志 |
| `gl` | `git log --oneline --decorate --graph` | 【高频】带分支图谱路径、彩色树状结构的美化历史日志 |
| `glo` / `gls` | `git log --oneline` / `git log --stat` | 单行极简日志 / 附带每次提交具体增删文件统计信息的日志 |

**Vi 模式**：
Fish 支持 Vi 风格编辑模式，本配置已默认启用。

| 快捷键 | 功能 |
|--------|------|
| `Esc` | 进入 Vi 普通模式 |
| `i`/`a` | 进入插入模式 (光标前/光标后) |
| `h`/`l` | 光标左/右移动 |
| `k`/`j` | 上一条/下一条命令历史（基于输入过滤） |
| `w`/`b` | 下一个/上一个单词 |
| `0`/`$` | 行首/行尾 |
| `d` | 删除 (配合移动命令，如 dw, dd) |
| `y` | 复制 (配合移动命令，如 yw, yy) |
| `p` | 粘贴 |
| `u` | 撤销 |
| `Ctrl+e` | 在普通模式/插入模式下，使用当前默认编辑器 (hx) 全屏编辑当前命令行 |

在 Vi 普通模式下可以使用所有 Vim 风格的编辑命令。

---

### 4.4 Helix 编辑器

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
  本项目采用 `mise` 集中管理所有语言服务器，详情请参考 [4.5 Mise 工具版本管理](#45-mise-工具版本管理)。
- **重启 LSP**：`:lsp-restart`
- **查看文档**：`:config-open` 打开配置，`:config-reload` 重载

---

### 4.5 Mise 工具版本管理

**核心理念：**
摒弃传统通过 `npm i -g`, `pip install`, `go install` 全局滥装工具导致的系统污染和版本冲突。
本配置将所有的运行时框架（Node/Python/Go）和语言服务器（LSP）**全部统一收敛交由 mise 管理**，实现两层优雅隔离：
1. **全局防灾保底**：全局配置 (`~/.config/mise/config.toml`) 中声明了各大语言**最新版本 (`@latest`) 的 LSP 工具链**，保证了在任何普通目录打开编辑器都有充足的补全提示能力。
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

### 4.6 Git 配置用法

> Git 初始配置（用户信息、多账号隔离等）请参见 [3.7 配置 Git](#37-配置-git)。

**配置文件**：
- `~/.config/git/config`: 核心配置（XDG 标准位置）
- `~/.config/git/ignore`: 全局忽略文件（XDG 标准位置）

**核心特性**：
- **Delta 集成**：使用 `git-delta` 进行 Diff 语法高亮，支持行号、并排显示和颜色优化；`syntax-theme` 由 `colorscheme` 脚本统一管理。
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
| `git cleanup` | `...` | 清理已合并的本地分支 |

---

### 4.7 stow 的用法说明

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

### 4.8 自定义命令（bin/）

这些命令会在 stow `bin` 后出现在 `~/.local/bin`：

- `colorscheme [name]`: 同步切换 Ghostty、Helix、Zellij、Btop、Bat 和 Delta 主题。无参数时显示当前主题和可用主题列表，内置 8 个预设（dracula / tokyonight / gruvbox / kanagawa / nord / solarized-dark / one-dark / everforest），也支持直接传入工具原生主题名。**配合 Git Clean Filter，切换主题不会导致仓库变脏。**
- `dot-theme-filter`: **Git 内部过滤器（非直接执行）**。配合 `.gitattributes` 使用，在 `git add` 时自动将主题配置还原为默认值，实现配置文件的“逻辑解耦”。
- `font-size <1-200>`: 设置 Ghostty 字体大小
- `opacity <0.0-1.0>`: 设置 Ghostty 背景透明度
- `audio-volume`: 音量控制与输出设备切换（需要 `switchaudio-osx`）
- `preview-md <file>`: 在 Zellij 浮动窗口中预览 Markdown 文件（需要 `glow`）
- `colors-print`: 打印终端 256 色板
- `print-256-hex-colors`: 打印 256 色的十六进制色值
- `validate-configs [tool|all]`: 验证配置文件语法和完整性（支持 fish/git/zellij/helix/mise/ghostty/karabiner）
- `dot-update`: 一键聚合更新所有核心依赖包（包含 Homebrew, Mise 工具链, Fisher 插件, 以及 Helix Tree-sitter 语法库）

> [!TIP]
> **变更生效方式：**
> - `colorscheme`：Zellij 实时生效；Ghostty 需按 `Cmd + Shift + ,` 重载配置；Helix 需执行 `:config-reload` 使已打开的 buffer 生效；Btop、Bat 与 Delta 下次执行命令时生效。注：Bat 与 Delta 不支持 tokyonight / kanagawa / one-dark / everforest，切换到这些主题时会自动跳过。
> - `font-size` / `opacity`：修改的是 Ghostty 配置文件，需按 `Cmd + Shift + ,` 重载配置后生效。

---

## 5. 常用维护命令 (Makefile)

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
| `make lint` | 静态分析 `bin/` 脚本（shellcheck） |
| `make docs` | 生成或更新 README 的目录 (TOC) |
| `make update` | 拉取远程代码并更新所有核心工具链体系 (`dot-update`) |
| `make clean` | 清理临时文件 (`.bak`, `.tmp` 等) |

---

## 6. 与官方默认的关键差异

本项目对各工具的默认配置做了若干有意识的定制。以下是**所有偏离官方默认值的关键改动**，帮助你快速了解本 dotfiles 的"个性化"部分。

### 🔑 Karabiner — 全局键位改造

| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| Caps Lock ↔ Left Control 互换 | 保持原位置 | 交换位置（已排除 HHKB 键位的键盘）| Caps Lock 位置更适合高频的 Ctrl 操作（Emacs/Zellij/Helix/Vim 等均重度依赖 Ctrl） |

### 🖥️ Ghostty — 终端行为与键位

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

### 🧩 Zellij — 快捷键与会话架构

**架构变更：**
| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| 快捷键体系 | 内置默认快捷键 | `keybinds clear-defaults=true` 全部重建 | 精简并统一 Vim 风格导航，移除未使用的绑定 |
| 默认布局 | `default` | `default_layout "dev-workspace"` | 使用自定义的开发工作区布局 |
| 会话名 | 随机生成 | `session_name "main"` | 固定会话名，方便 attach |
| 自动附加 | `false` | `attach_to_session true` | 打开新终端自动连接已有会话 |
| 主题 | `default` | `theme "dracula-pro"` | 自定义 Dracula 变体，修复文本选中色的兼容问题 |

**键位增强：**
| 改动 | 说明 |
|------|------|
| `Cmd + 1~9` 全局切换标签页 | 无需进入 tab 模式，配合 Ghostty 的 unbind 实现 |
| 所有模式添加 `h/j/k/l` 导航 | 面板/标签页/调整大小/移动/滚动均支持 Vim 风格 |
| `Ctrl + a` 进入 tmux 兼容模式 | 为 tmux 用户提供肌肉记忆兼容层 |

### 🐟 Fish — Shell 行为与键位

**行为变更：**
| 改动 | 官方默认 | 本项目 | 原因 |
|------|----------|--------|------|
| 欢迎语 | 显示版本信息 | `fish_greeting ""` (关闭) | 保持终端启动干净 |
| 编辑模式 | Emacs 模式 | Vi 混合模式 (Vi + Emacs insert) | Vi 键位为主，保留 Ctrl-a/e 等 Emacs 快捷键 |
| 默认编辑器 | 无 | `EDITOR=hx` / `VISUAL=hx` | 统一使用 Helix |
| 分页器 | 无 | `MANPAGER` 使用 bat 语法高亮 | Man 手册页更易读 |
| Homebrew 自动更新 | 启用 | `HOMEBREW_NO_AUTO_UPDATE=1` | 避免每次安装包时卡在更新 |
| Fisher 插件路径 | `~/.config/fish` | `~/.local/share/fisher` | 隔离第三方插件，保持配置目录纯净 |
| Zellij 自动启动 | 不自动启动 | 在 Ghostty 中自动启动 | 无需手动 `zellij`，同时排除 SSH/Quick Terminal 等场景 |

**键位变更：**
| 改动 | 说明 |
|------|------|
| `Ctrl + e` (normal 模式) | 用 Helix 全屏编辑当前命令行 |
| Vi 光标形状 | normal=block, insert=line, replace=underscore |
| Tide vi_mode 标识 | `D` → `N`（对齐 Vim 社区的 Normal 缩写习惯） |

### ✏️ Helix — 编辑器键位与显示

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

### 🔧 Git — 工作流增强

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

## 7. 致谢 (Acknowledgments)

本项目的诞生离不开现代开源社区的繁荣生态，特别感谢以下卓越的项目构建了这套工作流的基石：

- [Ghostty](https://ghostty.org/) 
- [Zellij](https://zellij.dev/)
- [Fish](https://fishshell.com/) / [Fisher](https://github.com/jorgebucaran/fisher) / [Tide](https://github.com/IlanCosman/tide)
- [Helix](https://helix-editor.com/)
- [Mise](https://mise.jdx.dev/)
- [fzf](https://github.com/junegunn/fzf) / [zoxide](https://github.com/ajeetdsouza/zoxide) / [eza](https://github.com/eza-community/eza) / [bat](https://github.com/sharkdp/bat)
- [ripgrep](https://github.com/BurntSushi/ripgrep) / [grc](https://github.com/garabik/grc) / [GNU Coreutils](https://www.gnu.org/software/coreutils/) / [shellcheck](https://github.com/koalaman/shellcheck)
- [git-delta](https://github.com/dandavison/delta) / [glow](https://github.com/charmbracelet/glow) / [btop](https://github.com/aristocratos/btop) / [asciinema](https://github.com/asciinema/asciinema)
- [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) / [Maple Mono](https://github.com/subframe7536/maple-font) / [Geist Mono](https://github.com/vercel/geist-font) / [Nerd Fonts](https://www.nerdfonts.com/)
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) / [switchaudio-osx](https://github.com/deweller/switchaudio-osx)
- [GNU Stow](https://www.gnu.org/software/stow/)

---

## 8. 开源协议 (License)

本项目采用 [MIT License](LICENSE) 开源协议。

你可以自由地使用、学习、修改和分发本项目的代码，将其作为你打造个人专属工作流的起点。
