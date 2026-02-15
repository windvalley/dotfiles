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

# 优先使用可复刻的环境变量（避免依赖 universal state）
if type -q nvim
    set -gx EDITOR hx
    set -gx VISUAL hx
end

# Homebrew：默认禁止自动更新
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# macOS 窗口卡顿临时规避
set -gx CHROME_HEADLESS 1
if status is-login; and type -q launchctl
    launchctl setenv CHROME_HEADLESS 1
end

# PATH：避免在 config.fish 里写 universal 变量；保持会话内确定性
if test -d "$HOME/.local/bin"
    fish_add_path --global --prepend "$HOME/.local/bin"
end

if test -d "$HOME/.opencode/bin"
    fish_add_path --global --prepend "$HOME/.opencode/bin"
end

if test -d "/Applications/Ghostty.app/Contents/MacOS"
    fish_add_path --global --append "/Applications/Ghostty.app/Contents/MacOS"
end

# 去重 PATH（不触碰 universal 变量）
set -l __deduped_path
for p in $PATH
    if not contains -- $p $__deduped_path
        set -a __deduped_path $p
    end
end
set -gx PATH $__deduped_path

# Docker Desktop 自动添加（若文件存在则加载）
if test -f "$HOME/.docker/init-fish.sh"
    source "$HOME/.docker/init-fish.sh"
end

if status is-interactive
    alias vi=nvim

    # Vi 模式：键绑定见 functions/fish_user_key_bindings.fish
    # (Fish autoload 机制要求该函数必须在 functions/ 目录下)

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

    # Git 缩写
    abbr -a -g g git
    abbr -a -g ga 'git add'
    abbr -a -g gs 'git status'
    abbr -a -g gd 'git diff'
    abbr -a -g gds 'git diff --staged'
    abbr -a -g gc 'git commit'
    abbr -a -g gp 'git push'
    abbr -a -g gl 'git pull'

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

    # 自动启动 Zellij
    # 跳过: 已在 zellij 中 / SSH / Quick Terminal / 禁用标志 / 未安装
    if not set -q ZELLIJ_SESSION_NAME; and not set -q SSH_CONNECTION; and not set -q GHOSTTY_QUICK_TERMINAL; and not set -q ZELLIJ_AUTO_DISABLE; and type -q zellij
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
end
