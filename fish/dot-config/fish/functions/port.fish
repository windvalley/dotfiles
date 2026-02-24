function port -d "查看本地监听的端口进程"
    # 用法: port 8080
    echo "🔍 TCP/UDP 监听状态 (若无权限请 sudo port $argv[1]):"
    lsof -nP -iTCP:$argv[1] -sTCP:LISTEN
    lsof -nP -iUDP:$argv[1]
end
