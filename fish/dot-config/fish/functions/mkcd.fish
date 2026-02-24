function mkcd -d "创建目录并进入"
    # 用法: mkcd <dir>
    mkdir -p $argv[1]; and cd $argv[1]
end
