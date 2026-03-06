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
#             (Ghostty) 管理全局调色板。确保全量工具的主题体验绝对一致。
#
# NOTE: 若修改了本文件，可通过执行 `exec fish` 使其立即生效
# ==============================================================================

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

# Homebrew: 兼容 Apple Silicon (/opt/homebrew) 和 Intel Mac (/usr/local)
for brew_prefix in /opt/homebrew /usr/local
    if test -x $brew_prefix/bin/brew
        eval ($brew_prefix/bin/brew shellenv)
        break
    end
end

# Homebrew：默认禁止自动更新
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# PATH: fish_add_path 自动处理重复，无需手动检查
# 使用 --path 参数仅修改当前会话的 PATH，避免污染 Universal 变量 (fish_user_paths)
test -d "$HOME/.local/bin"; and fish_add_path --path "$HOME/.local/bin"
test -d "/Applications/Ghostty.app/Contents/MacOS"; and fish_add_path --append --path "/Applications/Ghostty.app/Contents/MacOS"
test -d "$HOME/.orbstack/bin"; and fish_add_path --append --path "$HOME/.orbstack/bin"

# 优先使用可复刻的环境变量（避免依赖 universal state）
if type -q hx
    set -gx EDITOR hx
    set -gx VISUAL hx
end

# 抑制由于 Python 3.12+ 结合 os.fork() 引引发的系统级 DeprecationWarning 刷屏问题（如 grc）
# 使用环境变量而非 alias，因为 oh-my-fish/plugin-grc 内部使用 `command grc` 会跳过 alias
set -gx PYTHONWARNINGS "ignore::DeprecationWarning"

# --- AIChat Configuration ---
# 强制 aichat 在 macOS 下也使用 ~/.config/aichat 作为配置目录
set -gx AICHAT_CONFIG_DIR "$HOME/.config/aichat"

# 剥离 aichat 运行状态与数据文件到独立目录 (XDG_DATA_HOME 规范)
set -gx AICHAT_MESSAGES_FILE "$HOME/.local/share/aichat/messages.md"
set -gx AICHAT_SESSIONS_DIR "$HOME/.local/share/aichat/sessions"

