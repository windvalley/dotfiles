function a -d "列出所有配置的缩写 (Abbreviations) 及其功能描述"
    set -l output_lines
    set -l ansi_lines

    set -l config_file ~/.config/fish/config.fish
    set -l desc_keys
    set -l desc_values

    set -l color_title ""
    set -l color_header ""
    set -l color_key ""
    set -l color_cmd ""
    set -l color_desc ""
    set -l color_note ""
    set -l color_divider ""
    set -l color_reset ""

    if isatty stdout
        set color_title (set_color --bold brcyan)
        set color_header (set_color --bold bryellow)
        set color_key (set_color brgreen)
        set color_cmd (set_color white)
        set color_desc (set_color brmagenta)
        set color_note (set_color cyan)
        set color_divider (set_color brblack)
        set color_reset (set_color normal)
    end

    set -l divider "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    set -l header_line (printf "  %-12s %-26s %s" "缩写" "展开为" "说明")

    set -a output_lines "📋 Dotfiles 缩写 (Abbreviations) 一览："
    set -a output_lines "$divider"
    set -a output_lines "$header_line"
    set -a output_lines "$divider"

    set -a ansi_lines (printf "%s%s%s" "$color_title" "📋 Dotfiles 缩写 (Abbreviations) 一览：" "$color_reset")
    set -a ansi_lines (printf "%s%s%s" "$color_divider" "$divider" "$color_reset")
    set -a ansi_lines (printf "  %s%-12s%s %s%-26s%s %s%s%s" "$color_header" "缩写" "$color_reset" "$color_header" "展开为" "$color_reset" "$color_header" "说明" "$color_reset")
    set -a ansi_lines (printf "%s%s%s" "$color_divider" "$divider" "$color_reset")

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
    for line in (abbr --show)
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

        set -a output_lines (printf "  %-12s %-26s %s" "$abbr_name" "$abbr_cmd" "$abbr_desc")

        set -l abbr_name_pad (printf "%-12s" "$abbr_name")
        set -l abbr_cmd_pad (printf "%-26s" "$abbr_cmd")
        set -a ansi_lines (printf "  %s%s%s %s%s%s %s%s%s" "$color_key" "$abbr_name_pad" "$color_reset" "$color_cmd" "$abbr_cmd_pad" "$color_reset" "$color_desc" "$abbr_desc" "$color_reset")
    end

    set -l tip_line "💡 提示: 输入缩写后敲击空格即可自动展开为完整命令"
    set -a output_lines "$divider"
    set -a output_lines "$tip_line"

    set -a ansi_lines (printf "%s%s%s" "$color_divider" "$divider" "$color_reset")
    set -a ansi_lines (printf "%s%s%s" "$color_note" "$tip_line" "$color_reset")

    if status --is-interactive; and command -sq less
        printf '%s\n' $ansi_lines | less -R
    else if isatty stdout
        printf '%s\n' $ansi_lines
    else
        printf '%s\n' $output_lines
    end
end
