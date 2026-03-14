function _ai_local_model -d "解析 q/Ollama 默认模型"
    if test (count $argv) -gt 0
        set -l explicit_model (string trim -- "$argv[1]")
        if test -n "$explicit_model"
            echo "$explicit_model"
            return 0
        end
    end

    if set -q AI_LOCAL_MODEL
        set -l configured_model (string trim -- "$AI_LOCAL_MODEL")
        if test -n "$configured_model"
            echo "$configured_model"
            return 0
        end
    end

    if set -q Q_MODEL
        set -l configured_model (string trim -- "$Q_MODEL")
        if test -n "$configured_model"
            echo "$configured_model"
            return 0
        end
    end

    return 1
end
