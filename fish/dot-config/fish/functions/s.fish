function __s_flush_current_host -d "Write current host block to candidate list"
    for h in $__s_current_hosts
        set -a __s_entries "$h [$__s_current_user@$__s_current_hostname]"
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

function s -d "Use fzf to select a Host from ~/.ssh/config and connect or manage it"
    set -l ssh_config "$HOME/.ssh/config"

    if test (count $argv) -gt 0
        set -l subcommand $argv[1]
        switch "$subcommand"
            case edit
                hx "$ssh_config"
                return 0
            case config-help
                echo "📖 ~/.ssh/config Configuration Guide"
                echo ""
                echo "Basic Syntax:"
                echo "  Host alias_name"
                echo "      HostName 192.168.1.100"
                echo "      User root"
                echo "      Port 22"
                echo "      IdentityFile ~/.ssh/id_rsa_special"
                echo ""
                echo "Common Options:"
                echo "  - HostName:       The actual IP address or domain name to connect to."
                echo "  - User:           The login username (defaults to your local username)."
                echo "  - Port:           The SSH port (defaults to 22)."
                echo "  - IdentityFile:   The path to the private key for authentication."
                echo "  - ForwardAgent:   Set to 'yes' to forward your local SSH agent."
                echo "  - ProxyJump:      Jump through another host (e.g., 'jump_host')."
                echo "  - ProxyCommand:   Command to use to connect to server (e.g., 'ssh -q jump nc %h %p')."
                echo ""
                echo "Example (ProxyJump):"
                echo "  Host dev-server"
                echo "      HostName dev.example.com"
                echo "      User developer"
                echo "      IdentityFile ~/.ssh/dev_key"
                echo "      ProxyJump jump-server"
                echo ""
                echo "Example (ProxyCommand):"
                echo "  Host acc-target"
                echo "      HostName acc.example.com"
                echo "      User root"
                echo "      ProxyCommand ssh -q acc1 nc %h %p"
                echo ""
                echo "Using Include:"
                echo "  Include ~/.ssh/config.d/*"
                echo "  (The 's' command automatically parses Included files as well)"
                echo ""
                echo "For all available configuration options, please run:"
                echo "  man ssh_config"
                echo ""
                return 0
            case help "--help" "-h"
                echo "Usage: s [subcommand | search_term]"
                echo ""
                echo "Subcommands:"
                echo "  edit          Open ~/.ssh/config with Helix (hx) for editing"
                echo "  ls            List all configured SSH hosts"
                echo "  copy          Copy SSH public key to the selected host using ssh-copy-id"
                echo "  ping          Test connectivity (latency, etc.) to the selected host using ping"
                echo "  config-help   Show a quick guide on how to configure ~/.ssh/config"
                echo "  help          Show this help message"
                echo ""
                echo "Without a subcommand or search term, fzf will open to interactively select a host and establish an SSH connection."
                return 0
        end
    end

    if not test -f "$ssh_config"
        echo "⚠️ SSH config file not found: $ssh_config" >&2
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

    if test (count $argv) -gt 0; and test "$argv[1]" = "ls"
        if test (count $hosts) -eq 0
            echo "⚠️ No usable Host aliases found in ~/.ssh/config" >&2
            return 1
        end
        printf '%s\n' $entries | sort
        return 0
    end

    if not type -q fzf
        echo "⚠️ fzf is not installed, interactive selection is unavailable" >&2
        return 1
    end

    if test (count $hosts) -eq 0
        echo "⚠️ No usable Host aliases found in ~/.ssh/config" >&2
        return 1
    end

    if test (count $argv) -gt 0; and test "$argv[1]" = "copy"
        set -l selected (printf '%s\n' $entries | sort | fzf \
            --prompt="🔑 SSH Copy ID > " \
            --height=80% \
            --layout=reverse \
            --border \
            --preview="echo {} | awk -F '[][@ ]+' '{printf \"Host: %s\\nUser: %s\\nHostname: %s\\n\", \$1, \$2, \$3}'")

        if test -z "$selected"
            return 0
        end

        set -l selected_host (string split -m 1 ' ' -- $selected)[1]
        echo "🔑 Copying public key to: $selected_host"
        command ssh-copy-id "$selected_host"
        return 0
    end

    if test (count $argv) -gt 0; and test "$argv[1]" = "ping"
        set -l selected (printf '%s\n' $entries | sort | fzf \
            --prompt="📡 Ping Host > " \
            --height=80% \
            --layout=reverse \
            --border \
            --preview="echo {} | awk -F '[][@ ]+' '{printf \"Host: %s\\nUser: %s\\nHostname: %s\\n\", \$1, \$2, \$3}'")

        if test -z "$selected"
            return 0
        end

        set -l selected_host (string split -m 1 ' ' -- $selected)[1]
        set -l target_ip (echo "$selected" | awk -F '[][@ ]+' '{print $3}')

        if test "$target_ip" = "-" -o -z "$target_ip"
            set target_ip $selected_host
        end

        echo "📡 Pinging: $selected_host (Target: $target_ip)"
        command ping "$target_ip"
        return 0
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

    echo "🔗 Connecting to: $selected_host"
    TERM=xterm-256color command ssh "$selected_host"
end
