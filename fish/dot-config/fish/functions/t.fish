function t -d "按输入类型执行翻译或英文释义"
    if test (count $argv) -eq 0
        echo "用法: t <英文单词|中文单词|英文短文|中文短文>"
        return 1
    end

    # 将 t 后的所有参数重新拼成一段完整文本，避免只处理第一个词。
    set -l input_text (string join " " -- $argv | string trim)
    if test -z "$input_text"
        echo "❌ 请输入要处理的内容"
        return 1
    end

    set -l prompt_text ""
    set -l mode ""

    # 优先识别"纯中文短词"，用于给出多个英文对应词及词典信息。
    set -l is_chinese_word 0
    if string match -rq '^\p{Han}+$' -- "$input_text"
        set -l han_length (string length -- "$input_text")
        if test "$han_length" -le 4
            set is_chinese_word 1
        end
    end

    if test "$is_chinese_word" -eq 1
        set mode zh_word
    else if string match -rq '\p{Han}' -- "$input_text"
        set mode zh_to_en
        set prompt_text "你是一个专业翻译助手。用户会提供中文内容，请将其自然、准确地翻译为英文。

输出要求：
1. 只输出最终英文译文本身。
2. 不要输出标题、解释、编号、引号、Markdown 代码块。"
    else if string match -rq '^\p{L}[\p{L}\x27-]*$' -- "$input_text"
        set mode word
        set prompt_text "你是一个英汉词典助手。用户会提供一个英文单词，请返回以下四行内容：
美式音标: /.../
英式音标: /.../
English: ...
中文: ...

输出要求：
1. 使用常见且自然的美式音标。
2. 使用常见且自然的英式音标。
3. 英文解释要简洁、地道，适合词典式释义。
4. 中文解释要准确、简洁。
5. 不要输出示例句、编号、Markdown 代码块或其他额外说明。"
    else
        set mode en_to_zh
        set prompt_text "你是一个专业翻译助手。用户会提供一段英文内容，请将其自然、准确地翻译为简体中文。

输出要求：
1. 只输出最终中文译文本身。
2. 不要输出标题、解释、编号、引号、Markdown 代码块。"
    end

    # ────────────────────────────────────────────────────────────
    # 中文单词模式：拆成两步，先拿英文词列表，再逐个查词典。
    # ────────────────────────────────────────────────────────────
    if test "$mode" = zh_word
        set -l list_prompt "你是一个专业双语词典助手。用户会提供一个中文单词，请列出所有常见、自然、语义贴切的英文对应词。

输出要求：
1. 只输出英文单词，用逗号分隔，例如：devil, demon, fiend
2. 至少给出 2 个候选词，最多 6 个，按常用度排序。
3. 不同候选词不要重复，尽量覆盖不同但贴切的常见表达（口语、书面、文学等不同语域）。
4. 只输出逗号分隔的单词列表本身，不要输出编号、解释、音标、Markdown 代码块或任何其他文字。"

        set -l list_output (_ai_complete --prompt "$list_prompt" --input "$input_text" | string collect)
        set -l ai_exit_status $pipestatus[1]
        if test $ai_exit_status -ne 0 -o -z "$list_output"
            echo "❌ 获取候选词列表失败"
            return 1
        end

        set list_output (_ai_strip_think "$list_output" | string collect)
        set list_output (string replace -ar '(?m)^```[[:alnum:]_-]*\s*$' '' -- "$list_output" | string collect)
        set list_output (string replace -ar '(?m)^```\s*$' '' -- "$list_output" | string collect)
        set list_output (string trim -- "$list_output" | string collect)

        # 解析逗号分隔列表，清洗每个词
        set -l candidate_words
        set -l seen_normalized
        for raw_word in (string split "," -- "$list_output")
            set -l cleaned (string trim -- "$raw_word" | string replace -ar '[^a-zA-Z\x27 -]' '')
            set -l normalized (string lower -- "$cleaned")
            if test -n "$normalized"; and not contains -- "$normalized" $seen_normalized
                set -a candidate_words "$cleaned"
                set -a seen_normalized "$normalized"
            end
        end

        if test (count $candidate_words) -eq 0
            echo "❌ 未解析到有效的英文候选词"
            return 1
        end

        set -l color_title ""
        set -l color_label ""
        set -l color_value ""
        set -l color_accent ""
        set -l color_note ""
        set -l color_divider ""
        set -l color_reset ""

        if isatty stdout
            set color_title (set_color --bold brcyan)
            set color_label (set_color bryellow)
            set color_value (set_color white)
            set color_accent (set_color brgreen)
            set color_note (set_color brmagenta)
            set color_divider (set_color brblack)
            set color_reset (set_color normal)
        end

        printf "%s%s%s\n" "$color_title" "词典结果 · 中文词 -> English Words" "$color_reset"
        printf "%s%s%s\n" "$color_divider" "────────────────────" "$color_reset"
        printf "%s%s%s %s%s%s\n" "$color_label" "中文词" "$color_reset" "$color_value" "$input_text" "$color_reset"

        set -l dict_prompt "你是一个英汉词典助手。用户会提供一个英文单词，请返回以下四行内容：
