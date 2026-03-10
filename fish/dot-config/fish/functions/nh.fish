function nh -d "后台运行命令 (nohup + 丢弃输出)"
    if test (count $argv) -eq 0; or contains -- $argv[1] -h --help
        echo "Run command in background (nohup + silent)"
        echo "Usage:   nh <command> [arguments...]"
        echo "Example: nh wget https://example.com/file.zip"
        return 0
    end
    nohup $argv &>/dev/null &
end
