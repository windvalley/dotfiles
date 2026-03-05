function _aichat_fish_candidates -d "Generate candidate shell commands for _aichat_fish"
    if not command -sq aichat
        return 127
    end

    set -l input ""
    if test (count $argv) -gt 0
        set input (string join " " -- $argv)
    else if set -q __AICHAT_FISH_INPUT
        set input "$__AICHAT_FISH_INPUT"
    end

    set input (string trim -- "$input")
    if test -z "$input"
        return 0
    end

    # Environment hint for the model: macOS uses BSD userland and options differ from GNU.
    set -l detected_os (uname -s)
    if set -q __AICHAT_FISH_OS
        set detected_os "$__AICHAT_FISH_OS"
    end

    set -l shell_name fish
    if set -q __AICHAT_FISH_SHELL
        set shell_name "$__AICHAT_FISH_SHELL"
    end

    set -l platform_desc "$detected_os"
    if test "$detected_os" = Darwin
        set platform_desc "macOS (Darwin, BSD userland)"
    end

    function _aichat_fish__sanitize
        set -l s (string join " " -- $argv)
        set s (string trim -- "$s")

        # Strip common prompts
        set s (string replace -r '^\$\s+' '' -- "$s")
        set s (string replace -r '^❯\s+' '' -- "$s")

        # Normalize smart quotes
        set s (string replace -a '“' '"' -- "$s")
        set s (string replace -a '”' '"' -- "$s")
        set s (string replace -a '’' "'" -- "$s")
        set s (string replace -a '‘' "'" -- "$s")

        # Collapse internal newlines/spaces
        set s (string replace -a "\r" " " -- "$s")
        set s (string replace -a "\n" " " -- "$s")
        set s (string replace -r '\\s+' ' ' -- "$s")
        set s (string trim -- "$s")

        # Darwin/BSD rewrites for common GNU variants
        set -l os (uname -s)
        if set -q __AICHAT_FISH_OS
            set os "$__AICHAT_FISH_OS"
        end
        if test "$os" = Darwin
            # GNU ps sort -> BSD ps sort
            set s (string replace -r '^ps\s+aux\s+--sort=-%cpu' 'ps aux -r' -- "$s")
            set s (string replace -r '^ps\s+aux\s+--sort=-pcpu' 'ps aux -r' -- "$s")
        end

        echo "$s"
    end

    function _aichat_fish__is_obviously_bash
        set -l s (string join " " -- $argv)
        if string match -qr '\$\(|\bexport\b|\bsource\b|\[\[|\bfunction\b\s+\w+\s*\(|\{\s*\w+\s*=|\bdeclare\b|\btypeset\b|\bset\s+-e\b' -- "$s"
            return 0
        end
        return 1
    end

    function _aichat_fish__is_fish_parse_ok
        set -l s (string join " " -- $argv)
        fish -n -c "$s" >/dev/null 2>&1
    end

    function _aichat_fish__score
        set -l req "$argv[1]"
        set -l cmd "$argv[2]"

        set req (string lower -- "$req")
        set cmd (string lower -- "$cmd")

        set -l score 0

        # Prefer safer commands unless user explicitly asks for destructive actions
        if string match -qr '\brm\b|\bmkfs\b|\bdd\b' -- "$cmd"
            if not string match -qr '删|删除|清理|移除|wipe|remove|delete' -- "$req"
                set score (math $score - 15)
            end
        end

        if string match -qr '\bsudo\b' -- "$cmd"
            if not string match -qr 'sudo|管理员|权限|root' -- "$req"
                set score (math $score - 8)
            end
        end

        # ASCII token overlap (best-effort)
        for tok in (string match -ar '[a-z0-9_-]{2,}' -- "$req")
            if string match -q "*$tok*" -- "$cmd"
                set score (math $score + 4)
            end
        end

        # A few high-signal heuristics for common intents
        if string match -qr '树|tree|目录树|文件树' -- "$req"
            if string match -qr '\btree\b' -- "$cmd"
                set score (math $score + 20)
            end
            if string match -qr '(?:--tree)|\btree\b' -- "$cmd"
                set score (math $score + 10)
            end
        end

        if string match -qr '隐藏|hidden|all files' -- "$req"
            if string match -qr '\s-a\b|--all\b' -- "$cmd"
                set score (math $score + 12)
            end
        end

        if string match -qr 'cpu|进程|process|top' -- "$req"
            if string match -qr '\bps\b|\btop\b|\bhtop\b|\bpidstat\b' -- "$cmd"
                set score (math $score + 10)
            end
            if string match -qr 'cpu|pcpu|%cpu' -- "$cmd"
                set score (math $score + 6)
            end
        end

        if string match -qr '端口|port|listen|监听' -- "$req"
            if string match -qr '\blsof\b|\bnetstat\b|\bss\b' -- "$cmd"
                set score (math $score + 10)
            end
        end

        if string match -qr '搜索|search|find|grep' -- "$req"
            if string match -qr '\brg\b|\bgrep\b|\bfind\b' -- "$cmd"
                set score (math $score + 10)
            end
        end

        echo $score
    end

    function _aichat_fish__is_platform_incompatible
        set -l s (string join " " -- $argv)
        set -l os (uname -s)
        if set -q __AICHAT_FISH_OS
            set os "$__AICHAT_FISH_OS"
        end

        if test "$os" != Darwin
            return 1
        end

        # macOS/BSD 不兼容的常见 GNU 参数/工具行为
        if string match -qr '^ps\b.*\s--sort(=|\s)' -- "$s"
            return 0
        end
        if string match -qr '\bgrep\s+-P\b' -- "$s"
            return 0
        end
        if string match -qr '\bxargs\s+-r\b' -- "$s"
            return 0
        end
        if string match -qr '^date\b.*\s-d\b' -- "$s"
            return 0
        end
        if string match -qr '\breadlink\s+-f\b' -- "$s"
            return 0
        end

        # Linux top flags that frequently appear in model outputs
        if string match -qr '^top\b.*\s-b\b' -- "$s"
            return 0
        end
        if string match -qr '^top\b.*%CPU' -- "$s"
            return 0
        end

        return 1
    end

    set -l env "Environment:\n- OS: $platform_desc\n- Shell: $shell_name\n\n"
    set -l rules 'You output ONLY shell command candidates compatible with fish shell.
