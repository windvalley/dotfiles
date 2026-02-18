# Dotfiles 管理的 fish 配置约定（尽量少文件，但保持可维护）
# - dotfiles 仓库只跟踪 `config.fish` + `fish_plugins` + functions目录下自己编写的 fish 文件。
# - 你当然可以把所有配置都写在 `config.fish`，但它会越变越大且每次启动都会执行。
# - 更重的逻辑建议放到 `functions/*.fish`（autoload），更早/更独立的初始化放到 `conf.d/*.fish`。
# - 机器差异/私有值放本地文件且不入库：`~/.config/fish/conf.d/local.fish`。
# - Fisher 会在 `functions/`、`conf.d/`、`completions/` 生成/更新插件文件，不要把这些自动生成的产物提交到 git。
#
# NOTE: 更新本文件使及时生效的方法：exec fish

# 关闭默认欢迎语
set -g fish_greeting ""

# 新机器若还没有主题/颜色，手动执行一次即可。
# 列出有哪些主题可供选择：fish_config theme list
# NOTE: fish_config theme 只控制语法高亮颜色（命令、参数、字符串等的颜色），
#       不包括 Prompt（提示符）外观
#fish_config theme choose dracula

# Homebrew：默认禁止自动更新
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# PATH: fish_add_path 自动处理重复，无需手动检查
# 首次设置后，路径会保存到 fish_variables，后续启动幂等无副作用
test -d "$HOME/.local/bin"; and fish_add_path "$HOME/.local/bin"
test -d "$HOME/.opencode/bin"; and fish_add_path "$HOME/.opencode/bin"
test -d "/Applications/Ghostty.app/Contents/MacOS"; and fish_add_path --append "/Applications/Ghostty.app/Contents/MacOS"

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
    # ghostty & nvim 主题切换
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
    abbr -a -g ll 'ls -la'
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
    end

    # brew install --cask android-platform-tools
    # brew install scrcpy
    # sc: 无线投屏到电脑 (电脑作为显示器), 默认参数: 关闭声音 H265编码 1440码率
    alias sc "nh scrcpy -w -S --no-audio --video-codec=h265 -m1440"
    # scam: 使用手机摄像头作为视频源 (手机变成电脑摄像头)
    alias scam "nh scrcpy --video-source=camera --no-audio --video-codec=h265 --camera-size=1080x720"

    # 自动启动 Zellij
    # 跳过: 已在 zellij 中 / SSH / Quick Terminal / 禁用标志 / 未安装
    if not set -q ZELLIJ_SESSION_NAME; and not set -q SSH_CONNECTION; and not set -q GHOSTTY_QUICK_TERMINAL; and not set -q ZELLIJ_AUTO_DISABLE; and type -q zellij; and test "$TERM_PROGRAM" = ghostty
        # 防镜像: 记录启动 zellij 的 Ghostty PID，该进程存活期间新窗口跳过
        # (不用 zellij list-sessions: 无服务端时挂起，且输出含 ANSI 码)
        set -l pid_file /tmp/zellij-ghostty.pid
        set -l skip 0
        if pgrep -x zellij >/dev/null 2>&1; and test -f $pid_file
            set -l saved (cat $pid_file 2>/dev/null)
            test -n "$saved"; and kill -0 $saved 2>/dev/null; and set skip 1
        end
        if test $skip -eq 0
            # session_name / attach_to_session / default_layout 均由 config.kdl 管理
            command ps -o ppid= -p %self | string trim >$pid_file
            exec zellij
        end
    end

    # zoxide: 智能目录跳转 (z 替代传统的 z)
    # 用法: z <目录关键词> - 跳转到匹配的目录
    #      zi <关键词> - 交互式选择 (需要安装 fzf)
    #      z foo bar   - 匹配包含 foo 和 bar 的目录
    if type -q zoxide
        zoxide init fish | source
    end
end