美式音标: /.../
英式音标: /.../
English: ...
中文: ...

输出要求：
1. 使用常见且自然的美式音标。
2. 使用常见且自然的英式音标。
3. 英文解释要简洁、地道，适合词典式释义。
4. 中文解释要准确、简洁。
5. 不要输出示例句、编号、Markdown 代码块或其他额外说明。"

        set -l item_index 0
        for en_word in $candidate_words
            set -l dict_output (_ai_complete --prompt "$dict_prompt" --input "$en_word" | string collect)
            set -l ai_exit_status $pipestatus[1]
            if test $ai_exit_status -ne 0 -o -z "$dict_output"
                continue
            end

            set dict_output (_ai_strip_think "$dict_output" | string collect)
            set dict_output (string replace -ar '(?m)^```[[:alnum:]_-]*\s*$' '' -- "$dict_output" | string collect)
            set dict_output (string replace -ar '(?m)^```\s*$' '' -- "$dict_output" | string collect)
            set dict_output (string replace -ar '\x1b\[[0-9;?]*[ -/]*[@-~]' '' -- "$dict_output" | string collect)
            set dict_output (string replace -ar '[\x00-\x08\x0b-\x1f\x7f]' '' -- "$dict_output" | string collect)
            set dict_output (string trim -- "$dict_output" | string collect)

            set -l us_ipa ""
            set -l uk_ipa ""
            set -l en_exp ""
            set -l zh_exp ""
            set -l current_field ""

            for line in (string split \n -- "$dict_output")
                set -l trimmed_line (string trim -- "$line")
                if string match -rq '^(美式音标|美音|US|AmE)\s*[:：]' -- "$trimmed_line"
                    set current_field us_ipa
                    set us_ipa (string replace -r '^(美式音标|美音|US|AmE)\s*[:：]\s*' '' -- "$trimmed_line")
                else if string match -rq '^(英式音标|英音|UK|BrE)\s*[:：]' -- "$trimmed_line"
                    set current_field uk_ipa
                    set uk_ipa (string replace -r '^(英式音标|英音|UK|BrE)\s*[:：]\s*' '' -- "$trimmed_line")
                else if string match -rq '^(English|英文|英文解释|英文释义)\s*[:：]' -- "$trimmed_line"
                    set current_field en_exp
                    set en_exp (string replace -r '^(English|英文|英文解释|英文释义)\s*[:：]\s*' '' -- "$trimmed_line")
                else if string match -rq '^(中文|中文解释|中文释义)\s*[:：]' -- "$trimmed_line"
                    set current_field zh_exp
                    set zh_exp (string replace -r '^(中文|中文解释|中文释义)\s*[:：]\s*' '' -- "$trimmed_line")
                else if test -n "$trimmed_line"
                    switch "$current_field"
                        case en_exp
                            set en_exp (string join \n -- "$en_exp" "$trimmed_line" | string collect)
                        case zh_exp
                            set zh_exp (string join \n -- "$zh_exp" "$trimmed_line" | string collect)
                    end
                end
            end

            set item_index (math "$item_index + 1")
            echo ""
            printf "%s%s%s %s%s%s\n" "$color_accent" "候选" "$color_reset" "$color_value" "$item_index. $en_word" "$color_reset"
            if test -n "$us_ipa"
                printf "%s%s%s %s%s%s\n" "$color_label" "美式音标" "$color_reset" "$color_value" "$us_ipa" "$color_reset"
            end
            if test -n "$uk_ipa"
                printf "%s%s%s %s%s%s\n" "$color_label" "英式音标" "$color_reset" "$color_value" "$uk_ipa" "$color_reset"
            end
            if test -n "$en_exp"
                echo ""
                printf "%s%s%s\n" "$color_note" "English" "$color_reset"
                printf "%s\n" "$en_exp"
            end
            if test -n "$zh_exp"
                echo ""
                printf "%s%s%s\n" "$color_note" "中文" "$color_reset"
                printf "%s\n" "$zh_exp"
            end

            if test -z "$us_ipa$uk_ipa$en_exp$zh_exp"
                echo ""
                printf "%s\n" "$dict_output"
            end
        end

        if test "$item_index" -eq 0
            echo ""
            echo "❌ 未能获取任何候选词的词典信息"
        end
        return 0
    end

    # ────────────────────────────────────────────────────────────
    # 其他模式：中译英、英译中、英文单词词典
    # ────────────────────────────────────────────────────────────
    set -l output_text (_ai_complete --prompt "$prompt_text" --input "$input_text" | string collect)
    set -l ai_exit_status $pipestatus[1]
    if test $ai_exit_status -ne 0
        echo "❌ 处理失败，请检查本地 q / aichat 配置或模型状态"
        return 1
    end

    set output_text (_ai_strip_think "$output_text" | string collect)
    set output_text (string replace -ar '(?m)^```[[:alnum:]_-]*\s*$' '' -- "$output_text" | string collect)
    set output_text (string replace -ar '(?m)^```\s*$' '' -- "$output_text" | string collect)
    set output_text (string replace -ar '\x1b\[[0-9;?]*[ -/]*[@-~]' '' -- "$output_text" | string collect)
    set output_text (string replace -ar '[\x00-\x08\x0b-\x1f\x7f]' '' -- "$output_text" | string collect)
    set output_text (string trim -- "$output_text" | string collect)

    if test -z "$output_text"
        echo "❌ 未获取到有效结果"
        return 1
    end

    set -l color_title ""
    set -l color_label ""
    set -l color_value ""
    set -l color_accent ""
    set -l color_note ""
    set -l color_divider ""
    set -l color_reset ""

    if isatty stdout
        set color_title (set_color --bold brcyan)
        set color_label (set_color bryellow)
        set color_value (set_color white)
        set color_accent (set_color brgreen)
        set color_note (set_color brmagenta)
        set color_divider (set_color brblack)
        set color_reset (set_color normal)
    end

    switch "$mode"
        case zh_to_en
            printf "%s%s%s\n" "$color_title" "译文结果 · 中文 -> English" "$color_reset"
            printf "%s%s%s\n" "$color_divider" "────────────────────" "$color_reset"
            printf "%s%s%s %s%s%s\n" "$color_label" "原文" "$color_reset" "$color_value" "$input_text" "$color_reset"
            echo ""
            printf "%s%s%s\n" "$color_accent" "English" "$color_reset"
            printf "%s\n" "$output_text"

        case en_to_zh
            printf "%s%s%s\n" "$color_title" "译文结果 · English -> 中文" "$color_reset"
            printf "%s%s%s\n" "$color_divider" "────────────────────" "$color_reset"
            printf "%s%s%s %s%s%s\n" "$color_label" "原文" "$color_reset" "$color_value" "$input_text" "$color_reset"
            echo ""
            printf "%s%s%s\n" "$color_accent" "中文" "$color_reset"
            printf "%s\n" "$output_text"

        case word
            set -l us_ipa ""
            set -l uk_ipa ""
            set -l en_exp ""
            set -l zh_exp ""
            set -l current_field ""
            set -l unmatched_text ""

            for line in (string split \n -- "$output_text")
                set -l trimmed_line (string trim -- "$line")

                if string match -rq '^(美式音标|美音|US|AmE)\s*[:：]' -- "$trimmed_line"
                    set current_field us_ipa
                    set us_ipa (string replace -r '^(美式音标|美音|US|AmE)\s*[:：]\s*' '' -- "$trimmed_line")
                else if string match -rq '^(英式音标|英音|UK|BrE)\s*[:：]' -- "$trimmed_line"
                    set current_field uk_ipa
                    set uk_ipa (string replace -r '^(英式音标|英音|UK|BrE)\s*[:：]\s*' '' -- "$trimmed_line")
                else if string match -rq '^(English|英文|英文解释|英文释义)\s*[:：]' -- "$trimmed_line"
                    set current_field en_exp
                    set en_exp (string replace -r '^(English|英文|英文解释|英文释义)\s*[:：]\s*' '' -- "$trimmed_line")
                else if string match -rq '^(中文|中文解释|中文释义)\s*[:：]' -- "$trimmed_line"
                    set current_field zh_exp
                    set zh_exp (string replace -r '^(中文|中文解释|中文释义)\s*[:：]\s*' '' -- "$trimmed_line")
                else if test -n "$trimmed_line"
                    switch "$current_field"
                        case us_ipa
                            set us_ipa (string join \n -- "$us_ipa" "$trimmed_line" | string collect)
                        case uk_ipa
                            set uk_ipa (string join \n -- "$uk_ipa" "$trimmed_line" | string collect)
                        case en_exp
                            set en_exp (string join \n -- "$en_exp" "$trimmed_line" | string collect)
                        case zh_exp
                            set zh_exp (string join \n -- "$zh_exp" "$trimmed_line" | string collect)
                        case '*'
                            if test -n "$unmatched_text"
                                set unmatched_text (string join \n -- "$unmatched_text" "$trimmed_line" | string collect)
                            else
                                set unmatched_text "$trimmed_line"
                            end
                    end
                end
            end

            printf "%s%s%s\n" "$color_title" "词典结果 · English Word" "$color_reset"
            printf "%s%s%s\n" "$color_divider" "────────────────────" "$color_reset"
            printf "%s%s%s %s%s%s\n" "$color_label" "单词" "$color_reset" "$color_value" "$input_text" "$color_reset"
            echo ""

            if test -n "$us_ipa"
                printf "%s%s%s %s%s%s\n" "$color_accent" "美式音标" "$color_reset" "$color_value" "$us_ipa" "$color_reset"
            end
            if test -n "$uk_ipa"
                printf "%s%s%s %s%s%s\n" "$color_accent" "英式音标" "$color_reset" "$color_value" "$uk_ipa" "$color_reset"
            end
            if test -n "$en_exp"
                echo ""
                printf "%s%s%s\n" "$color_note" "English" "$color_reset"
                printf "%s\n" "$en_exp"
            end
            if test -n "$zh_exp"
                echo ""
                printf "%s%s%s\n" "$color_note" "中文" "$color_reset"
                printf "%s\n" "$zh_exp"
            end

            if test -n "$unmatched_text" -o -z "$us_ipa" -o -z "$uk_ipa" -o -z "$en_exp" -o -z "$zh_exp"
                echo ""
                printf "%s%s%s\n" "$color_note" "原始结果" "$color_reset"
                printf "%s\n" "$output_text"
            end

        case '*'
            printf "%s\n" "$output_text"
    end
end
