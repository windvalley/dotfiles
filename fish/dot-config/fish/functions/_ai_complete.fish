function _ai_complete__format_error -d "将后端 stderr 归一为单行摘要" --argument-names backend raw_error
    set -l err_text (string replace -a "\r" '' -- "$raw_error" | string collect)
    set err_text (string replace -ar '\x1b\[[0-9;?]*[ -/]*[@-~]' '' -- "$err_text" | string collect)
    set err_text (string replace -ar '[\x00-\x08\x0b-\x1f\x7f]' '' -- "$err_text" | string collect)
    set err_text (string trim -- "$err_text" | string collect)

    if test -z "$err_text"
        printf "❌ AI backend '%s' 调用失败。" "$backend"
        return 0
    end

    # 优先抽取 provider 返回的 message 字段，避免把整段内部堆栈直接暴露给终端用户。
    set -l provider_message (string match -rg '"message":"([^"]+)"' -- "$err_text" | string collect)
    if test -n "$provider_message"
        set -l status_code (string match -rg '\(status: ([0-9]+)\)' -- "$err_text" | string collect)
        if test -n "$status_code"
            printf "❌ AI backend '%s' 调用失败：%s (HTTP %s)" "$backend" "$provider_message" "$status_code"
        else
            printf "❌ AI backend '%s' 调用失败：%s" "$backend" "$provider_message"
        end
        return 0
    end

    set -l summary_lines
    for line in (string split \n -- "$err_text")
        set -l trimmed_line (string trim -- "$line")
        if test -z "$trimmed_line"
            continue
        end

        if string match -qr '^Caused by:$' -- "$trimmed_line"
            continue
        end

        set trimmed_line (string replace -r '^Error:\s*' '' -- "$trimmed_line")
        set trimmed_line (string replace -r '^Invalid response data:\s*' '' -- "$trimmed_line")

        if test -n "$trimmed_line"; and not contains -- "$trimmed_line" $summary_lines
            set -a summary_lines "$trimmed_line"
        end
    end

    if test (count $summary_lines) -eq 0
        printf "❌ AI backend '%s' 调用失败。" "$backend"
        return 0
    end

    set -l summary (string join ' | ' -- $summary_lines | string collect)
    if test (string length -- "$summary") -gt 220
        set summary (string sub -s 1 -l 217 -- "$summary")"..."
    end

    printf "❌ AI backend '%s' 调用失败：%s" "$backend" "$summary"
end

