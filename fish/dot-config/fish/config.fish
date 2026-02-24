# Dotfiles 管理的 fish 配置约定（尽量少文件，但保持可维护）
# - dotfiles 仓库只跟踪 `config.fish` + `fish_plugins` + functions目录下自己编写的 fish 文件。
# - 你当然可以把所有配置都写在 `config.fish`，但它会越变越大且每次启动都会执行。
# - 更重的逻辑建议放到 `functions/*.fish`（autoload），更早/更独立的初始化放到 `conf.d/*.fish`。
# - 机器差异/私密环境变量放本地文件且不入库：`~/.config/fish/config.local.fish`。
# - Fisher 会在 `functions/`、`conf.d/`、`completions/` 生成/更新插件文件，不要把这些自动生成的产物提交到 git。
#
# NOTE: 更新本文件使及时生效的方法：exec fish

# 关闭默认欢迎语
set -g fish_greeting ""

# --- Fisher Path Isolation ---
# 将第三方插件的产生文件（functions/conf.d/completions）彻底隔离到 ~/.local/share/fisher
# 保持 ~/.config/fish 目录的高贵纯洁，完全受 GNU Stow 和 Git 掌控
set -g fisher_path ~/.local/share/fisher

set fish_complete_path $fish_complete_path[1] $fisher_path/completions $fish_complete_path[2..-1]
set -g fish_function_path $fish_function_path[1] $fisher_path/functions $fish_function_path[2..-1]

for file in $fisher_path/conf.d/*.fish
    if test -f $file
        source $file
    end
end
# -----------------------------

# 新机器若还没有主题/颜色，手动执行一次即可。
# 列出有哪些主题可供选择：fish_config theme list
# NOTE: fish_config theme 只控制语法高亮颜色（命令、参数、字符串等的颜色），
#       不包括 Prompt（提示符）外观
#fish_config theme choose dracula

# 抑制由于 Python 3.12+ 结合 os.fork() 引发的系统级 DeprecationWarning 刷屏问题（如 grc）
set -gx PYTHONWARNINGS "ignore::DeprecationWarning"

# Homebrew：默认禁止自动更新
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# Man 手册页语法高亮（需 brew install bat）
if type -q bat
    set -gx MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -l man -p'"
end

# PATH: fish_add_path 自动处理重复，无需手动检查
# 使用 --path 参数仅修改当前会话的 PATH，避免污染 Universal 变量 (fish_user_paths)
test -d "$HOME/.local/bin"; and fish_add_path --path "$HOME/.local/bin"
test -d "/Applications/Ghostty.app/Contents/MacOS"; and fish_add_path --append --path "/Applications/Ghostty.app/Contents/MacOS"

# 优先使用可复刻的环境变量（避免依赖 universal state）
if type -q hx
    set -gx EDITOR hx
    set -gx VISUAL hx
end

# 常用快捷函数
# d: 显示日期时间 (格式: 02-17 Tuesday 20:19:24)
function d
    date +"%m-%d %A %T"
end

# nh: 后台运行命令 (nohup + 丢弃输出)
# 用法: nh <命令> [参数...]
# 示例: nh scrcpy -w -S
function nh
    nohup $argv &>/dev/null &
end

# ch: 查询 cheat.sh 快速获取命令帮助
# 用法: ch <命令>
# 示例: ch tar, ch curl
function ch
    curl cheat.sh/$argv[1]
end

if status is-interactive
    # Vi 模式：键绑定见 functions/fish_user_key_bindings.fish
    # (Fish autoload 机制要求该函数必须在 functions/ 目录下)
    set -g fish_key_bindings fish_vi_key_bindings

    # Vi 光标形状
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    set fish_cursor_external line

    # Tide: vi_mode 提示符 (可复刻，覆盖 universal 默认值)
    set -g tide_left_prompt_items vi_mode os pwd git newline character
    set -g tide_vi_mode_icon_default N
    set -g tide_vi_mode_icon_insert I
    set -g tide_vi_mode_icon_replace R
    set -g tide_vi_mode_icon_visual V

    # ~/dotfiles/bin/ 下的自定义命令
    # ghostty & helix & zellij 主题切换
    abbr -a -g cs colorscheme
    # ghostty 字体大小设置
    abbr -a -g fs font-size
    # ghostty 透明度设置
    abbr -a -g o opacity
    # 电脑音量设置以及渠道选择
    abbr -a -g vol audio-volume

    # 用 hx 替代 vi/vim
    abbr -a -g vi hx
    abbr -a -g vim hx
    abbr -a -g h hx

    # Git 缩写
    abbr -a -g g git
    abbr -a -g ga 'git add'
    abbr -a -g gs 'git status'
    abbr -a -g gd 'git diff'
    abbr -a -g gds 'git diff --staged'
    abbr -a -g gc 'git commit'
    abbr -a -g gca 'git commit --amend'
    abbr -a -g gp 'git push'
    abbr -a -g gl 'git pull'
    abbr -a -g gco 'git checkout'
    abbr -a -g gr 'git restore'
    abbr -a -g grs 'git restore --staged'
    abbr -a -g gg 'git log'

    # 常用命令增强
    abbr -a -g mkdir 'mkdir -p'

    # 目录跳转
    abbr -a -g ... ../..
    abbr -a -g .... ../../..
    abbr -a -g ..... ../../../..

    # 用 bat 替代 cat（需 brew install bat）
    if type -q bat
        abbr -a -g cat bat
    end

    # 用 eza 替代 ls（需 brew install eza）
    if type -q eza
        abbr -a -g ls eza
        abbr -a -g ll eza -l
    end

    # brew install --cask android-platform-tools
    # brew install scrcpy
    # sc: 无线投屏到电脑 (电脑作为显示器), 默认参数: 关闭声音 H265编码 1440码率
    alias sc "nh scrcpy -w -S --no-audio --video-codec=h265 -m1440"
    # scam: 使用手机摄像头作为视频源 (手机变成电脑摄像头)
    alias scam "nh scrcpy --video-source=camera --no-audio --video-codec=h265 --camera-size=1080x720"

    # 自动启动 Zellij
    # 跳过: 已在 zellij 中 / SSH / Quick Terminal / 禁用标志 / 未安装 / 非 Ghostty 运行时
    # 逃生方法: 终端中执行 `set -Ux ZELLIJ_AUTO_DISABLE 1` 可永久禁用自动启动
    if not set -q ZELLIJ_SESSION_NAME; and not set -q SSH_CONNECTION; and not set -q GHOSTTY_QUICK_TERMINAL; and not set -q ZELLIJ_AUTO_DISABLE; and type -q zellij; and test "$GHOSTTY_RUNTIME" = 1
        if zellij setup --check &>/dev/null
            exec zellij
        else
            echo "⚠️  Zellij 配置检查失败，跳过自动启动。"
            echo "   修复: 运行 'zellij setup --check' 查看详情"
            echo "   禁用: 运行 'set -Ux ZELLIJ_AUTO_DISABLE 1' 永久关闭"
        end
    end

    # zoxide: 智能目录跳转 (z 替代传统的 cd)
    # 用法: z <目录关键词> - 跳转到匹配的目录
    #      zi <关键词> - 交互式选择 (需要安装 fzf)
    #      z foo bar   - 匹配包含 foo 和 bar 的目录
    if type -q zoxide
        zoxide init fish | source
    end
end

# ============================================================
# 加载本地忽略的私有配置 (API Keys, 机器特定别名等)
# 
# 任何不应被提交到 GitHub 的变量请写在下面这个文件中:
# touch ~/.config/fish/config.local.fish
# ============================================================
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
