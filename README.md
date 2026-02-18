# dotfiles

这是一套精心设计的 **现代 macOS 终端开发环境**。

基于 GNU Stow 进行模块化管理，核心目标是打造一个**极简、高效、开箱即用**的工作流。它集成了高性能终端、现代化编辑器、高效 Shell 和多窗口管理工具，并确保它们在视觉和交互上保持高度一致。

## 0. TL;DR (快速开始)

最简单的方法是使用一键安装脚本：

```sh
# 克隆仓库并运行安装脚本
git clone --depth=1 https://github.com/windvalley/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
./install.sh
```

> [!NOTE]
> `install.sh` 支持多次执行（幂等），你可以放心地运行它来更新依赖或修复配置链接。

该脚本会自动安装 Homebrew（如果缺失）、ghostty、fish、zellij、helix、mise、stow, 并完成配置链接以及 Fish Shell 的初始化。

> [!TIP]
> 如果你想手动精准控制安装过程，请参考下面的详细步骤。

## 1. 项目结构

本仓库包含以下 7 个配置包：

- `ghostty/`: Ghostty（/ˈɡoʊs.ti/，Ghost + ty）终端配置
- `fish/`: Fish（/fɪʃ/，**F**riendly **I**nteractive **SH**ell）shell 配置
- `zellij/`: Zellij（/ˈzɛl.ɪdʒ/，源自阿拉伯语，马赛克瓷砖拼贴艺术）终端复用器，易于配置
- `helix/`: Helix（/ˈhiː.lɪks/，螺旋）现代模态编辑器，开箱即用
- `karabiner/`: Karabiner（/ˌkær.əˈbiː.nər/，德语，登山扣）键盘映射（交换 Caps Lock 和 Left Control）
- `git/`: Git 基础配置（别名、Delta 美化、全局忽略等）
- `mise/`: Mise（/miːz/，源自法语 mise en place，就位准备）工具版本管理器配置
- `bin/`: 自定义命令脚本（自动链接到 `~/.local/bin`）

> [!NOTE]
> `tmux/` 目录仅作为历史配置存档保留，当前方案已切换至 Zellij，默认不安装 tmux。

## 2. 依赖项

### 2.1 必选依赖 (核心功能)

```sh
# 软链管理工具
brew install stow

# 终端
brew install --cask ghostty@tip

# 多窗口管理(替代 tmux)
brew install zellij

# 交互 Shell
brew install fish

# 文本编辑器(替代 vim/neovim)
brew install helix

# 软件版本管理工具
brew install mise

# Git 美化工具 (Diff 语法高亮)
brew install git-delta

# 字体
brew install --cask font-jetbrains-mono-nerd-font
```

### 2.2 可选依赖 (增强功能)

```sh
# 常用工具
brew install bat eza fzf zoxide grc gawk gnu-sed grep glow

# 音量控制
brew install switchaudio-osx
```

**说明：**
- `zoxide`: 智能目录跳转工具，替代传统的 `cd`。用法：`z <关键词>` 跳转目录，`zi <关键词>` 交互式选择（需 fzf）。
- `gnu-sed`: 提供 `gsed`，用于 `colorscheme` / `font-size` / `opacity` 等脚本。
- `switchaudio-osx`: 提供 `SwitchAudioSource`，用于 `audio-volume`。
- `grc`: 通用彩色输出查看器 (Generic Colouriser)，配合 fish 插件为 `ping` / `ls` / `docker` / `diff` 等命令提供彩色输出增强。
- `glow`: 终端 Markdown 阅读器，用于 Helix 预览功能。

## 3. 安装步骤

### 3.1 一键安装 (推荐)

仓库根目录下提供了一个 `install.sh` 脚本，可以自动化完成绝大部分安装和配置工作。

**该脚本将执行以下操作：**
1. 检查并安装 **Homebrew**（如果尚未安装）。
2. 安装所有常用的 **Brew 依赖**（stow, zellij, fish, helix, mise, bat, eza, fzf, zoxide, grc, gawk, gnu-sed, grep, switchaudio-osx, glow）。
3. 安装 **Nerd Fonts**（默认 JetBrains Mono, Maple Mono, Geist Mono）。
4. 安装 **Ghostty** 终端（通过 `brew install --cask ghostty@tip`）。
5. 使用 `stow` 将所有配置软链到正确的位置。
6. 检查并将 **Fish** 设为默认 Shell。
7. 安装 **Fisher** 插件管理器并同步插件。

**使用方法：**
```sh
cd "$HOME/dotfiles"
./install.sh
```

**提示：** 该脚本支持多次执行（幂等），可随时运行以确保环境处于最新状态。

---

### 3.2 手动安装步骤 (可选)

如果你更倾向于手动操作，请按以下顺序执行：

#### 3.2.1 拉取仓库

```sh
git clone --depth=1 https://github.com/windvalley/dotfiles.git "$HOME/dotfiles"

# 更新
cd "$HOME/dotfiles"
git pull --rebase
```

