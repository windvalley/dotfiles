function port -d "查看本地监听的端口进程"
    if test (count $argv) -eq 0
        echo "Usage: port <port-number>"
        return 1
    end

    if not string match -qr '^[0-9]+$' -- $argv[1]
        echo "❌ Port number must be numeric"
        echo "Usage: port <port-number>"
        return 1
    end

    echo "🔍 TCP/UDP listening status (use sudo port $argv[1] if permission is denied):"
    lsof -nP -iTCP:$argv[1] -sTCP:LISTEN
    lsof -nP -iUDP:$argv[1]
end
