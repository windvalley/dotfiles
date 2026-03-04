function aip -d "AI 即插即用指令库：获取并复制常用的 AI 编程指挥语"
    argparse 'h/help' 'e/edit' 'l/list' 'r/random' -- $argv
    or return

    # 数据文件路径（与 functions/ 同级，stow 后为 ~/.config/fish/ai-prompts.list）
    set -l list_file (dirname (status filename))/../ai-prompts.list
    if not test -f "$list_file"
        echo -e "\e[31m❌ 未找到指令库: $list_file\e[0m"
        echo "   请确认 dotfiles 已正确 stow，或执行 aip -h 查看帮助"
        return 1
    end

    # ── 解析外部数据文件 ─────────────────────────────────────────
    set -l categories
    set -l titles
    set -l prompts
    while read -l line
        # 跳过注释行和空行
        if string match -q '#*' -- "$line"; or test -z "$line"
            continue
        end
        set -l parts (string split --max 2 '|' -- "$line")
        if test (count $parts) -lt 3
            continue
        end
        set -a categories (string trim -- "$parts[1]")
        set -a titles (string trim -- "$parts[2]")
        set -a prompts (string trim -- "$parts[3]")
    end <"$list_file"

    set -l total (count $prompts)
    if test $total -eq 0
        echo -e "\e[31m❌ 指令库为空，请编辑: $list_file\e[0m"
        return 1
    end

    # ── 帮助 ─────────────────────────────────────────────────────
    if set -q _flag_help
        echo -e "\n\e[1;36m🤖 aip — AI 即插即用指令库\e[0m"
        echo -e "   \e[90m数据与逻辑分离 · fzf 交互多选 · 实时预览 · 分类过滤\e[0m\n"
        echo "用法:"
        echo "  aip                 fzf 交互选择（支持多选 + 实时预览）"
        echo "  aip <编号>          直接复制指定编号（支持空格分隔多选）"
        echo "  aip <关键词>        按分类、标题或内容过滤"
        echo "  aip -l, --list      列出全部指令（按分类分组）"
        echo "  aip -r, --random    随机复制一条"
        echo "  aip -e, --edit      用编辑器打开指令库文件"
        echo "  aip -h, --help      显示此帮助"
        return 0
    end

    # ── 编辑模式 ─────────────────────────────────────────────────
    if set -q _flag_edit
        set -l editor hx
        if set -q EDITOR
            set editor $EDITOR
        end
        $editor "$list_file"
        return 0
    end

    # ── 随机模式 ─────────────────────────────────────────────────
    if set -q _flag_random
        set -l idx (random 1 $total)
        echo -n "$prompts[$idx]" | pbcopy
        echo -e "\n✅ 已随机复制 \e[1;33m$titles[$idx]\e[0m 至剪贴板\n"
        echo -e "\e[90m$prompts[$idx]\e[0m\n"
        echo "💡 现在可以直接 Cmd+V 粘贴给 AI 助手了"
        return 0
    end

    # ── 列表模式 ─────────────────────────────────────────────────
    if set -q _flag_list
        echo -e "\n\e[1;36m🤖 AI 即插即用指令库\e[0m （共 \e[33m$total\e[0m 条）\n"
        set -l last_cat ""
        for i in (seq $total)
            if test "$categories[$i]" != "$last_cat"
                test -n "$last_cat"; and echo ""
                echo -e "\e[1;35m  [$categories[$i]]\e[0m"
                set last_cat "$categories[$i]"
            end
            echo -e "    \e[32m$i.\e[0m $titles[$i]"
        end
        echo ""
        return 0
    end

    # ── 位置参数：编号直选 / 关键词过滤 ──────────────────────────
    if test (count $argv) -gt 0
        if string match -qr '^[0-9]+$' -- "$argv[1]"
            # 按编号直接复制（支持多个编号）
            set -l copied
            for num in $argv
                string match -qr '^[0-9]+$' -- "$num"; or continue
                if test "$num" -ge 1 -a "$num" -le $total
                    set -a copied "$prompts[$num]"
                    echo -e "✅ 已复制 \e[32m#$num\e[0m: \e[33m$titles[$num]\e[0m"
                else
                    echo -e "⚠️  编号 #$num 超出范围 (1-$total)"
                end
            end
            if test (count $copied) -gt 0
                printf "%s" (string join \n\n $copied) | pbcopy
            end
            return 0
        end

        # 关键词过滤
        set -l keyword "$argv[1]"
        echo -e "\n\e[35m🔍 过滤: $keyword\e[0m\n"
        set -l found 0
        for i in (seq $total)
            # 仅匹配分类名和标题（短字符串），不搜索 prompt 全文
            # 避免 glob 模式在长文本上的灾难性回溯
            if string match -qi -- "*$keyword*" "$categories[$i]" "$titles[$i]"
                echo -e "  \e[32m$i.\e[0m [\e[35m$categories[$i]\e[0m] $titles[$i]"
                set found (math $found + 1)
            end
        end
        if test $found -eq 0
            echo "  未找到匹配项"
        else
            echo -e "\n\e[90m💡 使用 aip <编号> 可直接复制\e[0m"
        end
        echo ""
        return 0
    end

    # ── fzf 交互式主菜单 ────────────────────────────────────────
    if command -q fzf
        # 将 prompt 正文写入临时文件，供 preview 按行号读取
        set -l tmpfile (mktemp)
        printf '%s\n' $prompts >"$tmpfile"

        # 创建 preview 辅助脚本（bash 语法，避免 fish 与 POSIX 语法不兼容）
        # 原因：fzf 的 --preview 通过 $SHELL -c 执行，当 $SHELL 为 fish 时
        #       POSIX 的 n=$(...) 赋值语法会报错，必须使用独立的 bash 脚本
        set -l preview_script (mktemp)
        printf '%s\n' \
            '#!/bin/bash' \
            'n="${1%%.*}"' \
            'n="${n// /}"' \
            'sed -n "${n}p" "$2" | fold -sw 78' >"$preview_script"
        chmod +x "$preview_script"

        # 构建 fzf 显示列表
        set -l options
        for i in (seq $total)
            set -a options (printf "%2d. [%s] %s" $i $categories[$i] $titles[$i])
        end

        set -l selected (printf '%s\n' $options | fzf \
            --multi \
            --ansi \
            --height 80% \
            --layout=reverse \
            --border \
            --prompt "🤖 AI Prompt > " \
            --header "Tab 多选 · Enter 复制 · Ctrl-C 退出 · aip -e 编辑库" \
            --preview "$preview_script {} $tmpfile" \
            --preview-window right:50%:wrap)

        # 清理临时文件
        rm -f "$tmpfile" "$preview_script"

        test -z "$selected"; and return 0

        # 提取选中项并合并复制（修复逐条复制只保留最后一条的问题）
        set -l copied
        for line in $selected
            set -l num (string match -r '^\s*(\d+)\.' -- "$line")[2]
            if test -n "$num"
                set -a copied "$prompts[$num]"
                echo -e "✅ 已复制 \e[32m#$num\e[0m → \e[1;33m$titles[$num]\e[0m"
            end
        end
        if test (count $copied) -gt 0
            printf "%s" (string join \n\n $copied) | pbcopy
            echo -e "\n💡 现在可以直接 Cmd+V 粘贴给 AI 助手了"
        end
        return 0
    end

    # ── 无 fzf 降级：彩色列表 + 编号输入 ────────────────────────
    echo -e "\n\e[1;36m🤖 AI 即插即用指令库\e[0m （共 \e[33m$total\e[0m 条）"
    echo -e "\e[90m💡 安装 fzf (brew install fzf) 可获得交互式多选与预览体验\e[0m\n"

    set -l last_cat ""
    for i in (seq $total)
        if test "$categories[$i]" != "$last_cat"
            test -n "$last_cat"; and echo ""
            echo -e "\e[1;35m  [$categories[$i]]\e[0m"
            set last_cat "$categories[$i]"
        end
        echo -e "    \e[32m$i.\e[0m $titles[$i]"
    end

    echo ""
    echo "──────────────────────────────────────"
    if not read -P (set_color cyan)"输入编号（空格分隔多选 / q 退出）: "(set_color normal) choice
        echo ""
        return 0
    end
    if test "$choice" = q -o "$choice" = Q -o -z "$choice"
        return 0
    end

    set -l copied
    for num in (string split ' ' -- "$choice")
        string match -qr '^[0-9]+$' -- "$num"; or continue
        if test "$num" -ge 1 -a "$num" -le $total
            set -a copied "$prompts[$num]"
            echo -e "✅ 已复制 \e[32m#$num\e[0m: \e[33m$titles[$num]\e[0m"
        else
            echo -e "⚠️  编号 #$num 超出范围 (1-$total)"
        end
    end
    if test (count $copied) -gt 0
        printf "%s" (string join \n\n $copied) | pbcopy
        echo -e "\n💡 现在可以直接 Cmd+V 粘贴给 AI 助手了"
    end
end
