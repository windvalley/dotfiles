function s -d "使用 fzf 从 ~/.ssh/config 中选择 Host 并建立 SSH 连接"
    set -l ssh_config "$HOME/.ssh/config"

    if not test -f "$ssh_config"
        echo "⚠️ 未找到 SSH 配置文件: $ssh_config" >&2
        return 1
    end

    if not type -q fzf
        echo "⚠️ 未安装 fzf，无法提供交互式选择" >&2
        return 1
    end

    set -l hosts
    set -l entries
    set -l current_hosts
    set -l current_user "-"
    set -l current_hostname "-"

    # 单次遍历 ~/.ssh/config，同时提取 Host/User/HostName
    while read -l line
        set line (string trim -- "$line")

        if test -z "$line"; or string match -qr '^#' -- "$line"
            continue
        end

        # 遇到新 Host 块：先将上一个块的数据写入 entries
        if string match -qri '^Host\s+' -- "$line"
            for h in $current_hosts
                set -a entries "$h [$current_user@$current_hostname]"
            end

            set current_hosts
            set current_user "-"
            set current_hostname "-"

            set -l host_value (string replace -ri '^Host\s+' '' -- "$line")
            for h in (string match -ar '\S+' -- $host_value)
                if string match -qr '[*?]' -- "$h"
                    continue
                end
                if not contains -- "$h" $hosts
                    set -a hosts "$h"
                    set -a current_hosts "$h"
                end
            end
            continue
        end

        if string match -qri '^User\s+' -- "$line"
            set current_user (string replace -ri '^User\s+' '' -- "$line")
            continue
        end

        if string match -qri '^HostName\s+' -- "$line"
            set current_hostname (string replace -ri '^HostName\s+' '' -- "$line")
            continue
        end
    end < "$ssh_config"

    # flush 最后一个 Host 块
    for h in $current_hosts
        set -a entries "$h [$current_user@$current_hostname]"
    end

    if test (count $hosts) -eq 0
        echo "⚠️ ~/.ssh/config 中没有找到可用的 Host 别名" >&2
        return 1
    end

    set -l fzf_query ""
    if test -n "$argv"
        set fzf_query "'$argv"
    end

    set -l selected (printf '%s\n' $entries | sort | fzf \
        --query="$fzf_query" \
        --prompt="🔐 SSH Host > " \
        --height=80% \
        --layout=reverse \
        --border \
        --preview="echo {} | awk -F '[][@ ]+' '{printf \"Host: %s\\nUser: %s\\nHostname: %s\\n\", \$1, \$2, \$3}'")

    if test -z "$selected"
        return 0
    end

    set -l selected_host (string split -m 1 ' ' -- $selected)[1]

    echo "🔗 正在连接: $selected_host"
    command ssh "$selected_host"
end
