function _ai_strip_think -d "移除 AI 输出中的 <think>...</think> 块"
    set -l input_text ""
    if test (count $argv) -gt 0
        set input_text "$argv[1]"
    else
        set input_text (cat | string collect)
    end

    set input_text (string replace -ar '(?s)<think>.*?</think>\s*' '' -- "$input_text" | string collect)
    printf '%s' "$input_text"
end