# 🚀 交互式会话专用配置区 (Interactive Session Only)
if status is-interactive
    # =========================================================================
    # 1. 【生命周期分水岭】：优先把复用器拦截判定放在这里！
    # =========================================================================
    # 自动启动 Zellij
    # 跳过: 已在 zellij 中 / SSH / Quick Terminal / 禁用标志 / 未安装 / 非 Ghostty 运行时;
    if not set -q ZELLIJ_SESSION_NAME; and not set -q SSH_CONNECTION; and not set -q GHOSTTY_QUICK_TERMINAL; and not set -q ZELLIJ_AUTO_DISABLE; and type -q zellij; and test "$GHOSTTY_RUNTIME" = 1
        if zellij setup --check &>/dev/null
            exec zellij
        else
            echo "⚠️ Zellij 配置检查失败，跳过自动启动。"
            echo "   修复: 运行 'zellij setup --check' 查看详情"
            echo "   禁用: 运行 'set -Ux ZELLIJ_AUTO_DISABLE 1' 永久关闭"
        end
    end

    # =========================================================================
    # 2. 【视觉 UI 层】：关闭欢迎语、设置快捷键、光标样式、Tide 提示符等
    # =========================================================================
    # 关闭默认欢迎语
    set -g fish_greeting ""

    # Man 手册页语法高亮（需 brew install bat）
    if type -q bat
        set -gx MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -l man -p'"
    end

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

    # =========================================================================
    # 3. 【操作捷径重写层】：所有的 alias 和 abbr 大军在此集结
    # =========================================================================
    # 针对 Ghostty 的 xterm-ghostty 终端类型在远程机器缺失的问题
    # 在执行 ssh 或 orb 命令时动态降级 TERM 为 xterm-256color 以保证远程兼容性
    alias ssh="TERM=xterm-256color command ssh"
    if type -q orb
        alias orb="TERM=xterm-256color command orb"
    end

    # ~/dotfiles/bin/ 下的自定义命令
    # ghostty & helix & zellij 主题切换
    abbr -a -g cs colorscheme # 详情见自定义命令 colorscheme
    # ghostty 字体大小设置
    abbr -a -g fs font-size # 详情见自定义命令 font-size
    # ghostty 透明度设置
    abbr -a -g o opacity # 详情见自定义命令 opacity
    # 电脑音量设置以及渠道选择
    abbr -a -g vol audio-volume # 详情见自定义命令 audio-volume

    # 用 hx 替代 vi/vim
    abbr -a -g vi hx # 统一唤起 Helix 现代文本编辑器
    abbr -a -g vim hx # 统一唤起 Helix 现代文本编辑器
    abbr -a -g h hx # 统一唤起 Helix 现代文本编辑器

    # Git 缩写
    abbr -a -g g git # Git 基础命令调用入口
    abbr -a -g ga 'git add' # 添加文件到暂存区
    abbr -a -g gs 'git status' # 查看工作区及合并状态
    abbr -a -g gd 'git diff' # 查看工作区尚未暂存的修改
    abbr -a -g gds 'git diff --staged' # 查看暂存区里尚未提交的差异
    abbr -a -g gb 'git branch' # 查看本地分支
    abbr -a -g gba 'git branch -a' # 查看全部(含远程)分支
    abbr -a -g gbd 'git branch -D' # 强制删除分支
    abbr -a -g gc 'git commit' # 提交代码
    abbr -a -g gca 'git commit --amend' # 追加或修改最后一次提交
    abbr -a -g gcm 'git commit -m' # 带信息提交代码
    abbr -a -g gcam 'git commit -a -m' # 暂存所有已跟踪文件并提交代码
    abbr -a -g gp 'git push' # 推送代码到远程仓库
    abbr -a -g gpl 'git pull' # 拉取远程代码
    abbr -a -g gm 'git merge' # 合并分支
    abbr -a -g gms 'git merge --squash' # 将整条开发分支的多次提交合并压缩为一次改动
    abbr -a -g grb 'git rebase' # 变基分支
    abbr -a -g grbc 'git rebase --continue' # 解决冲突后继续跑变基
    abbr -a -g grbi 'git rebase -i' # 交互式手工挑选、压缩变基
    abbr -a -g gco 'git checkout' # 检出分支或文件 (传统方式)
    abbr -a -g gcl 'git clean -fd' # 清理未跟踪文件和目录（危险操作，请确认后使用）
    abbr -a -g gsw 'git switch' # 切换分支 (推荐的现代分支方式)
    abbr -a -g gswc 'git switch -c' # 创建并切换分支
    abbr -a -g gr 'git reset' # 重置暂存区或 HEAD 状态
    abbr -a -g grh 'git reset HEAD' # 仅重置暂存区 (撤销 add)
    abbr -a -g gro 'git restore' # 撤销工作区修改 (推荐的现代重置方式)
    abbr -a -g gros 'git restore --staged' # 撤销暂存区修改
    abbr -a -g gsta 'git stash' # 雪藏当前未提交改动清空工作区
    abbr -a -g gstp 'git stash pop' # 弹出并恢复雪藏内容
    abbr -a -g gt 'git tag' # 查看本地所有标签
    abbr -a -g gts 'git tag -s' # 创建带本地 GPG 签名的标签
    abbr -a -g gg 'git log' # 查看原始 Git 提交日志
    abbr -a -g gl 'git log --oneline --decorate --graph' # 带分支图谱路径、彩色树状结构的美化历史日志
    abbr -a -g glo 'git log --oneline' # 单行极简日志
    abbr -a -g gls 'git log --stat' # 附带每次提交具体增删文件统计信息的日志

    # 常用命令增强
    abbr -a -g mkdir 'mkdir -p' # 级联创建多级目录 (如果父目录不存在自动创建)

    # AI: 诊断上一条失败命令
    abbr -a -g -- '??' ai_diag_last
    # AI: 将自然语言快速转为可执行命令
    abbr -a -g -- '?' 'aichat -e'

    # 目录跳转
    abbr -a -g ... ../.. # 极速向父级两层目录跳转
    abbr -a -g .... ../../.. # 极速向父级三层目录跳转
    abbr -a -g ..... ../../../.. # 极速向父级四层目录跳转

    # 用 eza 替代 ls（需 brew install eza）
    if type -q eza
        abbr -a -g ls eza # 现代版的文件列表显示
        abbr -a -g ll eza -l # 现代版文件列表附带详细权限尺寸等信息
        abbr -a -g lls eza -l # 兼容手滑：lls -> ll
    end

    # =========================================================================
    # 4. 【交互环境加载工具层】：如 zoxide 跳转等吃性能且非界面不可用的命令
    # =========================================================================

    # zoxide: 智能目录跳转 (z 替代传统的 cd)
    # 用法: z <目录关键词> - 跳转到匹配的目录
    #      zi <关键词> - 交互式选择 (需要安装 fzf)
    #      z foo bar - 匹配包含 foo 和 bar 的目录
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
