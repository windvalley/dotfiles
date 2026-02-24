function gitignore -d "拉取 GitHub 官方的 gitignore 模板并输出"
    # 用法: gitignore Node
    if test -z "$argv[1]"
        echo "❌ 请提供语言名称 (例如: Python, Node, Go, Rust)" >&2
        return 1
    end
    
    # 将首字母大写以匹配 GitHub API 要求的格式
    set -l lang_first (string sub -s 1 -l 1 "$argv[1]" | string upper)
    set -l lang_rest (string sub -s 2 "$argv[1]" | string lower)
    set -l lang "$lang_first$lang_rest"
    
    set -l url "https://raw.githubusercontent.com/github/gitignore/master/$lang.gitignore"
    
    # 检查URL是否有效 (HTTP 200) 后直接输出，避免存入变量导致换行符丢失
    if curl -sI -f "$url" >/dev/null
        curl -sL "$url"
    else
        echo "❌ 拉取失败，请检查名称是否正确（常见: Python, Node, Go, Rust, C++）" >&2
    end
end
