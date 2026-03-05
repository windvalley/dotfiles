function _aichat_fish -d "通过 aichat 基于当前命令行生成命令"
    if not command -sq aichat
        echo "❌ 未找到 aichat，请先安装并配置"
        return 127
    end

    # 优先使用参数（方便手动调用/测试）；否则读取当前命令行缓冲区
    set -l input ""
    if test (count $argv) -gt 0
        set input (string join " " -- $argv)
    else
        set input (commandline)
    end

    set input (string trim -- "$input")
    if test -z "$input"
        return
    end

    # 约定：描述必须以 # 开头；否则一律视为“命令行 -> 解释”。
    set -l is_description false
    if string match -qr '^#' -- "$input"
        set is_description true
        set input (string replace -r '^#\s*' '' -- "$input")
        set input (string trim -- "$input")
        if test -z "$input"
            return
        end
    end

    if test "$is_description" != true
        # 是命令行：解释命令含义（不修改命令行）
        if string match -qr 'sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{30,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{30,}|-----BEGIN[[:space:]]+.*PRIVATE KEY-----' -- "$input"
            echo "⚠️ 检测到疑似敏感信息，已跳过解释。请先手动打码后重试。"
            return 1
        end

        set -l os (uname -s)
        set -l platform_desc "$os"
        if test "$os" = Darwin
            set platform_desc "macOS (Darwin, BSD userland)"
        end

        set -l explain_prompt (printf '%s\n' \
            '你是一个专业的 Shell 命令解释器。' \
            '' \
            '环境：' \
            "- OS: $platform_desc" \
            '- Shell: fish' \
            '' \
            '请用中文解释命令，并使用 Markdown 输出。' \
            '注意：我会把【原始命令】作为解释内容的第一行单独输出，所以你不要重复粘贴命令本身。' \
            '' \
            '输出结构：' \
            '## 意图' \
            '一句话说明它要做什么' \
            '' \
            '## 拆解' \
            '按执行顺序拆解每段/每个参数的含义' \
            '' \
            '## 风险与副作用' \
            '例如删除、覆盖、网络请求、权限、平台差异（GNU vs BSD）' \
            '' \
            '## 更安全的替代方案（可选）' \
            '给出替代命令并说明差异' \
            '' \
            '要求：只解释，不要执行。' \
            | string collect)

        set -l show_status_line false
        if status --is-interactive
            # 不覆盖命令行：另起一行显示静态状态提示；输出解释前会清掉该行。
            set show_status_line true
            printf '\n⌛ Explaining...\n' >&2
        end

        set -l explanation_body (aichat --no-stream --prompt "$explain_prompt" -- "$input" | string collect)

        if test "$show_status_line" = true
            # 回到状态行并清掉，让解释内容的第一行就是“被解释的命令行”
            printf '\033[1A\033[2K\r' >&2
        end

        # 第一行必须是被解释的命令行
        if status --is-interactive; and command -sq bat
            printf '%s\n\n%s\n' "$input" "$explanation_body" | bat -l markdown -p --paging=always
        else
            printf '%s\n\n%s\n' "$input" "$explanation_body"
        end

        if status --is-interactive
            commandline -f repaint
        end
        return
    end

    # 是描述：生成多个候选命令，并用 fzf 交互选择
    if status --is-interactive; and test (count $argv) -eq 0; and command -sq fzf
        set -lx __AICHAT_FISH_INPUT "$input"
        set -lx __AICHAT_FISH_OS (uname -s)
        set -lx __AICHAT_FISH_SHELL fish

        # 用 fzf 的 start:reload 实现“动态加载”，避免覆盖用户正在输入的描述文字
        set -l reload_cmd "fish -c '_aichat_fish_candidates'"
        set -l selected (
            printf '' |
                fzf --disabled \
                    --height=40% \
                    --layout=reverse \
                    --border \
                    --cycle \
                    --prompt='AI> ' \
                    --header='macOS + fish | Generating candidates...' \
                    --bind "start:reload:$reload_cmd" \
                    --bind 'esc:cancel'
        )

        if test $status -ne 0; or test -z "$selected"
            commandline -f repaint
            return
        end

        commandline "$selected"
        commandline -f repaint
        return
    end

    # 非交互场景：输出第一个候选（或回退到单条生成）
    set -l candidates (_aichat_fish_candidates "$input")
    if test (count $candidates) -gt 0
        echo "$candidates[1]"
        return
    end

    aichat --no-stream -e -- "$input"
end
