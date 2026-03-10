function ports -d "查看所有本地监听的 TCP 端口"
    if test (count $argv) -gt 0; and contains -- $argv[1] -h --help
        echo "List all local listening TCP ports"
        echo ""
        echo "Usage:"
        echo "  ports                 List all TCP ports in LISTEN state"
        echo "  ports -h | --help     Show this help message"
        return 0
    end
    echo "🔍 本机正在监听的 TCP 端口:"
    lsof -nP -iTCP -sTCP:LISTEN
end
