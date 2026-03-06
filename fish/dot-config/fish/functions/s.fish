function __s_flush_current_host -d "将当前 Host 块写入候选列表"
    for h in $__s_current_hosts
        set -a __s_entries "$h [$__s_current_user@$__s_current_hostname]"
    end
end

function __s_parse_ssh_config -a config_file -d "递归解析 SSH 配置（含 Include）"
    if not test -f "$config_file"
        return 0
    end

    if contains -- "$config_file" $__s_seen_config_files
        return 0
    end

    set -ga __s_seen_config_files "$config_file"
    set -l config_dir (path dirname "$config_file")

    while read -l raw_line
        set -l line (string trim -- "$raw_line")

        if test -z "$line"; or string match -qr '^#' -- "$line"
            continue
        end

        if string match -qri '^Include\s+' -- "$line"
            # 兼容常见的 Include 单文件写法（例如 Include ~/.orbstack/ssh/config），
            # 让 s 命令能把 OrbStack 自动生成的 SSH 主机也一起列出来。
            set -l include_value (string replace -ri '^Include\s+' '' -- "$line")
            for include_path in (string split ' ' -- $include_value)
                set include_path (string trim -- "$include_path")

                if test -z "$include_path"
                    continue
                end

                set include_path (string replace -r '^~' "$HOME" -- "$include_path")

                if not string match -qr '^/' -- "$include_path"
                    set include_path "$config_dir/$include_path"
                end

                if test -f "$include_path"
                    __s_parse_ssh_config "$include_path"
                end
            end
            continue
        end

        # 遇到新 Host 块：先将上一个块的数据写入 entries，
        # 这样 Include 的解析顺序就与 OpenSSH 实际读取顺序保持一致。
        if string match -qri '^Host\s+' -- "$line"
            __s_flush_current_host

            set -g __s_current_hosts
            set -g __s_current_user "-"
            set -g __s_current_hostname "-"

            set -l host_value (string replace -ri '^Host\s+' '' -- "$line")
            for h in (string match -ar '\S+' -- $host_value)
                if string match -qr '[*?]' -- "$h"
                    continue
                end
                if not contains -- "$h" $__s_hosts
                    set -a __s_hosts "$h"
                    set -a __s_current_hosts "$h"
                end
            end
            continue
        end

        if string match -qri '^User\s+' -- "$line"
            set -g __s_current_user (string replace -ri '^User\s+' '' -- "$line")
            continue
        end

        if string match -qri '^HostName\s+' -- "$line"
            set -g __s_current_hostname (string replace -ri '^HostName\s+' '' -- "$line")
            continue
        end
    end < "$config_file"
end

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

    set -g __s_seen_config_files
    set -g __s_hosts
    set -g __s_entries
    set -g __s_current_hosts
    set -g __s_current_user "-"
    set -g __s_current_hostname "-"

    __s_parse_ssh_config "$ssh_config"
    __s_flush_current_host

    set -l hosts $__s_hosts
    set -l entries $__s_entries

    set -e __s_seen_config_files
    set -e __s_hosts
    set -e __s_entries
    set -e __s_current_hosts
    set -e __s_current_user
    set -e __s_current_hostname

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
    TERM=xterm-256color command ssh "$selected_host"
end