function _ai_complete -d "按优先级在 q 与 aichat 之间执行一次 AI 请求"
    set -l raw_text ""
    set -l system_prompt ""
    set -l input_text ""
    set -l args $argv

    while test (count $args) -gt 0
        switch "$args[1]"
            case --raw
                if test (count $args) -lt 2
                    echo "❌ _ai_complete 缺少 --raw 的参数值" >&2
                    return 2
                end
                set raw_text "$args[2]"
                set args $args[3..-1]
            case --prompt --system
                if test (count $args) -lt 2
                    echo "❌ _ai_complete 缺少 --prompt 的参数值" >&2
                    return 2
                end
                set system_prompt "$args[2]"
                set args $args[3..-1]
            case --input --user
                if test (count $args) -lt 2
                    echo "❌ _ai_complete 缺少 --input 的参数值" >&2
                    return 2
                end
                set input_text "$args[2]"
                set args $args[3..-1]
            case '*'
                echo "❌ _ai_complete 不支持的参数: $args[1]" >&2
                return 2
        end
    end

    set -l q_prompt_text ""
    if test -n "$raw_text"
        set q_prompt_text "$raw_text"
    else
        if test -n "$system_prompt"
            set q_prompt_text "$system_prompt"
        end
        if test -n "$input_text"
            if test -n "$q_prompt_text"
                set q_prompt_text (printf '%s\n\nUser input / 用户输入:\n%s\n' "$q_prompt_text" "$input_text" | string collect)
            else
                set q_prompt_text "$input_text"
            end
        end
    end

    if test -z "$q_prompt_text"
        echo "❌ _ai_complete 未收到有效输入" >&2
        return 2
    end

    set -g __AI_LAST_BACKEND ""
    set -l last_error ""

    for backend in (_ai_backend_list)
        switch "$backend"
            case q
                if not command -sq ollama
                    set last_error "❌ AI backend 'q' 不可用：未安装 ollama。"
                    continue
                end

                set -l local_model (_ai_local_model)
                if test $status -ne 0; or test -z "$local_model"
                    set last_error "❌ AI backend 'q' 不可用：未解析到本地模型。请设置 AI_LOCAL_MODEL，或调用 q -m <model>。"
                    continue
                end

                set -l model_check_message (_ai_local_model_check "$local_model" | string collect)
                set -l model_check_status $pipestatus[1]
                if test $model_check_status -ne 0
                    set last_error "❌ AI backend 'q' 不可用：$model_check_message"
                    continue
                end

                set -l think_mode (_ai_local_think)
                set -l err_file (mktemp)
                set -l output_text ""

                if test "$think_mode" = "false"
                    set output_text (command ollama run "$local_model" --think=false --hidethinking "$q_prompt_text" 2>"$err_file" | string collect)
                else
                    set output_text (command ollama run "$local_model" --think="$think_mode" "$q_prompt_text" 2>"$err_file" | string collect)
                end

                set -l cmd_status $pipestatus[1]
                set -l err_text ""
                if test -s "$err_file"
                    set err_text (cat "$err_file" | string collect)
                end
                rm -f "$err_file"

                # Ollama CLI 在非 TTY 场景下仍可能输出控制序列，这里统一清理。
                set output_text (string replace -ar '\x1b\[[0-9;?]*[ -/]*[@-~]' '' -- "$output_text" | string collect)
                set output_text (string replace -a "\r" '' -- "$output_text" | string collect)
                set output_text (string replace -ar '[\x00-\x08\x0b-\x1f\x7f]' '' -- "$output_text" | string collect)

                set -l trimmed_output (string trim -- "$output_text")
                if test $cmd_status -eq 0; and test -n "$trimmed_output"
                    set -g __AI_LAST_BACKEND q
                    printf '%s\n' "$output_text"
                    return 0
                end

                if test -n "$err_text"
                    set last_error (_ai_complete__format_error q "$err_text" | string collect)
                else
                    set last_error "❌ AI backend 'q' 调用失败。"
                end

            case aichat
                if not command -sq aichat
                    set last_error "❌ AI backend 'aichat' 不可用：未安装 aichat。"
                    continue
                end

                set -l err_file (mktemp)
                set -l output_text ""

                if test -n "$raw_text"
                    set output_text (aichat --no-stream -- "$raw_text" 2>"$err_file" | string collect)
                else if test -n "$system_prompt"; and test -n "$input_text"
                    set output_text (aichat --no-stream --prompt "$system_prompt" -- "$input_text" 2>"$err_file" | string collect)
                else if test -n "$system_prompt"
                    set output_text (aichat --no-stream -- "$system_prompt" 2>"$err_file" | string collect)
                else
                    set output_text (aichat --no-stream -- "$input_text" 2>"$err_file" | string collect)
                end

                set -l cmd_status $pipestatus[1]
                set -l err_text ""
                if test -s "$err_file"
                    set err_text (cat "$err_file" | string collect)
                end
                rm -f "$err_file"

                set -l trimmed_output (string trim -- "$output_text")
                if test $cmd_status -eq 0; and test -n "$trimmed_output"
                    set -g __AI_LAST_BACKEND aichat
                    printf '%s\n' "$output_text"
                    return 0
                end

                if test -n "$err_text"
                    set last_error (_ai_complete__format_error aichat "$err_text" | string collect)
                else
                    set last_error "❌ AI backend 'aichat' 调用失败。"
                end
        end
    end

    if test -n "$last_error"
        printf '%s\n' "$last_error" >&2
    else
        echo "❌ 没有可用的 AI 后端。请检查 AI_CHAT_BACKENDS / AI_LOCAL_MODEL / AICHAT_MODEL 配置。" >&2
    end
    return 1
end
