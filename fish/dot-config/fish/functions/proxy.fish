function proxy -d "开启终端代理 (HTTP/HTTPS/SOCKS5)"
    # 根据你使用的代理客户端修改端口号，Clash 默认 7890，V2Ray 默认 10809
    set -gx http_proxy "http://127.0.0.1:7890"
    set -gx https_proxy "http://127.0.0.1:7890"
    set -gx all_proxy "socks5://127.0.0.1:7890"
    echo "🌍 终端代理已开启 (127.0.0.1:7890)"
end
