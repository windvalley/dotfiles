function _ai_backend_list -d "解析 AI 后端优先级配置"
    set -l raw_order "q,aichat"
    if set -q AI_CHAT_BACKENDS
        set -l configured (string trim -- "$AI_CHAT_BACKENDS")
        if test -n "$configured"
            set raw_order "$configured"
        end
    end

    set raw_order (string replace -ar '[,\t\r\n]+' ' ' -- "$raw_order")
    set raw_order (string replace -ar '\s+' ' ' -- "$raw_order")
    set raw_order (string trim -- "$raw_order")

    set -l ordered
    for backend in (string split ' ' -- "$raw_order")
        set backend (string lower -- (string trim -- "$backend"))
        switch "$backend"
            case q aichat
                if not contains -- "$backend" $ordered
                    set -a ordered "$backend"
                end
        end
    end

    if test (count $ordered) -eq 0
        set ordered q aichat
    end

    printf '%s\n' $ordered
end
