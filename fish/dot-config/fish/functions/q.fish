function q -d "基于本地模型的专用 AI 工具"
    set -l model ""
    set -l think_mode ""
    set -l list_models false
    set -l prompt_parts
    set -l args $argv

    while test (count $args) -gt 0
        switch "$args[1]"
            case -h --help
                echo "q - 基于本地模型的专用 AI 工具"
                echo ""
                echo "用法:"
                echo "  q"
                echo "      使用默认本地模型进入交互会话"
                echo ""
                echo "  q <提示词>"
                echo "      使用默认本地模型发起一次单轮请求"
                echo ""
                echo "  q -m <模型> <提示词>"
                echo "      临时指定模型执行一次请求"
                echo ""
                echo "  q --think <false|true|low|medium|high> <提示词>"
                echo "      临时覆盖 thinking 模式"
                echo ""
                echo "  q --list-models"
                echo "      查看当前已安装的 Ollama 模型"
                echo ""
                echo "环境变量:"
                echo "  AI_CHAT_BACKENDS"
                echo "      共享 AI 工作流的后端优先级，例如 q,aichat"
                echo ""
                echo "  AI_LOCAL_MODEL"
                echo "      q 和本地优先工作流默认使用的 Ollama 模型"
                echo ""
                echo "  AI_LOCAL_THINK"
                echo "      q 的默认 thinking 模式；未设置时默认为 false"
                return 0
            case --list-models
                set list_models true
                set args $args[2..-1]
            case -m --model
                if test (count $args) -lt 2
                    echo "❌ q 缺少模型名称，请使用 q -m <model>" >&2
                    return 2
                end
                set model "$args[2]"
                set args $args[3..-1]
            case --think
                if test (count $args) -lt 2
                    echo "❌ q 缺少 thinking 参数，请使用 --think <false|true|low|medium|high>" >&2
                    return 2
                end
                set think_mode (string lower -- (string trim -- "$args[2]"))
                set args $args[3..-1]
            case '*'
                set prompt_parts $args
                break
        end
    end

    if not command -sq ollama
        echo "❌ 未找到 ollama，请先安装并启动服务" >&2
        return 127
    end

    if test "$list_models" = true
        command ollama list
        return $status
    end

    if test -z "$model"
        set model (_ai_local_model)
    end
    if test -z "$model"
        echo "❌ 未解析到本地模型。请设置 AI_LOCAL_MODEL，或执行 q -m <model>" >&2
        return 1
    end

    set -l model_check_message (_ai_local_model_check "$model" | string collect)
    set -l model_check_status $pipestatus[1]
    if test $model_check_status -ne 0
        printf '❌ %s\n' "$model_check_message" >&2
        return $model_check_status
    end

    if test -z "$think_mode"
        set think_mode (_ai_local_think)
    end

    set -l cmd_args run "$model"
    if test "$think_mode" = "false"
        set cmd_args $cmd_args --think=false --hidethinking
    else
        set cmd_args $cmd_args --think="$think_mode"
    end

    if test (count $prompt_parts) -eq 0
        command ollama $cmd_args
        return $status
    end

    set -l prompt_text (string join " " -- $prompt_parts)
    if isatty stdout
        command ollama $cmd_args "$prompt_text"
        return $status
    end

    set -l err_file (mktemp)
    set -l output_text (command ollama $cmd_args "$prompt_text" 2>"$err_file" | string collect)
    set -l cmd_status $pipestatus[1]
    set -l err_text ""
    if test -s "$err_file"
        set err_text (cat "$err_file" | string collect)
    end
    rm -f "$err_file"

    set output_text (string replace -ar '\x1b\[[0-9;?]*[ -/]*[@-~]' '' -- "$output_text" | string collect)
    set output_text (string replace -a "\r" '' -- "$output_text" | string collect)
    set output_text (string replace -ar '[\x00-\x08\x0b-\x1f\x7f]' '' -- "$output_text" | string collect)

    if test $cmd_status -ne 0
        if test -n "$err_text"
            printf '%s\n' "$err_text" >&2
        end
        return $cmd_status
    end

    printf '%s\n' "$output_text"
end
