# dotfiles

使用 GNU Stow 管理 dotfiles。仓库按“包”组织：每个目录就是一个可 stow 的单元。

## 1. 依赖

```sh
# 软链管理工具
brew install stow 

# 终端(推荐安装 tip 版本)
brew install --cask ghostty@tip
# 多窗口管理器
brew install tmux
brew install zellij 
# 交互 shell
brew install fish
# 文本编辑器
brew install neovim
brew install helix

# 常用工具
brew install bat eza fzf grc switchaudio-osx gawk gun-sed grep python@3

# 说明：
# - `gnu-sed` 会提供 `gsed`，用于 `colorscheme` / `font-size` / `opacity` 等脚本。
# - `switchaudio-osx` 会提供 `SwitchAudioSource`，用于 `audio-volume`。
# - `grc` 用于 fish 的 `oh-my-fish/plugin-grc`（缺失不影响基础使用）。
# - `gawk`/`grep` 用于 tmux-copycat 的 / 搜索增强（缺失不影响 tmux 基础使用）。
# - `python@3` 用于 `print-256-hex-colors`（缺失不影响基础使用）。
```

## 2. 安装

### 2.1 拉取仓库

```sh
git clone --depth=1 https://github.com/windvalley/dotfiles.git "$HOME/dotfiles"

# 更新
cd "$HOME/dotfiles"
git pull --rebase
```

### 2.2 链接配置（stow）

链接核心配置到 `$HOME`：

```sh
cd "$HOME/dotfiles"
stow --restow --target="$HOME" --dir="$HOME/dotfiles" --dotfiles ghostty tmux fish
```

链接命令脚本（`bin/` -> `~/.local/bin`）：

```sh
mkdir -p "$HOME/.local/bin"
cd "$HOME/dotfiles"
stow --restow --target="$HOME/.local/bin" --dir="$HOME/dotfiles" bin
```

链接 Karabiner（`karabiner/` -> `~/.config/karabiner`）：

```sh
mkdir -p "$HOME/.config/karabiner"
cd "$HOME/dotfiles"
stow --restow --target="$HOME/.config/karabiner" --dir="$HOME/dotfiles" karabiner
```

## 3. 配置

### 3.1 配置 fish

将 fish 设为默认 shell：

```sh
which fish | sudo tee -a /etc/shells
chsh -s $(which fish)
```

重启终端后（或执行 `exec fish -l`），在 fish 里执行：

```fish
# 检查是否已经切换成功, 如果输出结果不是 fish 路径，
# 可能 tmux 缓存原因，请执行 tmux kill-server
echo $SHELL

# 让 fish 识别 Homebrew 安装的程序
fish_add_path (brew --prefix)/bin

# 生成命令补全（自动从 man 页面解析）
fish_update_completions

# 主题（只影响语法高亮，不影响 prompt；prompt 由 tide 控制）
fish_config theme choose dracula
```

### 3.2 配置 fisher

fisher 是 fish 的插件管理器。

```fish
# 安装 Fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# 安装插件
fisher install (cat ~/.config/fish/fish_plugins)
```

更多见：`fish/dot-config/fish/README.md`

### 3.3 配置 tide

tide 是 fish 的 prompt 插件。

```fish
tide configure
```

## 4. 使用方法

### 4.1 常用命令（bin/）

这些命令会在 stow `bin` 后出现在 `~/.local/bin`：

- `colorscheme <name>`: 同时切换 Neovim 和 Ghostty 主题
- `font-size <1-200>`: 设置 Ghostty `font-size`
- `opacity <0.0-1.0>`: 设置 Ghostty `background-opacity`

fish 内置了一些缩写（见 `fish/dot-config/fish/config.fish`）：`cs`/`fs`/`o`。

### 4.2 ghostty

- 配置文件：`~/.config/ghostty/config`
- 变更配置后生效：`cmd+shift+,`
- Toggle 快捷终端（quick terminal）：`cmd+;`

更多见：`ghostty/dot-config/ghostty/README.md`

### 4.3 tmux

- 配置文件：`~/.tmux.conf`
- 变更配置后生效：`cmd+a+r`

### 4.4 Homebrew 前缀（Intel / Apple Silicon）

- Apple Silicon: 通常是 `/opt/homebrew`
- Intel: 通常是 `/usr/local`

写脚本/配置时优先使用：

```fish
brew --prefix
```

### 4.5 stow 的用法说明

```sh
# 安装或重新安装
#
#  -nv 模拟安装（查看会做什么，但不实际执行）, 去掉该参数即可实际执行;
#  --restow 重新安装（即重新创建符号链接，先删除再创建）;
#  --target 指定符号链接目标目录(实际工作的目录, 一般都是用户家目录，即 $HOME);
#  --dir 指定dotfiles源文件目录, dotfiles目录下的文件的路径层级要符合实际工作的目录层级;
#  --dotfiles 将 dot- 开头的包名转换为 . 开头的隐藏文件, 用于特殊处理
#
# 最后的 ghostty 就是 dotfiles 目录下的，路径层级为：
# ghostty
# └── dot-config   # 对应实际的 .config
#    └── ghostty
#        ├── config
#        ├── config.example
#        └── README.md
stow -nv --restow --target=$HOME --dir=$HOME/dotfiles --dotfiles ghostty

# 卸载, 即删除符号链接;
# 去掉 -nv 参数即可实际执行
stow -nv --delete --target=$HOME --dir=$HOME/dotfiles --dotfiles ghostty
```
