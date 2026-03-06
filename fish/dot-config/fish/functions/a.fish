function a -d "列出所有配置的缩写 (Abbreviations) 及其功能描述"
    echo "📋 Dotfiles 缩写 (Abbreviations) 一览："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  %-12s %-26s %s\n" "缩写" "展开为" "说明"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    set -l config_file ~/.config/fish/config.fish
    set -l desc_keys
    set -l desc_values

    # 从 config.fish 中提取注释说明，避免和运行态 abbr 定义耦合
    if test -f $config_file
        set -l pending_desc ""
        while read -l line
            if string match -qr '^\s*#' -- $line
                set pending_desc (string replace -r '^\s*#\s*' '' -- $line)
                continue
            end

            if string match -qr '^\s*$' -- $line
                set pending_desc ""
                continue
            end

            set -l tokens (string split -m 1 "#" -- $line)
            set -l cmd_part (string trim -- $tokens[1])
            set -l desc "—"

            if test (count $tokens) -gt 1
                set desc (string trim -- $tokens[2])
            else if test -n "$pending_desc"
                set desc "$pending_desc"
            end

            if not string match -qr '^\s*abbr\s+-a\s+-g\s+' -- $cmd_part
                continue
            end

            if test "$desc" = "—"
                continue
            end

            set -l spec (string replace -r '^\s*abbr\s+-a\s+-g\s+' '' -- $cmd_part)
            set spec (string replace -r '^--\s+' '' -- $spec)
            set spec (string trim -- $spec)

            set -l abbr_name
            if string match -qr "^'[^']+'\\s+" -- $spec
                set abbr_name (string replace -r "^'([^']+)'\\s+.*" '$1' -- $spec)
            else if string match -qr '^"[^"]+"\s+' -- $spec
                set abbr_name (string replace -r '^"([^"]+)"\s+.*' '$1' -- $spec)
            else if string match -qr '^\S+\s+' -- $spec
                set abbr_name (string replace -r '^(\S+)\s+.*' '$1' -- $spec)
            else
                continue
            end

            set -a desc_keys "$abbr_name"
            set -a desc_values "$desc"
            set pending_desc ""
        end < $config_file
    end

    # 读取 Fish 当前真实已加载的缩写定义，保证输出与运行态一致
    abbr --show | while read -l line
        if not string match -qr '^\s*abbr\s+-a\s+--\s+' -- $line
            continue
        end

        set -l spec (string replace -r '^\s*abbr\s+-a\s+--\s+' '' -- $line)
        set -l abbr_name
        set -l abbr_cmd

        if string match -qr "^'[^']+'\\s+" -- $spec
            set abbr_name (string replace -r "^'([^']+)'\\s+.*" '$1' -- $spec)
            set abbr_cmd (string replace -r "^'[^']+'\\s+(.*)\$" '$1' -- $spec)
        else if string match -qr '^"[^"]+"\s+' -- $spec
            set abbr_name (string replace -r '^"([^"]+)"\s+.*' '$1' -- $spec)
            set abbr_cmd (string replace -r '^"[^"]+"\s+(.*)$' '$1' -- $spec)
        else if string match -qr '^\S+\s+' -- $spec
            set abbr_name (string replace -r '^(\S+)\s+.*' '$1' -- $spec)
            set abbr_cmd (string replace -r '^\S+\s+(.*)$' '$1' -- $spec)
        else
            continue
        end

        set abbr_cmd (string trim -- $abbr_cmd)
        if string match -qr "^'[^']*'\$" -- $abbr_cmd
            set abbr_cmd (string replace -r "^'(.*)'\$" '$1' -- $abbr_cmd)
        else if string match -qr '^"[^"]*"$' -- $abbr_cmd
            set abbr_cmd (string replace -r '^"(.*)"$' '$1' -- $abbr_cmd)
        end

        set -l abbr_desc "—"
        set -l idx 1
        while test $idx -le (count $desc_keys)
            if test "$desc_keys[$idx]" = "$abbr_name"
                set abbr_desc "$desc_values[$idx]"
                break
            end
            set idx (math $idx + 1)
        end

        printf "  %-12s %-26s %s\n" "$abbr_name" "$abbr_cmd" "$abbr_desc"
    end

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 提示: 输入缩写后敲击空格即可自动展开为完整命令"
end
