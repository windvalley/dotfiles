function ports -d "查看所有本地监听的 TCP 端口"
    # 用法: ports
    echo "🔍 本机正在监听的 TCP 端口:"
    lsof -nP -iTCP -sTCP:LISTEN
end
