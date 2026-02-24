function unproxy -d "关闭终端代理"
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    echo "🚫 终端代理已关闭"
end
