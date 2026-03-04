function a -d "列出所有配置的缩写 (Abbreviations) 及其功能描述"
    echo "📋 Dotfiles 缩写 (Abbreviations) 一览："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  %-12s %-26s %s\n" "缩写" "展开为" "说明"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    set -l config_file ~/.config/fish/config.fish
    
    if test -f $config_file
        cat $config_file | grep '^\s*abbr -a -g ' | while read -l line
            set -l abbr_name (string replace -r '^\s*abbr -a -g\s+([^\s]+).*' '$1' -- $line)
            set -l rest (string replace -r '^\s*abbr -a -g\s+[^\s]+\s+(.*)' '$1' -- $line)
            set -l tokens (string split -m 1 "#" -- $rest)
            
            set -l abbr_cmd (string trim -c "' " -- $tokens[1])
            set -l abbr_desc "—"
            
            if test (count $tokens) -gt 1
                set abbr_desc (string trim -- $tokens[2])
            end
            
            printf "  %-12s %-26s %s\n" "$abbr_name" "$abbr_cmd" "$abbr_desc"
        end
    end

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 提示: 输入缩写后敲击空格即可自动展开为完整命令"
end
