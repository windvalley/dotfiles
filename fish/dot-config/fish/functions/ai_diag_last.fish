function ai_diag_last -d "将上一条失败命令及其输出交给 AI 诊断"
    if not set -q __AI_LAST_CMDLINE; or not set -q __AI_LAST_STATUS
        echo "⚠️ 未捕获到上一条命令上下文（需要交互式 fish 会话）。"
        return 1
    end

    set -l status_code "$__AI_LAST_STATUS"
    set -l pipestatus_list
    if set -q __AI_LAST_PIPESTATUS
        set pipestatus_list $__AI_LAST_PIPESTATUS
    else
        set pipestatus_list $status_code
    end

    set -l is_failure false
    for s in $pipestatus_list
        if test $s -ne 0
            set is_failure true
            break
        end
    end

    if test "$is_failure" != true
        echo "✅ 上一条命令退出码为 0，无需诊断。"
        return 0
    end

    set -l cmd "$__AI_LAST_CMDLINE"

    set -l excerpt ""
    if set -q __AI_LAST_SCREEN_FILE; and test -f "$__AI_LAST_SCREEN_FILE"
        # Try to extract excerpt starting from the last occurrence of the commandline.
        set -l match (command grep -nF -- "$cmd" "$__AI_LAST_SCREEN_FILE" | tail -n 1)
        if test -n "$match"
            set -l start (string split -m1 -- ':' "$match")[1]
            set excerpt (command sed -n "$start,\$p" "$__AI_LAST_SCREEN_FILE" | tail -n 200 | string collect)
        else
            set excerpt (tail -n 200 "$__AI_LAST_SCREEN_FILE" | string collect)
        end
    end

    if test -z "$excerpt"
        set excerpt "(no captured pane output; not running inside Zellij or dump-screen unavailable)"
    end

    # Best-effort redaction for common secret patterns.
    set -l redacted (string replace -r -- 'sk-[A-Za-z0-9]{20,}' '[REDACTED]' -- "$excerpt")
    set redacted (string replace -r -- 'ghp_[A-Za-z0-9]{30,}' '[REDACTED]' -- "$redacted")
    set redacted (string replace -r -- 'AKIA[0-9A-Z]{16}' '[REDACTED]' -- "$redacted")
    set redacted (string replace -r -- 'AIza[0-9A-Za-z_-]{30,}' '[REDACTED]' -- "$redacted")
    set redacted (string replace -r -- '-----BEGIN[[:space:]]+.*PRIVATE KEY-----' '[REDACTED]' -- "$redacted")

    set -l os (uname -s)
    set -l platform_desc "$os"
    if test "$os" = Darwin
        set platform_desc "macOS (Darwin, BSD userland)"
    end

    set -l pipestatus_text (string join ',' -- $pipestatus_list)
    set -l prompt (printf '%s\n' \
        '你是一个资深的 Shell 故障排查助手。请用中文输出。' \
        '' \
        '环境：' \
        "- OS: $platform_desc" \
        '- Shell: fish' \
        '' \
        '任务：' \
        '- 根据终端摘录诊断命令失败原因（优先考虑平台差异：macOS/BSD vs GNU/Linux）。' \
        '- 给出可直接复制的修复步骤与修正后的命令（必须兼容 macOS/BSD 与 fish）。' \
        '- 如果有多个可能原因：按概率排序，并说明如何验证。' \
        '' \
        '输出格式（Markdown）：' \
        '- 第 1 行必须且只能是原始命令（用代码包裹）' \
        '- 之后按章节输出：## 可能原因、## 如何验证、## 修复方案、## 更安全的替代方案（可选）' \
        '' \
        '原始命令：' \
        "`$cmd`" \
        "Exit status: $status_code" \
        "Pipe status: $pipestatus_text" \
        '' \
        '终端摘录：' \
        '```text' \
        "$redacted" \
        '```' \
        | string collect)

    set -l show_status_line false
    if status --is-interactive
        set show_status_line true
        printf '\n⌛ Diagnosing...\n' >&2
    end

    set -l result (_ai_complete --prompt "$prompt" --input "$cmd" | string collect)
    set -l ai_exit_status $pipestatus[1]
    set result (_ai_strip_think "$result" | string collect)

    if test "$show_status_line" = true
        printf '\033[1A\033[2K\r' >&2
    end

    if test $ai_exit_status -ne 0
        return 1
    end

    if status --is-interactive; and command -sq bat
        if test -n "$result"
            printf '%s\n' "$result" | bat -l markdown -p --paging=always
        end
        return 0
    end

    printf '%s\n' "$result"
end
