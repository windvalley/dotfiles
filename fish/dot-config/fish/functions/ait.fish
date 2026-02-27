function ait -d "自动更新 Changelog 加发版 (AI Release)"
    # 检查 AI 工具配置
    if test -z "$AI_CMD"
        echo "❌ 未检测到可用的 AI 命令，请在 ~/.config/fish/config.local.fish 中配置 AI_CMD"
        return 1
    end

    # 1. 环境自检
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "❌ 当前目录不是 Git 仓库"
        return 1
    end

    # 检查是否有未处理的变更（仅作提示，不中断）
    set -l status_count (git status --porcelain | grep -v "CHANGELOG.md" | count)
    if test "$status_count" -gt 0
        echo "⚠️  注意：当前工作区存在未提交的更改（Changelog 除外）"
    end

    # 2. 获取版本上下文
    set -l last_tag (git tag --sort=-v:refname | head -n 1)
    set -l log_range "HEAD"
    if test -n "$last_tag"
        set log_range "$last_tag..HEAD"
        echo "📡 正在分析自 $last_tag 以来的变更..."
    else
        echo "📡 未发现历史 Tag，正在从头分析所有提交..."
    end

    set -l commit_logs (git log $log_range --pretty=format:"%h %s" | string collect)
    if test -z "$commit_logs"
        echo "❌ 没有发现新的 Commit，无需发版"
        return 1
    end

    # 交互式语言选择
    set -l is_chinese 0
    set -l lang_prompt "Please generate the version number and changelog in English."
    
    if not read -P "🌐 发布说明语言选择? [Enter=英文 / c=中文] " lang_choice
        echo ""
        echo "❌ 已取消"
        return 1
    end

    if test "$lang_choice" = "c" -o "$lang_choice" = "C"
        set is_chinese 1
        set lang_prompt "请使用中文生成版本号和发布说明。"
        echo "🇨🇳 已选择中文"
    else
        echo "🇺🇸 已选择英文 (默认)"
    end

    # 3. 调用 AI 循环生成 Changelog 和版本号
    set -l supplementary_info ""
    set -l loop_active true
    
    set -l new_version ""
    set -l release_lines
    
    while test "$loop_active" = "true"
        echo "🤖 正在由 AI 生成发布说明并推断版本号..."
        
        set -l current_date (date "+%Y-%m-%d")
        set -l prompt "你是一个资深开源项目发布工程师。请不要把 Commit 当作流水账翻译！请你站在本次『全局整合发版』的视角，分析这些零乱的 Git Commit 记录，合并出最终的交付成果，生成一份务实的 CHANGELOG 总结，并推断下一个合理的版本号。

$lang_prompt

当前日期: $current_date
上一个版本: $last_tag (如果没有，请从 v0.1.0 开始)

提交记录:
$commit_logs

要求:
1. 【全局视角聚合】: 不要原样逐条列出 Commit！合并同一个特性的进度。比如提交中如果有“新增 A”、“完善 A”、“将 A 重命名为 B”，在发布总结里只需要写一条：“新增核心功能 B”。屏蔽开发过程中反反复复的中间状态和修复，只展示给用户看的变化！
2. 根据语义化版本 (SemVer) 规范推断版本号。如果有新功能(feat)则增加 MINOR，只有修复(fix/patch)则增加 PATCH。
3. 返回格式必须是以下两部分，用 '---VERSION_SPLIT---' 分隔：
   第一部分：仅包含推断出的纯版本号（例如 1.2.0，不要带 v）
   第二部分：对应的 CHANGELOG 内容，格式遵循 Keep a Changelog 规范。二级标题必须为 ## [VERSION] - DATE。具体条目按 Added, Changed, Fixed 等归类，内容使用无序列表即可。

4. 强制约束：只返回以上两部分内容，不带 Markdown 代码块或其他多余解释。"

        if test -n "$supplementary_info"
            set prompt "$prompt