#### 3.2.2 链接配置（stow）

链接核心配置到 `$HOME`：

```sh
cd "$HOME/dotfiles"
stow --restow --target="$HOME" --dir="$HOME/dotfiles" --dotfiles ghostty helix zellij mise git
```

链接 Fish 配置（需预处理以避免 stow 冲突）：

```sh
# 如果 ~/.config/fish 是软链接（如之前手动创建的），需先解除再创建目录。
# 原因：fish 会在该目录下自动生成大量运行时文件，若整个目录是软链接，
# 这些文件会进入 dotfiles 仓库，产生不必要的 git 变更。
ls -ld ~/.config/fish
unlink ~/.config/fish
mkdir -p ~/.config/fish

# 如果 config.fish 或 fish_plugins 已存在（如 fish 自动生成的），需先备份
mv ~/.config/fish/{config.fish,config.fish.bak}
mv ~/.config/fish/{fish_plugins,fish_plugins.bak}

# 执行 stow
cd "$HOME/dotfiles"
stow --restow --target="$HOME" --dir="$HOME/dotfiles" --dotfiles fish
```

> [!TIP]
> 以上预处理步骤按需执行，如果对应的软链接或文件不存在则跳过即可。
> `install.sh` 已自动处理这些情况，无需手动操作。

链接命令脚本（`bin/` -> `~/.local/bin`）：

```sh
mkdir -p "$HOME/.local/bin"
cd "$HOME/dotfiles"
stow --restow --target="$HOME/.local/bin" --dir="$HOME/dotfiles" bin
```

链接 Karabiner（`karabiner/` -> `~/.config/karabiner`）：

```sh
cd "$HOME/dotfiles"
stow --restow --target="$HOME" --dir="$HOME/dotfiles" --dotfiles karabiner
```

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

# 让 fish 识别 Homebrew 安装的程序
fish_add_path (brew --prefix)/bin

# 生成命令补全（自动从 man 页面解析）
fish_update_completions

