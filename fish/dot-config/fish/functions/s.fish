function __s_flush_current_host -d "Write current host block to candidate list"
    for h in $__s_current_hosts
        set -a __s_entries "$h [$__s_current_user@$__s_current_hostname|$__s_current_proxy]"
    end
end

function __s_parse_ssh_config -a config_file -d "Recursively parse SSH config (including Include)"
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
            # Compat with single-file Includes (e.g. Include ~/.orbstack/ssh/config),
            # enabling s to list dynamically generated hosts like OrbStack's.
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

        # When encountering a new Host block: First flush the previous block's data.
        # This keeps the parsing order of Includes consistent with OpenSSH's actual read order.
        if string match -qri '^Host\s+' -- "$line"
            __s_flush_current_host

            set -g __s_current_hosts
            set -g __s_current_user "-"
            set -g __s_current_hostname "-"
            set -g __s_current_proxy "-"

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

        if string match -qri '^ProxyJump\s+' -- "$line"
            set -g __s_current_proxy (string replace -ri '^ProxyJump\s+' '' -- "$line")
            continue
        end
    end < "$config_file"
end

function __s_print_bootstrap_hint -a ssh_config -d "Print next-step hints when SSH config is missing"
    echo "💡 可以先运行以下命令初始化 SSH 主机配置：" >&2
    echo "   s add   新增可直连主机（推荐，适合新机器首次使用）" >&2
    echo "   s jump  基于已有跳板机新增主机" >&2
    echo "   s edit  手动编辑 $ssh_config" >&2
end

function __s_print_empty_hosts_hint -a subcommand -d "Print next-step hints when no usable hosts are found"
    echo "⚠️ No usable Host aliases found in ~/.ssh/config" >&2

    if test "$subcommand" = "jump"
        echo "💡 当前还没有可用的跳板机，请先运行: s add" >&2
        return 0
    end

    echo "💡 请先运行: s add" >&2
    echo "   或手动执行: s edit" >&2
end

function __s_ensure_ssh_config -a ssh_config -d "Create ~/.ssh/config on first use so s add can bootstrap a new machine"
    set -l ssh_dir (path dirname "$ssh_config")

    if not test -d "$ssh_dir"
        command mkdir -p "$ssh_dir"
        or return 1
        command chmod 700 "$ssh_dir" 2>/dev/null
    end

    if not test -f "$ssh_config"
        command touch "$ssh_config"
        or return 1
        command chmod 600 "$ssh_config" 2>/dev/null
    end
end

