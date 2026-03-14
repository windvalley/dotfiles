function _ai_complete_to_file -d "将 AI 输出安全写入目标文件"
    if test (count $argv) -lt 1
        echo "❌ _ai_complete_to_file 缺少输出文件路径" >&2
        return 2
    end

    set -l output_file "$argv[1]"
    set -l remaining_args $argv[2..-1]
    set -l temp_file (mktemp)

    if _ai_complete $remaining_args >"$temp_file"
        if test -s "$temp_file"
            mv "$temp_file" "$output_file"
            return 0
        end
        rm -f "$temp_file"
        echo "❌ AI 输出为空，未写入目标文件" >&2
        return 1
    end

    set -l cmd_status $status
    rm -f "$temp_file"
    return $cmd_status
end
