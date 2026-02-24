function copy -d "将输入流或文件内容复制到 macOS 剪贴板"
    # 用法 1: copy ./hello.txt  (复制文件内容)
    # 用法 2: ls -al | copy     (复制命令输出)
    
    # isatty 命令检查标准输入是否连接到终端设备。
    # 如果没连接终端（说明前面有管道 | 传数据过来），或者重定向了输入流：
    if not isatty stdin
        # 处理管道流，像 `cat file | copy` 或 `ls | copy`
        pbcopy
        echo "✅ 标准输出已捕获并复制到系统剪贴板"
    else
        # 处理文件参数，像 `copy file.txt`
        if test -f "$argv[1]"
            cat "$argv[1]" | pbcopy
            echo "✅ 文件内容已复制到系统剪贴板 -> $argv[1]"
        else
            echo "❌ 用法错误"
            echo "用法 1: 命令 | copy   (复制输出结果)"
            echo "用法 2: copy <文件>   (复制文件内容)"
        end
    end
end
