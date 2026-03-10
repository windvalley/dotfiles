function unproxy -d "关闭终端代理"
    if test (count $argv) -gt 0; and contains -- $argv[1] -h --help
        echo "Disable terminal proxy"
        echo ""
        echo "Usage:"
        echo "  unproxy               Remove proxy environment variables"
        echo "  unproxy -h | --help   Show this help message"
        return 0
    end
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    echo "🚫 终端代理已关闭"
end
