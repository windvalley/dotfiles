function b -d "使用 fzf 搜索文件并用 bat 预览"
    # 限制 fzf 查找文件类型、隐藏 git 忽略和内置缓存目录
    set -l fzf_query ""
    if test -n "$argv"
        # 为传入的参数加上单引号前缀，告诉 fzf 进行"精确包含匹配"而不是"模糊拆字匹配"
        set fzf_query "'$argv"
    end

    set -l target (fd --type f --hidden --exclude .git --exclude node_modules --exclude target \
        | fzf --query="$fzf_query" \
              --select-1 \
              --prompt="🦇 View with bat > " \
              --preview="bat --color=always --style=numbers --line-range=:500 {}" \
              --preview-window="right:60%" \
              --height=80% \
              --layout=reverse \
              --border)

    # 如果选中了文件，用 bat 查看
    if test -n "$target"
        bat --style=full --paging=always $target
    end
end
