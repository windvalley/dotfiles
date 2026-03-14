function _ai_local_think -d "解析 q/Ollama thinking 开关"
    if set -q AI_LOCAL_THINK
        set -l configured_think (string lower -- (string trim -- "$AI_LOCAL_THINK"))
        if test -n "$configured_think"
            echo "$configured_think"
            return 0
        end
    end

    if set -q Q_THINK
        set -l configured_think (string lower -- (string trim -- "$Q_THINK"))
        if test -n "$configured_think"
            echo "$configured_think"
            return 0
        end
    end

    echo "false"
end
