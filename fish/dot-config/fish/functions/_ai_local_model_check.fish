function _ai_local_model_check -d "校验 Ollama 本地模型是否可用，并返回可读错误"
    if test (count $argv) -lt 1
        echo "_ai_local_model_check 缺少模型名称"
        return 2
    end

    set -l model (string trim -- "$argv[1]")
    if test -z "$model"
        echo "未提供本地模型名称。"
        return 2
    end

    set -l err_file (mktemp)
    command ollama show "$model" >/dev/null 2>"$err_file"
    set -l show_status $status
    set -l err_text ""
    if test -s "$err_file"
        set err_text (cat "$err_file" | string collect)
    end
    rm -f "$err_file"

    if test $show_status -eq 0
        return 0
    end

    set err_text (string replace -ar '\x1b\[[0-9;?]*[ -/]*[@-~]' '' -- "$err_text" | string collect)
    set err_text (string replace -a "\r" '' -- "$err_text" | string collect)
    set err_text (string replace -ar '[\x00-\x08\x0b-\x1f\x7f]' '' -- "$err_text" | string collect)
    set err_text (string trim -- "$err_text")

    set -l err_lower (string lower -- "$err_text")
    if string match -qr 'not found|unknown model|no such model|manifest.*not found|model.*does not exist|pull.*model' -- "$err_lower"
        printf "本地模型 '%s' 不存在。请先执行 ollama list 确认名称，或先运行 ollama pull %s。\n" "$model" "$model"
        return 1
    end

    if test -n "$err_text"
        printf "无法检查本地模型 '%s'：%s\n" "$model" "$err_text"
        return 2
    end

    printf "无法检查本地模型 '%s'。请确认 Ollama 服务已启动且命令可正常执行。\n" "$model"
    return 2
end
