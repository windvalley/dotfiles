function proxy -d "开启终端代理 (HTTP/HTTPS/SOCKS5)"
    if test (count $argv) -gt 0; and contains -- $argv[1] -h --help
        echo "Enable terminal proxy (HTTP/HTTPS/SOCKS5)"
        echo ""
        echo "Usage:"
        echo "  proxy                 Enable proxy for the current session (127.0.0.1:7890)"
        echo "  proxy -h | --help     Show this help message"
        return 0
    end
    set -gx http_proxy "http://127.0.0.1:7890"
    set -gx https_proxy "http://127.0.0.1:7890"
    set -gx all_proxy "socks5://127.0.0.1:7890"
    echo "🌍 终端代理已开启 (127.0.0.1:7890)"
end
