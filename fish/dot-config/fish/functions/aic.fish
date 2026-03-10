function aic -d "根据代码变更自动生成 Git Commit 信息"
    if test (count $argv) -gt 0; and contains -- $argv[1] -h --help
        echo "AI-Powered Commit Tool"
        echo ""
        echo "Usage:"
        echo "  aic                   Analyze staged changes and generate commit message"
        echo "  aic -h | --help       Show this help message"
        return 0
    end
    # 打印工具简介
    echo -e "\n🚀 [\e[1maic\e[0m] \e[36mAI-Powered Commit Tool\e[0m"
    echo -e "   \e[90mWorkflow: Analyze Staged Changes -> AI Gen Commit Message -> Commit\e[0m\n"

    if not command -sq aichat
        echo "❌ 未找到 aichat，请先安装并配置"
        return 127
    end
    
    # 检查是否在 git 仓库中
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "❌ 当前目录不是 Git 仓库"
        return 1
    end
    
    # 使用 string collect 可以保留完整的换行符和 diff 格式
    set -l diff (git diff --cached | string collect)
    if test -z "$diff"
        echo "❌ 没有暂存的更改，请先 git add"
        return 1
    end

    # 交互式语言选择
    set -l is_chinese 0
    set -l lang_prompt "Please generate the commit message in English."
    
    if not read -P "🌐 语言选择? [Enter=英文 / c=中文] " lang_choice
        echo ""
        echo "❌ 已取消"
        return 1
    end

    if test "$lang_choice" = "c" -o "$lang_choice" = "C"
        set is_chinese 1
        set lang_prompt "请使用中文生成提交信息。"
        echo "🇨🇳 已选择中文"
    else
        echo "🇺🇸 已选择英文 (默认)"
    end
    
    echo "🤖 正在分析代码变更..."
    
    set -l supplementary_info ""
    
    set -l loop_active true
    
    while test "$loop_active" = "true"
        # 每次循环重新构建 Prompt，以便语言选项发生变化时能生效
        set -l prompt_text "根据以下 git diff 生成符合 Conventional Commits 规范的提交信息。
格式要求:
1. 第一行标题必须是: type(scope): description （严格限制在 50 个字符以内）
2. 必须包含空行分隔的 Body 部分，详细解释修改的原因和具体内容。Body 的每一行文本必须在 72 个字符处强制换行（Hard wrap）。
3. Body 中的每一个修改条目必须以 '- ' (连字符加空格) 开头，形成无序列表风格。
4. 如果有相关的 Breaking Changes 或者 Issue 关闭，请在 Footer 提供。

$lang_prompt

类型可选: feat, fix, docs, style, refactor, test, chore

⚠️ 绝对约束：
- 绝对禁止输出任何解释、思考过程、分析意图（如 'I detect implementation intent'）或引导语！
- 只返回严格的提交信息文本本身。
- 禁止使用外层的 Markdown 代码块 (\`\`\`)。
- 第一行必须直接是 type(scope): description 格式！"

        if test -n "$supplementary_info"
            set prompt_text "$prompt_text

【强烈注意】用户提供了以下补充说明，请务必将其融入到生成的提交信息中：
$supplementary_info"
        end

        set prompt_text "$prompt_text

<diff>
$diff
</diff>"

        # 调用 aichat 生成内容
        set -l msg_tmpfile (mktemp)
        aichat --no-stream "$prompt_text" > $msg_tmpfile
        set -l ai_exit_status $status
        
        # 捕捉在 AI 生成过程中被 Ctrl+C 中断的情况或者命令执行失败
        # 先检查退出码：Ctrl+C (130) 或其他错误
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
        
        # 清理响应: 移除模型思考与 Markdown 块标记
        sed -i '' -e '/^<think>/,/^<\/think>/d' $msg_tmpfile
        sed -i '' -e '/^```\(commit\|text\)/d' -e '/^```$/d' $msg_tmpfile
        
        # 兜底防御：大模型有时仍会输出思考过程或废话。
        # 这里使用 awk 截取从标准的 Conventional Commit 起始的所有内容，抛弃前面的废话
        awk '/^(feat|fix|docs|style|refactor|test|chore|perf|build|ci|revert)(\([^)]+\))?: / {found=1} found {print}' $msg_tmpfile > $msg_tmpfile.tmp
        if test -s $msg_tmpfile.tmp
            mv $msg_tmpfile.tmp $msg_tmpfile
        else
            rm -f $msg_tmpfile.tmp
        end
        
        echo ""
        echo "📝 建议提交信息:"
        awk '{print "   " $0}' $msg_tmpfile
        echo ""
        
        set -l toggle_prompt "t(翻译为中文)"
        if test "$is_chinese" -eq 1
            set toggle_prompt "t(翻译为英文)"
        end
        
        # 捕捉 Ctrl+C (read 被中断时会返回非 0)
        if not read -P "确认提交? [Y/n/e(编辑)/r(重写)/p(微调)/$toggle_prompt] " confirm
            rm -f $msg_tmpfile
            echo ""
            echo "❌ 已取消"
            return 1
        end
        
        switch $confirm
            case Y y ""
                set -l final_msg (cat $msg_tmpfile | string collect)
                if test -n "$final_msg"
                    git commit -m "$final_msg"
                else
                    echo "❌ 提交信息为空，已取消"
                end
                rm $msg_tmpfile
                set loop_active false
                
            case E e
                # 直接以 AI 生成内容作为初始提交信息，进入 git commit 编辑界面继续修改
                if not env | string match -qr '^GIT_EDITOR=.+'; and not env | string match -qr '^VISUAL=.+'; and not env | string match -qr '^EDITOR=.+'; and not git config --get core.editor >/dev/null 2>&1; and command -sq hx
                    env GIT_EDITOR=hx git commit --edit --file=$msg_tmpfile
                else
                    git commit --edit --file=$msg_tmpfile
                end
                rm $msg_tmpfile
                set loop_active false
                
            case R r
                rm $msg_tmpfile
                echo "🔄 正在重新生成..."
                echo "🤖 正在分析代码变更..."
                
            case P p
                rm $msg_tmpfile
                echo ""
                
                # 捕获 Ctrl+C 或 Ctrl+D 中断
                if not read -P "✏️  请输入修改要求 (如: '语气更正式一点' 或 '加上关闭 Issue #123'): " addon
                    echo ""
                    echo "❌ 已取消微调"
                    return 1
                end

                if test -n "$addon"
                    set supplementary_info "$supplementary_info
- $addon"
                end
                echo "🔄 正在根据新的提示信息重新生成..."
                echo "🤖 正在分析代码变更..."
                
            case T t
                rm $msg_tmpfile
                if test "$is_chinese" -eq 1
                    set is_chinese 0
                    set lang_prompt "Please generate the commit message in English."
                    echo "🇺🇸 正在切换为英文并重新生成..."
                else
                    set is_chinese 1
                    set lang_prompt "请使用中文生成提交信息。"
                    echo "🇨🇳 正在切换为中文并重新生成..."
                end
                echo "🤖 正在分析代码变更..."
                
            case '*'
                rm $msg_tmpfile
                echo "❌ 已取消"
                set loop_active false
        end
    end
end
