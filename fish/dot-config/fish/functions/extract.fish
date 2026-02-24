function extract -d "万能解压工具"
    # 用法: extract <file>
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2' '*.tbz2' '*.tbz'
                tar xjf $argv[1]
            case '*.tar.gz' '*.tgz'
                tar xzf $argv[1]
            case '*.tar.xz' '*.txz'
                tar xJf $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "❌ 不支持的格式: $argv[1]"
        end
    else
        echo "❌ 文件不存在: $argv[1]"
    end
end
