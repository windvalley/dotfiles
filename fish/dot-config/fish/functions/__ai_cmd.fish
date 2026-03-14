function __ai_cmd -d "使用当前可用 AI 后端生成单条可执行命令"
    if test (count $argv) -eq 0
        echo "用法: ? <自然语言描述>" >&2
        return 1
    end

    set -l input_text (string join " " -- $argv | string trim)
    if test -z "$input_text"
        echo "❌ 请输入要转换为命令的自然语言描述" >&2
        return 1
    end

    set -l candidates (_aichat_fish_candidates "$input_text")
    if test $status -ne 0; or test (count $candidates) -eq 0
        echo "❌ 未生成可执行命令，请检查本地模型、AI_CHAT_BACKENDS 或 aichat 配置" >&2
        return 1
    end

    echo "$candidates[1]"
end
