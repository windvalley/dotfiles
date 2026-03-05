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

        # 直接从源文件中提取 -d 描述（最可靠的方式）
        set -l desc (grep -m1 '^function ' $file | string replace -r '^function\s+\S+.*-d\s+["\x27]([^"\x27]+)["\x27].*' '$1')
        if test -z "$desc"
            set desc "—"
        end

        printf "  %-16s %s\n" "$name" "$desc"
    end

    echo ""
    echo "💡 提示: 查看具体用法请输入 type <命令名>"
end
