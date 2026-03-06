function c -d "列出所有 dotfiles 自定义命令及其说明"
    # 排除 Fish 内部钩子函数，只列出用户自己写的实用命令
    set -l exclude_list fish_user_key_bindings fish_prompt fish_right_prompt fish_mode_prompt fish_greeting

    echo "📋 Dotfiles 自定义命令一览："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  %-16s %s\n" "命令" "说明"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    for file in ~/.config/fish/functions/*.fish
        set -l name (basename $file .fish)

        # 跳过 Fish 内部钩子函数
        if contains $name $exclude_list
            continue
        end

        # 跳过以下划线开头的私有辅助函数
        if string match -q "_*" $name
            continue
        end

        # 只提取与文件同名函数的 -d 描述，避免同文件里的私有辅助函数串行。
        set -l escaped_name (string escape --style=regex -- "$name")
        set -l function_line (grep -m1 -E "^function[[:space:]]+"$escaped_name"[[:space:]]" $file)
        set -l desc (string match -r --groups-only ".*-d\\s+[\"']([^\"']+)[\"'].*" -- "$function_line")
        if test -z "$desc"
            set desc "—"
        end

        printf "  %-16s %s\n" "$name" "$desc"
    end

    echo ""
    echo "💡 提示: 查看具体用法请输入 type <命令名>"
end