function s -d "SSH 主机管理与快速连接 (基于 fzf)"
    set -l ssh_config "$HOME/.ssh/config"
    set -l subcommand ""

    if test (count $argv) -gt 0
        set subcommand $argv[1]
        switch "$subcommand"
            case edit
                hx "$ssh_config"
                return 0

            case help "--help" "-h"
                echo "Usage: s [subcommand | search_term]"
                echo ""
                echo "Subcommands:"
                echo "  add           Add a new SSH host with direct access"
                echo "  jump          Add a new SSH host that requires a JumpHost"
                echo "  edit          Open ~/.ssh/config with Helix (hx) for editing"
                echo "  ls            List all configured SSH hosts"
                echo "  copy          Copy SSH public key to the selected host using ssh-copy-id"
                echo "  ping          Test connectivity (latency, etc.) to the selected host using ping"
                echo "  tunnel        Forward a local port to a remote server port via a JumpHost"
                echo "  help          Show this help message"
                echo ""
                echo "Without a subcommand or search term, fzf will open to interactively select a host and establish an SSH connection."
                return 0
        end
    end

    if not test -f "$ssh_config"
        if test "$subcommand" = "add"
            __s_ensure_ssh_config "$ssh_config"
            or begin
                echo "❌ Failed to initialize SSH config: $ssh_config" >&2
                return 1
            end
        else
            echo "⚠️ SSH config file not found: $ssh_config" >&2
            __s_print_bootstrap_hint "$ssh_config"
            return 1
        end
    end

    set -g __s_seen_config_files
    set -g __s_hosts
    set -g __s_entries
    set -g __s_current_hosts
    set -g __s_current_user "-"
    set -g __s_current_hostname "-"
    set -g __s_current_proxy "-"

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
    set -e __s_current_proxy

    # History integration and candidate sorting
    set -l history_file "$HOME/.local/state/s_history"
    set -l sorted_entries
    set -l history_hosts

    if test -f "$history_file"
        # Sort history entries by count (descending) and take top 20
        set -l sorted_history (cat "$history_file" | sort -nr | head -n 20)
        
        # Matching hosts from ~/.ssh/config that are in history
        for line in $sorted_history
            # Parse "count hostname"
            set -l parts (string split ' ' -- (string trim "$line"))
            set -l h ""
            if test (count $parts) -ge 2
                set h $parts[2]
            else
                set h $parts[1]
            end

            if test -z "$h"; continue; end

            for entry in $entries
                if string match -r "^$h \[.*" "$entry" >/dev/null
                    # Extract count from history line "count hostname"
                    set -l count (string split ' ' -- (string trim "$line"))[1]
                    set -l starred_entry "⭐$count $entry"
                    if not contains -- "$starred_entry" $sorted_entries
                        set -a sorted_entries "$starred_entry"
                        set -a history_hosts "$h" # Keep track of hosts already added from history
                    end
                    break
                end
            end
        end
    end

    for e in (printf '%s\n' $entries | sort)
        set -l h (string split -m 1 ' ' -- "$e")[1]
        if not contains -- "$h" $history_hosts
            set -a sorted_entries "   $e"
        end
    end

    # Helper function to update history inline to avoid global scope pollution
    function __s_update_history -a host -V hosts -V history_file -d "Update connection frequency and cleanup orphaned records"
        if not test -d "$HOME/.local/state"
            command mkdir -p "$HOME/.local/state"
        end
        if test -z "$host"; return; end

        set -l tmp_file (mktemp)
        
        # Increment count for the host or add new entry starting at 1
        # Also filter history to only keep hosts that exist in the current $hosts list
        awk -v host="$host" -v valid_hosts="$hosts" '
            BEGIN {
                if (valid_hosts != "") {
                    split(valid_hosts, vh, " ");
                    for (i in vh) valid[vh[i]] = 1;
                    cleanup = 1
                }
            }
            {
                # Parse host from "count hostname" or "hostname"
                h = ($2 == "" ? $1 : $2)
                
                # Only keep if host exists in current config (if cleanup logic active)
                if (!cleanup || valid[h]) {
                    if (h == host) {
                        # Increment count: handle old format ($2 empty) or new format ($1 is count)
                        count = ($2 == "" ? 2 : $1 + 1)
                        print count, h; found = 1
                    } else if ($2 == "") {
                        # Convert old format to new format (default to 1 visit)
                        print 1, h
                    } else {
                        # Keep existing record
                        print $0
                    }
                }
            }
            END {
                # If host is new and valid, add it with count 1
                if (!found && (!cleanup || valid[host])) {
                    print 1, host
                }
            }
        ' "$history_file" | sort -nr | head -n 20 > "$tmp_file"
        
        mv "$tmp_file" "$history_file"
    end
    # Subcommands that don't need fzf first
    if test (count $argv) -gt 0
        if test "$subcommand" = "ls"
            if test (count $hosts) -eq 0
                __s_print_empty_hosts_hint "$subcommand"
                return 1
            end
            printf '%s\n' $sorted_entries
            return 0
        else if test "$subcommand" = "add"
            echo "🆕 添加新的 SSH 主机配置"
            read -p "set_color green; echo -n '1. 主机别名     (e.g., prod-web): '; set_color normal" -l new_host
            or return 0
            if test -z "$new_host"
                echo "❌ 取消配置"
                return 1
            end
            read -p "set_color green; echo -n '2. 主机IP/域名 (e.g., 10.0.0.5): '; set_color normal" -l new_hostname
            or return 0
            read -p "set_color green; echo -n '3. 登录用户名   (e.g., root): '; set_color normal" -l new_user
            or return 0
            read -p "set_color green; echo -n '4. SSH端口     (留空默认为 22): '; set_color normal" -l new_port
            or return 0

            echo "" >> "$ssh_config"
            echo "Host $new_host" >> "$ssh_config"
            echo "    HostName $new_hostname" >> "$ssh_config"
            if test -n "$new_user"
                echo "    User $new_user" >> "$ssh_config"
            end
            if test -n "$new_port" -a "$new_port" != "22"
                echo "    Port $new_port" >> "$ssh_config"
            end
            echo "✅ 配置已追加至 $ssh_config !"
            return 0
        end
    end

    if not type -q fzf
        echo "⚠️ fzf is not installed, interactive selection is unavailable" >&2
        return 1
    end

    if test (count $hosts) -eq 0
        __s_print_empty_hosts_hint "$subcommand"
        return 1
    end

    # Common fzf parameters for interactive selection
    set -l fzf_opts --height=80% --layout=reverse --border --tiebreak=index --select-1 \
        --preview="set -l host (echo {} | sed -E 's/^[ ⭐0-9]*//' | awk '{print \$1}'); \
                   set -l count (awk -v h=\"\$host\" '\$2 == h {print \$1}' $history_file); \
                   if test -z \"\$count\"; set count 0; end; \
                   echo {} | sed -E 's/^[ ⭐0-9]*//' | awk -v c=\"\$count\" -F '[][@| ]+' '{printf \"Host: %s\\nUser: %s\\nHostname: %s\\nJumpHost: %s\\nVisits: %s\\n\", \$1, \$2, \$3, \$4, c}'"

    set -l fzf_query ""
    if test (count $argv) -gt 0
        set subcommand $argv[1]
        if not contains -- "$subcommand" copy ping tunnel jump add
            # If not a known subcommand, it's a search term for default ssh
            set fzf_query "'$argv"
            set subcommand ""
        else if test (count $argv) -gt 1
            set -l query_args $argv[2..-1]
            set fzf_query "'$query_args"
        end
    end

    if test -n "$fzf_query"
        set -a fzf_opts --query="$fzf_query"
    end

    if test "$subcommand" = "copy"
        set -l selected (printf '%s\n' $sorted_entries | fzf $fzf_opts --prompt="🔑 SSH Copy ID > ")
        if test -z "$selected"; return 0; end
        set -l selected_host (string split -m 1 ' ' -- (string replace -r '^[ ⭐0-9]*' '' -- $selected))[1]
        echo "🔑 Copying public key to: $selected_host"
        command ssh-copy-id "$selected_host"
        if test $status -eq 0
            __s_update_history "$selected_host"
        end
        return 0
    end

    if test "$subcommand" = "ping"
        set -l selected (printf '%s\n' $sorted_entries | fzf $fzf_opts --prompt="📡 Ping Host > ")
        if test -z "$selected"; return 0; end
        set -l clean_selected (string replace -r '^[ ⭐0-9]*' '' -- $selected)
        set -l selected_host (string split -m 1 ' ' -- $clean_selected)[1]
        set -l target_ip (echo "$clean_selected" | awk -F '[][@ ]+' '{print $3}')
        if test "$target_ip" = "-" -o -z "$target_ip"
            set target_ip $selected_host
        end
        echo "📡 Pinging: $selected_host (Target: $target_ip)"
        command ping "$target_ip"
        if test $status -eq 0 -o $status -eq 130
            __s_update_history "$selected_host"
        end
        return 0
    end


    if test "$subcommand" = "tunnel"
        set -l selected (printf '%s\n' $sorted_entries | fzf $fzf_opts --prompt="🔀 选择跳板机 (JumpHost) > ")
        if test -z "$selected"; return 0; end
        set -l selected_host (string split -m 1 ' ' -- (string replace -r '^[ ⭐0-9]*' '' -- $selected))[1]
        
        echo "🔀 正在设置 SSH 本地端口转发 (跳板机: $selected_host)"
        read -p "set_color cyan; echo -n '1. 本地端口   (Local Port, 如 8080): '; set_color normal" -l local_port
        or return 0
        read -p "set_color cyan; echo -n '2. 远端目标IP (留空表示跳板机自身 127.0.0.1): '; set_color normal" -l remote_target
        or return 0
        if test -z "$remote_target"
            set remote_target "127.0.0.1"
        end
        read -p "set_color cyan; echo -n '3. 远端目标端口 (Remote Port, 如 3306): '; set_color normal" -l remote_port
        or return 0
        
        if test -z "$local_port" -o -z "$remote_port"
            echo "❌ 端口信息不完整，操作取消。"
            return 1
        end
        
        echo "🔗 Executing: ssh -N -L $local_port:$remote_target:$remote_port $selected_host"
        command ssh -N -L "$local_port:$remote_target:$remote_port" "$selected_host"
        if test $status -ne 255
            __s_update_history "$selected_host"
        end
        return 0
    end

    if test "$subcommand" = "jump"
        # 第 1 步：通过 fzf 选择已有的跳板机
        set -l selected (printf '%s\n' $sorted_entries | fzf $fzf_opts --prompt="🚀 选择跳板机 (JumpHost) > ")
        if test -z "$selected"; return 0; end
        set -l proxy_jump (string split -m 1 ' ' -- (string replace -r '^[ ⭐0-9]*' '' -- $selected))[1]

        echo "🚀 SSH JumpHost 配置向导 (跳板机: $proxy_jump)"
        read -p "set_color green; echo -n '1. 新主机别名  (e.g., prod-db): '; set_color normal" -l new_host
        or return 0
        if test -z "$new_host"
            echo "❌ 取消配置"
            return 1
        end
        read -p "set_color green; echo -n '2. 新主机IP/域名 (e.g., 10.0.0.5): '; set_color normal" -l new_hostname
        or return 0
        read -p "set_color green; echo -n '3. 登录用户名  (e.g., root): '; set_color normal" -l new_user
        or return 0

        echo "" >> "$ssh_config"
        echo "Host $new_host" >> "$ssh_config"
        echo "    HostName $new_hostname" >> "$ssh_config"
        if test -n "$new_user"
            echo "    User $new_user" >> "$ssh_config"
        end
        echo "    ProxyJump $proxy_jump" >> "$ssh_config"
        echo "✅ 配置已追加至 $ssh_config !"
        return 0
    end
    set -l selected (printf '%s\n' $sorted_entries | fzf $fzf_opts --prompt="🔐 SSH Host > ")
    if test -z "$selected"
        return 0
    end
    set -l selected_host (string split -m 1 ' ' -- (string replace -r '^[ ⭐0-9]*' '' -- $selected))[1]

    echo "🔗 Connecting to: $selected_host"
    TERM=xterm-256color command ssh "$selected_host"
    if test $status -ne 255
        __s_update_history "$selected_host"
    end
end
