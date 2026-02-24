function ch -d "查询 cheat.sh 快速获取命令帮助"
    # 用法: ch <命令>
    # 示例: ch tar, ch curl
    curl cheat.sh/$argv[1]
end
