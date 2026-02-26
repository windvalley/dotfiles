function gci -d "AI 生成 Git 提交信息"
    # 检查 AI 工具配置（已由 config.fish 初始化）
    if test -z "$AI_CMD"
        echo "❌ 未检测到可用的 AI 工具 (支持：kimi, aichat, opencode, claude, gemini, sgpt, gh copilot)"
        return 1
    end
    
    set -l ai_name "$AI_NAME"
    set -l ai_cmd "$AI_CMD"
    
    # 修复：原来直接 (git diff --cached) 会导致换行符丢失（fish 会把输出按行分割成数组，再转字符串时变成空格分隔）
    # 使用 string collect 可以保留完整的换行符和 diff 格式
    set -l diff (git diff --cached | string collect)
    if test -z "$diff"
        echo "❌ 没有暂存的更改，请先 git add"
        return 1
    end
    
    echo "🤖 $ai_name 正在分析更改..."
    
    set -l is_chinese 0
    set -l lang_prompt "Please generate the commit message in English."
    if count $argv > /dev/null
        set is_chinese 1
        set lang_prompt "请使用中文生成提交信息。"
    end
    
    set -l loop_active true
    
    while test "$loop_active" = "true"
        # 每次循环重新构建 Prompt，以便语言选项发生变化时能生效
        set -l prompt_text "根据以下 git diff 生成符合 Conventional Commits 规范的提交信息。
格式要求:
1. 第一行标题必须是: type(scope): description （严格限制在 50 个字符以内）
2. 必须包含空行分隔的 Body 部分，详细解释修改的原因和具体内容。Body 的每一行文本必须在 72 个字符处强制换行（Hard wrap）。
3. 如果有相关的 Breaking Changes 或者 Issue 关闭，请在 Footer 提供。

$lang_prompt

类型可选: feat, fix, docs, style, refactor, test, chore
只返回完整的提交信息本身（包含首行和 Body/Footer），不加任何啰嗦的解释和外层的 Markdown 代码块 (```)。

<diff>
$diff
</diff>"

        # 调用检测到的 AI 工具生成内容
        set -l msg_tmpfile (mktemp)
        eval $ai_cmd \"\$prompt_text\" > $msg_tmpfile
        
        # 捕捉在 AI 生成过程中被 Ctrl+C 中断的情况
        if test $status -ne 0
            rm -f $msg_tmpfile
            echo ""
            echo "❌ 操作已中断"
            return 1
        end
        
        # 清理响应
        sed -i '' -e '/^```\(commit\|text\)/d' -e '/^```$/d' $msg_tmpfile
        
        echo ""
        echo "📝 建议提交信息:"
        awk '{print "   " $0}' $msg_tmpfile
        echo ""
        
        set -l toggle_prompt "t(翻译为中文)"
        if test "$is_chinese" -eq 1
            set toggle_prompt "t(翻译为英文)"
        end
        read -P "确认提交? [Y/n/e(编辑)/r(重写)/$toggle_prompt] " confirm
        
        # 捕捉 Ctrl+C (read 会返回非零状态码)
        if test $status -ne 0
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
                set -l editor "hx"
                if set -q EDITOR
                    set editor $EDITOR
                end
                eval $editor $msg_tmpfile
                
                set -l edited (cat $msg_tmpfile | string collect)
                if test -n "$edited"
                    git commit -m "$edited" -e
                else
                    echo "❌ 提交信息为空，已取消"
                end
                rm $msg_tmpfile
                set loop_active false
                
            case R r
                rm $msg_tmpfile
                echo "🔄 正在重新生成..."
                echo "🤖 $ai_name 正在分析更改..."
                
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
                echo "🤖 $ai_name 正在分析更改..."
                
            case '*'
                rm $msg_tmpfile
                echo "❌ 已取消"
                set loop_active false
        end
    end
end