【强烈注意】用户提供了以下补充说明，请务必将其融入到生成的内容中：
$supplementary_info"
        end

        set -l ai_output (eval "$AI_CMD" \"\$prompt\" | string collect)
        if test $status -ne 0
            echo ""
            echo "❌ AI 生成失败"
            return 1
        end

        # 拆分版本号和内容
        set -l split_token "---VERSION_SPLIT---"
        # 关键：加引号确保整个输出作为一个整体处理，避免 Fish 数组自动分割行
        set -l parts (string split -m 1 -- "$split_token" "$ai_output")
        
        set new_version ""
        set release_lines

        set -l parse_success 0
        if test (count $parts) -ge 2
            set new_version (string trim "$parts[1]")
            # 按行分割为纯数组，同时去掉末尾可能会有的 \r 回车符
            set release_lines (string split \n -- "$parts[2]" | string replace -r '\r$' '')
            
            # 弹出开头和结尾的空行
            while test (count $release_lines) -gt 0; and test -z "$(string trim -- "$release_lines[1]")"
                set -e release_lines[1]
            end
            while test (count $release_lines) -gt 0; and test -z "$(string trim -- "$release_lines[-1]")"
                set -e release_lines[-1]
            end
            
            if test -n "$new_version" -a (count $release_lines) -gt 0
                set parse_success 1
            end
        end

        if test "$parse_success" -eq 0
            echo "❌ AI 返回格式不正确，无法解析版本和内容"
            echo "🤖 AI 原始输出如下："
            echo "--------------------"
            printf "%s\n" "$ai_output"
            echo "--------------------"
        else
            echo ""
            echo "📦 推断版本号: v$new_version"
            echo "📝 预览发布说明:"
            # 遍历原汁原味的行数组，保留所有的缩进与文本排版
            for line in $release_lines
                echo "   $line"
            end
            echo ""
        end

        # 4. 用户确认
        set -l toggle_prompt "t(翻译为中文)"
        if test "$is_chinese" -eq 1
            set toggle_prompt "t(翻译为英文)"
        end
        
        if not read -P "确认执行发版流程? [Y/n/r(重写)/p(微调)/$toggle_prompt] " confirm
            echo ""
            echo "❌ 已取消"
            return 1
        end

        switch $confirm
            case Y y ""
                if test "$parse_success" -eq 0
                    echo "❌ 当前解析结果无效，请重新生成或退出"
                    continue
                end
                set loop_active false
                
            case R r
                echo "🔄 正在重新生成..."
                
            case P p
                echo ""
                if not read -P "✏️  请输入修改要求 (如: '版本号改为 1.3.0' 或 '更详细描述某个更新'): " addon
                    echo ""
                    echo "❌ 已取消微调"
                    return 1
                end

                if test -n "$addon"
                    set supplementary_info "$supplementary_info
- $addon"
                end
                echo "🔄 正在根据新的提示信息重新生成..."
                
            case T t
                if test "$is_chinese" -eq 1
                    set is_chinese 0
                    set lang_prompt "Please generate the version number and changelog in English."
                    echo "🇺🇸 正在切换为英文并重新生成..."
                else
                    set is_chinese 1
                    set lang_prompt "请使用中文生成版本号和发布说明。"
                    echo "🇨🇳 正在切换为中文并重新生成..."
                end
                
            case '*'
                echo "❌ 已取消"
                return 1
        end
    end

    # 5. 执行发版动作
    echo "🚀 正在更新 CHANGELOG.md..."
    
    set -l changelog_file "CHANGELOG.md"
    if not test -f "$changelog_file"
        echo "# Changelog" > "$changelog_file"
        echo "" >> "$changelog_file"
    end

    set -l temp_changelog (mktemp)
    set -l marker "## [Unreleased]"
    # 把安全的行数组拼合为干净的多行文本流
    set -l final_content (string join \n -- $release_lines)
    
    if grep -qF "$marker" "$changelog_file"
        # 使用原生切割重组的方式，绝不依赖具有不同行为的外部工具（如 sed 的插桩或 awk 把新行吃掉）
        set -l marker_line (grep -nF "$marker" "$changelog_file" | cut -d: -f1 | head -n 1)
        
        # 将 [1, marker_line] 部分的头部截取出来
        head -n $marker_line "$changelog_file" > $temp_changelog
        echo "" >> $temp_changelog
        
        # 写入原形毕露的全文本数组
        for line in $release_lines
            echo "$line" >> $temp_changelog
        end
        echo "" >> $temp_changelog
        
        # 将 (marker_line, 末尾] 部分的尾部追加回来
        set -l tail_start (math $marker_line + 1)
        tail -n +$tail_start "$changelog_file" >> $temp_changelog
    else
        # 如果没有标记，在第一行标题后插入
        set -l head_text (head -n 1 "$changelog_file")
        echo "$head_text" > $temp_changelog
        echo "" >> $temp_changelog
        for line in $release_lines
            echo "$line" >> $temp_changelog
        end
        echo "" >> $temp_changelog
        tail -n +2 "$changelog_file" >> $temp_changelog
    end

    if test -s "$temp_changelog"
        mv $temp_changelog "$changelog_file"
    else
        echo "❌ 更新 CHANGELOG.md 失败：临时文件为空"
        rm -f $temp_changelog
        return 1
    end

    echo "💾 正在提交..."
    git add "$changelog_file"
    # 只提交 CHANGELOG.md，避免把工作区其他已暂存的文件意外带进去
    if not git commit "$changelog_file" -m "chore(release): prepare v$new_version"
        echo "❌ Git 提交失败（可能没有实际变更）"
        return 1
    end

    echo "🏷️  正在打 Tag..."
    if not git tag -a "v$new_version" -m "Release version $new_version"
        echo "❌ Git Tag v$new_version 失败"
        return 1
    end

    echo "✨ 发版成功! 已打 Tag v$new_version"
    echo "💡 提示: 执行 'git push --follow-tags' 推送到远程仓库"
end
