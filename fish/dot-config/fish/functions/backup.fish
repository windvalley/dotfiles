function backup -d "为文件或目录创建带时间戳的备份"
    # 用法: backup install.sh
    if test -z "$argv[1]"
        echo "用法: backup <文件或目录>"
        return 1
    end
    
    if not test -e "$argv[1]"
        echo "❌ 找不到: $argv[1]"
        return 1
    end
    
    set -l timestamp (date +%Y%m%d_%H%M%S)
    set -l backup_name "$argv[1].$timestamp.bak"
    
    cp -R "$argv[1]" "$backup_name"
    echo "✅ 已完成安全备份 -> $backup_name"
end