Constraints:
- If OS is macOS (Darwin), prefer BSD options (avoid GNU-only long options).
- Avoid bash-only syntax: export VAR=, source, $(...), [[ ]], function f(){}, process substitution.
Given a user request, output exactly 5 candidates.
Order:
- Sort candidates by relevance (most relevant first).
Format rules:
- Each candidate MUST start with: CMD:
- One candidate per line
- No numbering, no bullets, no explanations, no code fences'
    set -l base_prompt "$env$rules"

    set -l raw (aichat --no-stream --prompt "$base_prompt" -- "$input")

    # Robust split: even if the model prints everything on one line,
    # insert a newline before each "CMD:" occurrence.
    set raw (string replace -a 'CMD:' '\nCMD:' -- "$raw")

    set -l extracted
    for line in (string split "\n" -- "$raw")
        set -l s (string trim -- "$line")
        if test -z "$s"
            continue
        end

        if not string match -q 'CMD:*' -- "$s"
            continue
        end

        set s (string replace -r '^CMD:\s*' '' -- "$s")
        set s (_aichat_fish__sanitize "$s")
        if test -z "$s"
            continue
        end

        if not contains -- "$s" $extracted
            set -a extracted "$s"
        end
    end

    # Validate and keep only fish-parseable candidates
    set -l out
    set -l errors
    for cmd in $extracted
        if _aichat_fish__is_platform_incompatible "$cmd"
            set -a errors "DARWIN: $cmd"
            continue
        end

        if _aichat_fish__is_obviously_bash "$cmd"
            set -a errors "BASH: $cmd"
            continue
        end

        if _aichat_fish__is_fish_parse_ok "$cmd"
            set -a out "$cmd"
        else
            set -a errors "PARSE: $cmd"
        end
    end

    # Second attempt: ask model to fix syntax based on failures
    if test (count $out) -eq 0; and test (count $errors) -gt 0
        set -l errors_text (string join "\n" -- $errors)
        set -l fix_prompt "You fix shell commands to be valid in fish shell and compatible with macOS/BSD when OS is macOS (Darwin).\nReturn exactly 5 candidates, format: CMD:<command> per line.\nInput request: $input\nEnvironment: OS=$platform_desc, Shell=$shell_name\nPreviously invalid candidates (do not repeat as-is):\n$errors_text"
        set raw (aichat --no-stream --prompt "$fix_prompt" -- "$input")
        set raw (string replace -a 'CMD:' '\nCMD:' -- "$raw")

        set -l extracted2
        for line in (string split "\n" -- "$raw")
            set -l s (string trim -- "$line")
            if test -z "$s"
                continue
            end
            if not string match -q 'CMD:*' -- "$s"
                continue
            end
            set s (string replace -r '^CMD:\s*' '' -- "$s")
            set s (_aichat_fish__sanitize "$s")
            if test -z "$s"
                continue
            end
            if not contains -- "$s" $extracted2
                set -a extracted2 "$s"
            end
        end

        for cmd in $extracted2
            if _aichat_fish__is_platform_incompatible "$cmd"
                continue
            end
            if _aichat_fish__is_obviously_bash "$cmd"
                continue
            end
            if _aichat_fish__is_fish_parse_ok "$cmd"
                set -a out "$cmd"
            end
        end
    end

    if test (count $out) -gt 0
        # Local relevance re-order (best-effort) while keeping only valid candidates.
        set -l scored
        for cmd in $out
            set -l s (_aichat_fish__score "$input" "$cmd")
            set -a scored "$s\t$cmd"
        end

        set -l sorted_lines (printf '%s\n' $scored | command sort -nr -k1,1)
        set -l out_sorted
        for line in $sorted_lines
            set -l parts (string split -m1 -- "\t" "$line")
            if test (count $parts) -ge 2
                set -a out_sorted "$parts[2]"
            end
        end

        if test (count $out_sorted) -gt 0
            set out $out_sorted
        end

        printf '%s\n' $out
        return 0
    end

    # Final fallback: ask aichat for a single executable command
    set -l generated (aichat --no-stream -e -- "$input")
    set generated (_aichat_fish__sanitize "$generated")
    if test -n "$generated"; and _aichat_fish__is_fish_parse_ok "$generated"
        echo "$generated"
        return 0
    end

    return 1
end
