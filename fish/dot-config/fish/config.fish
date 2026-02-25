# ==============================================================================
# Fish Shell 核心配置约定 (追求极简与高性能)
# ==============================================================================
# - 📦 主配置: 本文件 (config.fish) 仅保留核心 PATH、全局环境变量、轻量缩写 (abbr) 和初始键绑定。
# - ⚡️ 按需加载 (Autoload): 任何自定义功能函数必须独立存放在 `functions/` 目录下 (如 d.fish, nh.fish)。
#             ✅ 优势 1：大幅提升终端每次新建 Tab 的启动速度。
#             ✅ 优势 2：修改函数内容后开箱即用，无需执行 source 命令重载配置。
# - 🔒 私密环境: 不想提交进 Git 的私有凭证或机器特定变量放在本地 `config.local.fish`。
# - 🧩 第三方隔离: Fisher 第三方插件被硬路由到 `~/.local/share/fisher`，确保配置目录干爽纯洁。
# - 🎨 主题隔离: Fish 自身保持默认 ANSI 配色，无需配置 theme。颜色渲染统一交由外层终端
#             (Ghostty) 管理全局调色板。这样保证全量工具的主题体验绝对一致。
#
# NOTE: 若修改了本文件，可通过执行 `exec fish` 使其立即生效
# ==============================================================================

# 关闭默认欢迎语
set -g fish_greeting ""

# --- Fisher Path Isolation ---
# 将第三方插件的文件（functions/conf.d/completions）隔离到 ~/.local/share/fisher
# 确保 ~/.config/fish 目录仅包含自己编写的配置，便于集中通过 Stow 和 Git 进行版本控制
set -g fisher_path ~/.local/share/fisher

set fish_complete_path $fish_complete_path[1] $fisher_path/completions $fish_complete_path[2..-1]
set -g fish_function_path $fish_function_path[1] $fisher_path/functions $fish_function_path[2..-1]

for file in $fisher_path/conf.d/*.fish
    if test -f $file
        source $file
    end
end
# -----------------------------

# 抑制由于 Python 3.12+ 结合 os.fork() 引发的系统级 DeprecationWarning 刷屏问题（如 grc）
if type -q grc
    alias grc="env PYTHONWARNINGS=ignore::DeprecationWarning grc"
end

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

    # Tide: 确保 vi_mode 组件出现在 prompt 左侧
    set -g tide_left_prompt_items vi_mode os pwd git newline character

    # Tide: vi_mode 提示符 (自动纠正 Universal 变量，一劳永逸)
    # Tide 默认用 Fish 内部模式名首字母 (default→D)，这里纠正为 Vim 社区通用的 N (Normal)
    # 使用 set -U 直接写入持久化的 Universal 变量，仅在值不符合预期时才写入，避免每次启动都触发磁盘 IO
    if test "$tide_vi_mode_icon_default" != N
        set -U tide_vi_mode_icon_default N
    end


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

    # 用 eza 替代 ls（需 brew install eza）
    if type -q eza
        abbr -a -g ls eza
        abbr -a -g ll eza -l
    end

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
