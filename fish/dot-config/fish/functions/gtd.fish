function gtd -d "同时删除本地和远端的 Git Tag"
    # 用法: gtd v0.8.0
    if test -z "$argv[1]"
        echo "用法: gtd <tag名>"
        return 1
    end

    echo "🗑️ 删除本地 tag: $argv[1]"
    git tag -d $argv[1]

    echo "🗑️ 删除远端 tag: $argv[1]"
    git push origin --delete $argv[1]
end
