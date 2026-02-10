## 一、安装

### 安装必备软件

```sh
brew install --cask ghostty@tip
brew install tmux
brew install fish fisher
brew install stow
brew install bat eza fzf
```

### 安装 dotfiles

```sh
git clone --depth=1 https://github.com/windvalley/dotfiles.git ~/dotfiles

cd ~/dotfiles
stow --restow --target=$HOME --dir=$HOME/dotfiles --dotfiles ghostty
stow --restow --target=$HOME --dir=$HOME/dotfiles --dotfiles tmux
stow --restow --target=$HOME --dir=$HOME/dotfiles --dotfiles fish
```

## 二、配置

### 配置 fish

```sh
# 将 Fish 设为默认 Shell
FISH=$(which fish)
echo $FISH | sudo tee -a /etc/shells
chsh -s $FISH
```

> 注意：配置完以上步骤，请先重启终端, 使 fish 生效, 再继续执行下面的步骤。

```sh
# 让 Fish 识别 Homebrew 安装的程序
fish_add_path $(brew --prefix)/bin

# 生成命令补全（自动从 man 页面解析）
fish_update_completion

# 配置主题：列出有哪些主题可供选择：fish_config theme list
# NOTE: fish_config theme 只控制语法高亮颜色（命令、参数、字符串等的颜色），
#       不包括 Prompt（提示符）外观, Prompt 的外观由 tide 插件控制
fish_config theme choose dracula
```

### 配置 fisher

> fisher 是 fish 的插件管理器

```sh
# 安装 Fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# 统一安装插件
fisher install $(cat ~/.config/fish/fish_plugins)
```

### 配置 tide

> tide 是 fish 的命令行 prompt 插件

```sh
tide configure
```

## 三、附录

### ghostty 的用法说明

> ~/.config/ghostty/config

- 变更配置后使配置生效: `cmd+shift+,`
- Toggle 快捷终端（quick terminal）: `cmd+;`

### tmux 的用法说明

> ~/.tmux.conf

- 变更配置后使配置生效: `cmd+a+r`

### stow 的用法说明

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