# 主题（只影响语法高亮，不影响 prompt；prompt 由 tide 控制）
fish_config theme choose dracula
```

### 4.2 从 zsh 迁移

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
> 可用 `echo $PATH | tr ' ' '\n'` 查看当前所有路径。

### 4.3 配置 fisher

fisher 是 fish 的插件管理器。

```fish
# 安装 Fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# 安装插件
fisher install (cat ~/.config/fish/fish_plugins)
```

更多见：`fish/dot-config/fish/README.md`

### 4.4 配置 tide

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

### 4.5 配置 Git

**1. 配置用户信息**

安装完成后，请务必设置你的 Git 用户名和邮箱：

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**2. 自定义全局忽略文件**

仓库中已包含通用的 `~/.gitignore`（通过 `core.excludesfile` 配置）。如果你有特定的文件需要全局忽略（例如 IDE 配置、临时文件等），可以直接编辑该文件：

```bash
# 添加自定义忽略规则 (例如忽略所有 .log 文件)
echo "*.log" >> ~/.gitignore
```

> [!TIP]
> 上述修改会直接更新 `~/dotfiles/git/dot-gitignore`，建议将这些变更提交到你自己的 dotfiles 仓库中。

## 5. 使用方法

### 5.1 Ghostty 终端

**配置文件**：`~/.config/ghostty/config`

**注意**：标签页功能已禁用（由 Zellij 统一管理），多窗口功能仍可用。

**快捷键**：
| 快捷键 | 功能 |
|--------|------|
| `Cmd + Shift + ,` | 重载配置（修改配置文件后按此快捷键生效） |
| `Cmd + ;` | 打开 Quick Terminal（自定义快捷键）|
| `Cmd + d` | 垂直分屏 |
| `Cmd + Shift + d` | 水平分屏 |
| `Cmd + [ / ]` | 切换分屏 |

> [!NOTE]
> 建议使用 Zellij 的标签页和面板功能替代 Ghostty 原生标签页和分屏功能，以获得更灵活的布局控制和跨会话保持能力。

---

### 5.2 Zellij 终端复用器

**配置文件**：`~/.config/zellij/config.kdl`

**自动启动**：本配置在 fish 中集成了 Zellij 自动启动逻辑，打开新终端窗口时会自动启动或挂载到 Zellij 会话。以下情况会自动跳过：
- 已在 Zellij 会话中
- 通过 SSH 连接
- 在 Ghostty 的 Quick Terminal 中
- 设置了环境变量 `ZELLIJ_AUTO_DISABLE`

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
| `Ctrl + a` | 进入 tmux 兼容模式 |

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

### 5.3 Fish Shell

**配置文件**：`~/.config/fish/config.fish`

**内置缩写**：
| 缩写 | 完整命令 |
|------|----------|
| `cs` | `colorscheme` |
| `fs` | `font-size` |
| `o` | `opacity` |
| `vol` | `audio-volume` |

**常用命令**：
| 命令 | 功能 |
|------|------|
| `fish_update_completions` | 更新命令补全 |
| `fish_add_path <path>` | 添加路径 |
| `fish_config` | 打开交互配置 |

**Tide prompt**：`tide configure`（交互式配置）

**Vi 模式**：
Fish 支持 Vi 风格编辑模式，本配置已默认启用。

| 快捷键 | 功能 |
|--------|------|
| `Esc` | 进入 Vi 正常模式 |
| `i`/`a` | 进入插入模式 (光标前/光标后) |
| `h`/`l` | 光标左/右移动 |
| `k`/`j` | 上一条/下一条命令历史（基于输入过滤） |
| `w`/`b` | 下一个/上一个单词 |
| `0`/`$` | 行首/行尾 |
| `d` | 删除 (配合移动命令，如 dw, dd) |
| `y` | 复制 (配合移动命令，如 yw, yy) |
| `p` | 粘贴 |
| `u` | 撤销 |

在 Vi 正常模式下可以使用所有 Vim 风格的编辑命令。

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
  ```bash
  # Go
  go install golang.org/x/tools/gopls@latest
  go install golang.org/x/tools/cmd/goimports@latest

  # Python
  pip install python-lsp-server

  # Rust
  brew install rust-analyzer

  # TypeScript
  npm i -g typescript-language-server typescript
  ```
- **重启 LSP**：`:lsp-restart`
- **查看文档**：`:config-open` 打开配置，`:config-reload` 重载

---

### 5.5 Mise 工具版本管理

**配置文件**：`~/.config/mise/config.toml`

**常用命令**：
| 命令 | 功能 |
|------|------|
| `mise install` | 安装配置中声明的工具版本 |
| `mise ls` | 列出已安装的工具 |
| `mise ls-remote <tool>` | 查看可安装的远程版本 |
| `mise use <tool>@<version>` | 设置项目本地版本 |
| `mise use -g <tool>@<version>` | 设置全局默认版本 |
| `mise current <tool>` | 查看当前激活版本 |
| `mise prune` | 清理未使用的版本 |
| `mise doctor` | 诊断配置问题 |

**版本查询示例**：
```bash
mise ls-remote go      # 查看所有可用的 Go 版本
mise ls-remote node    # 查看所有可用的 Node.js 版本
mise ls-remote python  # 查看所有可用的 Python 版本
```

**Fish 自动激活**：无需手动配置，Fish 会通过 vendor_conf.d 自动激活 mise。

---

### 5.6 Git 配置用法

**配置文件**：
- `~/.gitconfig`: 核心配置
- `~/.gitignore`: 全局忽略文件

**核心特性**：
- **Delta 集成**：使用 `git-delta` 进行 Diff 语法高亮，支持行号、并排显示和颜色优化。
- **智能默认值**：
  - `pull.rebase = true`: 保持提交历史线性整洁。
  - `push.autoSetupRemote = true`: 自动关联远程分支。
  - `init.defaultBranch = main`: 默认分支名为 main。
  - `core.ignorecase = false`: 强制区分大小写（避免跨平台文件名问题）。

> [!IMPORTANT]
> **关于 `core.ignorecase = false`**：
> macOS 默认文件系统不区分大小写（Case-Insensitive），但 git 默认会尝试适配文件系统。强制开启 `ignorecase = false` 可以避免在重命名文件（如 `File.js` -> `file.js`）时 git 无法感知的问题。
> **副作用**：在终端进入目录时需严格匹配大小写（如 `cd Desktop` 不能写成 `cd desktop`），这有助于养成良好的路径书写习惯。

**常用别名**：
| 别名 | 命令 | 说明 |
|------|------|------|
| `git lg` | `log --graph ...` | 显示漂亮的提交图谱（精简版） |
| `git lga` | `log --graph ...` | 显示漂亮的提交图谱（详细版，含时间） |
| `git last` | `log -1 HEAD` | 查看最后一次提交 |
| `git cleanup` | `...` | 清理已合并的本地分支 |

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

- `colorscheme <name>`: 切换 Ghostty、Helix 和 Zellij 主题
- `font-size <1-200>`: 设置 Ghostty 字体大小
- `opacity <0.0-1.0>`: 设置 Ghostty 背景透明度
- `audio-volume`: 音量控制与输出设备切换（需要 `switchaudio-osx`）
- `preview-md <file>`: 在 Zellij 浮动窗口中预览 Markdown 文件（需要 `glow`）
- `colors-print`: 打印终端 256 色板
- `print-256-hex-colors`: 打印 256 色的十六进制色值

> [!TIP]
> **变更生效方式：**
> - `colorscheme`：Zellij 实时生效；Ghostty 需按 `Cmd + Shift + ,` 重载配置；Helix 需执行 `:config-reload` 使已打开的 buffer 生效。
> - `font-size` / `opacity`：修改的是 Ghostty 配置文件，需按 `Cmd + Shift + ,` 重载配置后生效。

fish 内置了一些缩写（见 `fish/dot-config/fish/config.fish`）：`cs`/`fs`/`o`/`vol`。
