if status is-interactive
    function __ai_capture_last_cmd --on-event fish_postexec
        # $status can be overwritten by commands we run in this handler.
        # Capture it immediately.
        set -l last_status $status
        set -l last_pipestatus $pipestatus

        # fish_postexec passes the executed commandline as argv.
        set -l cmdline (string join " " -- $argv)
        set -l cmdline (string trim -- "$cmdline")

        if test -z "$cmdline"
            return
        end

        # Avoid self-noise in captured context.
        if string match -qr '^(\?\?|ai_diag_last|_aichat_fish)\b' -- "$cmdline"
            return
        end

        set -g __AI_LAST_CMDLINE "$cmdline"
        set -g __AI_LAST_STATUS $last_status
        set -g __AI_LAST_PIPESTATUS $last_pipestatus
        set -g __AI_LAST_AT (date +%s)

        # Capture pane output when a command fails (best-effort, requires Zellij).
        set -l is_failure false
        for s in $last_pipestatus
            if test $s -ne 0
                set is_failure true
                break
            end
        end

        if test "$is_failure" = true
            if set -q ZELLIJ; and command -sq zellij
                set -l cache_root "$HOME/.cache"
                if set -q XDG_CACHE_HOME
                    set cache_root "$XDG_CACHE_HOME"
                end

                set -l dir "$cache_root/dotfiles/ai"
                mkdir -p "$dir" 2>/dev/null

                set -l file "$dir/last_failure_screen.txt"
                zellij action dump-screen --full "$file" >/dev/null 2>&1
                set -g __AI_LAST_SCREEN_FILE "$file"
            end
        end
    end
end
