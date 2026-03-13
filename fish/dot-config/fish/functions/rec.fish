function rec -d "极简终端录屏与回放 (基于 asciinema)"
    if test (count $argv) -gt 0; and contains -- $argv[1] -h --help help
        echo "Run and playback terminal sessions (based on asciinema)"
        echo ""
        echo "Usage:"
        echo "  rec [filename]        Record a new session to [filename].cast (default: my_demo.cast)"
        echo "  rec play [filename]   Playback the specified or default session"
        echo "  rec upload [filename] Upload the session to share via web"
        echo "  rec help | -h         Show this help message"
        return 0
    end

    if not command -q asciinema
        echo "❌ 未检测到 asciinema，请先运行 'mise install' 安装当前仓库声明的工具链。"
        return 1
    end
    
    set -l act "$argv[1]"
    # 如果第一个参数是 play 或 upload，则真正的名字在第二个参数；否则直接是第一个参数
    if contains "$act" play upload
        set -l name (test -n "$argv[2]"; and echo "$argv[2]"; or echo "my_demo")
        # 如果用户手滑加了 .cast 后缀，自动去重
        set -l filename (string replace -r '\.cast$' '' "$name").cast
        
        if not test -f "$filename"
            echo "❌ 找不到录像文件: $filename"
            return 1
        end

        if test "$act" = "play"
            echo "▶️ 开始回放: $filename"
            asciinema play "$filename"
            return
        else if test "$act" = "upload"
            echo "☁️ 准备上传: $filename"
            asciinema upload "$filename"
            return
        end
    end

    # =================
    # 录制逻辑
    # =================
    set -l name (test -n "$argv[1]"; and echo "$argv[1]"; or echo "my_demo")
    set -l filename (string replace -r '\.cast$' '' "$name").cast
    
    echo "========================================"
    echo "🎬 即将开始安静录制 -> $filename"
    echo "🛑 录制结束后，按 【Ctrl + D】 (或键入 exit) 即可停止退出并保存。"
    echo "========================================"
    sleep 1.5
    asciinema rec "$filename" -q
    
    echo ""
    echo "✅ 录制完毕！已保存为: $filename"
    echo "▶️ 本地回放: rec play "(string replace -r '\.cast$' '' "$filename")
    echo "🌍 网页分享: rec upload "(string replace -r '\.cast$' '' "$filename")
end
