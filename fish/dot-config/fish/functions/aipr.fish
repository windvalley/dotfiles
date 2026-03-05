function aipr -d "根据分支变更自动生成 Pull Request 描述"
    # 打印工具简介
    echo -e "\n🚀 [\e[1maipr\e[0m] \e[36mAI-Powered PR Description Tool\e[0m"
    echo -e "   \e[90mWorkflow: Analyze Branch Diff -> AI Gen PR Description -> Copy / Create PR\e[0m\n"

    if not command -sq aichat
        echo "❌ 未找到 aichat，请先安装并配置"
        return 127
    end

    # 检查是否在 git 仓库中
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "❌ 当前目录不是 Git 仓库"
        return 1
    end

    # 确定目标分支（默认 main）
    set -l target_branch main
    if test (count $argv) -gt 0
        set target_branch $argv[1]
    end

    # 验证目标分支存在
    if not git rev-parse --verify $target_branch >/dev/null 2>&1
        echo "❌ 目标分支 '$target_branch' 不存在"
        return 1
    end

    # 获取当前分支
    set -l current_branch (git branch --show-current)
    if test -z "$current_branch"
        echo "❌ 当前处于分离 HEAD 状态，请先切换到功能分支"
        return 1
    end

    # 防止在目标分支上直接运行
    if test "$current_branch" = "$target_branch"
        echo "❌ 当前已在 '$target_branch' 分支上，请切换到功能分支后再运行"
        return 1
    end

    # 计算合并基点，获取当前分支独有的变更
    set -l merge_base (git merge-base $target_branch $current_branch)
    if test -z "$merge_base"
        echo "❌ 无法找到 '$current_branch' 与 '$target_branch' 的共同祖先"
        return 1
    end

    # 收集 commit 列表
    set -l commit_logs (git log $merge_base..$current_branch --pretty=format:"%h %s" | string collect)
    if test -z "$commit_logs"
        echo "❌ 当前分支相对 '$target_branch' 没有新的 Commit"
        return 1
    end

    # 收集 diff stat（文件级变更概览）
    set -l diff_stat (git diff --stat $merge_base..$current_branch | string collect)

    # 收集完整 diff（限制大小，避免超出 AI token 限制）
    set -l diff_content (git diff $merge_base..$current_branch | string collect)
    set -l diff_length (string length -- "$diff_content")

    # 如果 diff 过大（>30000 字符），只使用 stat 和 commit 摘要
    set -l diff_truncated 0
    if test $diff_length -gt 30000
        set diff_content (echo "$diff_content" | head -c 30000 | string collect)
        set diff_truncated 1
    end

    # 显示变更概览
    set -l commit_count (git rev-list --count $merge_base..$current_branch)
    echo -e "📊 \e[1m变更概览\e[0m"
    echo -e "   分支: \e[33m$current_branch\e[0m → \e[32m$target_branch\e[0m"
    echo -e "   提交: \e[36m$commit_count\e[0m 个"
    echo ""

    # 交互式语言选择
    set -l is_chinese 0
    set -l lang_prompt "Please generate the PR description in English."

    if not read -P "🌐 语言选择? [Enter=英文 / c=中文] " lang_choice
        echo ""
        echo "❌ 已取消"
        return 1
    end

    if test "$lang_choice" = c -o "$lang_choice" = C
        set is_chinese 1
        set lang_prompt "请使用中文生成 PR 描述。"
        echo "🇨🇳 已选择中文"
    else
        echo "🇺🇸 已选择英文 (默认)"
    end

    echo "🤖 正在分析分支变更..."

    set -l supplementary_info ""

    set -l loop_active true
    set -l msg_tmpfile ""

    while test "$loop_active" = true
        if test -z "$msg_tmpfile"
            # 每次循环重新构建 Prompt，以便语言选项发生变化时能生效
        set -l prompt_text "根据以下 Git 分支变更信息，生成一份结构化的 Pull Request 描述。

格式要求:
1. 第一行是 PR 标题，格式: type(scope): description （简洁准确，限制在 72 字符内）
2. 空一行后是 PR 正文（Body），包含以下章节:
   - ## Summary（变更摘要：1-2 句话概述本 PR 的目的和动机）
   - ## Changes（详细变更列表：按逻辑分组，每项用 '- ' 开头）
   - ## Impact（影响范围：列出对用户、系统或其他模块的潜在影响）
3. 如有必要也可以加 ## Notes 章节说明注意事项

$lang_prompt

当前分支: $current_branch → $target_branch
提交数量: $commit_count

提交记录:
$commit_logs

文件变更统计:
$diff_stat

