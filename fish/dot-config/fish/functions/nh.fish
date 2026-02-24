function nh -d "后台运行命令 (nohup + 丢弃输出)"
    # 用法: nh <命令> [参数...]
    # 示例: nh scrcpy -w -S
    nohup $argv &>/dev/null &
end