⚠️ 绝对约束：
- 绝对禁止输出任何解释、思考过程或引导语！
- 只返回严格的 PR 描述文本本身。
- 禁止使用外层的 Markdown 代码块 (\`\`\`)包裹整个输出。
- 第一行必须直接是 PR 标题！"

        if test $diff_truncated -eq 1
            set prompt_text "$prompt_text

（注：diff 内容较大，以下仅展示前 30000 字符）"
        end

        if test -n "$supplementary_info"
            set prompt_text "$prompt_text

【强烈注意】用户提供了以下补充说明，请务必将其融入到生成的内容中：
$supplementary_info"
        end

        set prompt_text "$prompt_text

<diff>
$diff_content
</diff>"

        # 调用 aichat 生成内容
        set msg_tmpfile (mktemp)
        aichat --no-stream "$prompt_text" >$msg_tmpfile
        set -l ai_exit_status $status

        # 捕捉在 AI 生成过程中被 Ctrl+C 中断的情况或者命令执行失败
        if test $ai_exit_status -ne 0
            rm -f $msg_tmpfile
            echo ""
            echo "❌ 操作已中断或报错退出"
            return 1
        end

        # 如果文件为空（AI未输出或因发生类似模型未找到的错误而仅输出到了 stderr）
        if not test -s $msg_tmpfile
            rm -f $msg_tmpfile
            echo ""
            echo "❌ AI 生成失败 (未获取到输出内容，请检查上方报错信息)"
            return 1
        end

        # opencode 有时被中断返回 0 但输出包含 Interrupted by user
        # 仅在退出码为 0 时额外检查此边缘情况
        if grep -q "Interrupted by user" $msg_tmpfile
            rm -f $msg_tmpfile
            echo ""
            echo "❌ 操作已中断"
            return 1
        end

        # 清理响应: 移除模型思考与外层 Markdown 块标记
        sed -i '' -e '/^<think>/,/^<\/think>/d' $msg_tmpfile
        sed -i '' -e '/^```\(markdown\|md\|text\)/d' -e '/^```$/d' $msg_tmpfile
        end

        echo ""
        echo "📝 建议 PR 描述:"
        echo -e "\e[90m────────────────────────────────────────\e[0m"
        awk '{print "   " $0}' $msg_tmpfile
        echo -e "\e[90m────────────────────────────────────────\e[0m"
        echo ""

        # 构建交互选项
        set -l toggle_prompt "t(翻译为中文)"
        if test "$is_chinese" -eq 1
            set toggle_prompt "t(翻译为英文)"
        end

        set -l gh_prompt ""
        if command -q gh
            set gh_prompt "/g(gh创建PR)"
        end

        # 捕捉 Ctrl+C (read 被中断时会返回非 0)
        if not read -P "操作? [Y(复制)/e(编辑)/r(重写)/p(微调)/$toggle_prompt$gh_prompt/n(取消)] " confirm
            rm -f $msg_tmpfile
            echo ""
            echo "❌ 已取消"
            return 1
        end

        switch $confirm
            case Y y ""
                cat $msg_tmpfile | pbcopy
                echo "✅ PR 描述已复制到剪贴板"
                echo -e "💡 现在可以直接 \e[1mCmd+V\e[0m 粘贴到 GitHub PR 页面"
                rm $msg_tmpfile
                set loop_active false

            case E e
                set -l editor hx
                if set -q EDITOR
                    set editor $EDITOR
                end
                eval $editor $msg_tmpfile

                echo "✅ 修改已保存"

            case R r
                rm -f $msg_tmpfile
                set msg_tmpfile ""
                echo "🔄 正在重新生成..."
                echo "🤖 正在分析分支变更..."

            case P p
                rm -f $msg_tmpfile
                set msg_tmpfile ""
                echo ""

                # 捕获 Ctrl+C 或 Ctrl+D 中断
                if not read -P "✏️  请输入修改要求 (如: '加上性能影响说明' 或 '标题更简洁'): " addon
                    echo ""
                    echo "❌ 已取消微调"
                    return 1
                end

                if test -n "$addon"
                    set supplementary_info "$supplementary_info
- $addon"
                end
                echo "🔄 正在根据新的提示信息重新生成..."
                echo "🤖 正在分析分支变更..."

            case T t
                rm -f $msg_tmpfile
                set msg_tmpfile ""
                if test "$is_chinese" -eq 1
                    set is_chinese 0
                    set lang_prompt "Please generate the PR description in English."
                    echo "🇺🇸 正在切换为英文并重新生成..."
                else
                    set is_chinese 1
                    set lang_prompt "请使用中文生成 PR 描述。"
                    echo "🇨🇳 正在切换为中文并重新生成..."
                end
                echo "🤖 正在分析分支变更..."

            case G g
                if not command -q gh
                    echo "❌ gh CLI 未安装，请先运行 'brew install gh'"
                    continue
                end

                # 提取标题（第一行）和正文（其余内容）
                set -l pr_title (head -1 $msg_tmpfile)
                set -l pr_body (tail -n +3 $msg_tmpfile | string collect)

                echo ""
                echo -e "📤 即将创建 PR: \e[33m$current_branch\e[0m → \e[32m$target_branch\e[0m"
                echo -e "   标题: \e[1m$pr_title\e[0m"
                echo ""

                if not read -P "确认创建? [Y/n] " gh_confirm
                    echo ""
                    echo "❌ 已取消创建"
                    continue
                end

                switch $gh_confirm
                    case Y y ""
                        gh pr create --base $target_branch --title "$pr_title" --body "$pr_body"
                        if test $status -eq 0
                            echo "✅ PR 创建成功!"
                        else
                            echo "❌ PR 创建失败，描述已复制到剪贴板备用"
                            cat $msg_tmpfile | pbcopy
                        end
                        rm -f $msg_tmpfile
                        set loop_active false
                    case '*'
                        echo "❌ 已取消创建"
                end

            case N n
                rm $msg_tmpfile
                echo "❌ 已取消"
                set loop_active false

            case '*'
                rm $msg_tmpfile
                echo "❌ 已取消"
                set loop_active false
        end
    end
end
