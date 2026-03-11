function p -d "预览和选择 macOS 系统剪贴板历史记录 (依赖 Maccy 和 fzf)"
    # -- 帮助信息 --
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "用法: p [关键词...]"
        echo ""
        echo "通过 fzf 交互式预览和选择 macOS 剪贴板历史记录。"
        echo "选中后自动将对应内容（文本或图片）重新拷贝到系统剪贴板。"
        echo ""
        echo "参数:"
        echo "  关键词   可选，用于精确过滤剪贴板条目。若匹配唯一结果则直接拷贝，跳过交互界面"
        echo ""
        echo "示例:"
        echo "  p                  交互式浏览全部剪贴板历史"
        echo "  p dotfiles         过滤含 'dotfiles' 的条目"
        echo "  p hello world      精确匹配含 'hello world' 的条目"
        echo ""
        echo "依赖:"
        echo "  Maccy   - macOS 剪贴板历史管理工具 (brew install --cask maccy)"
        echo "  fzf     - 模糊搜索工具 (brew install fzf)"
        echo "  chafa   - 终端图片渲染 (brew install chafa)，可选但推荐"
        echo "  sqlite3 - macOS 自带"
        return 0
    end

    set -l maccy_db "$HOME/Library/Containers/org.p0deje.Maccy/Data/Library/Application Support/Maccy/Storage.sqlite"

    if not test -f "$maccy_db"
        set_color red; echo "未找到 Maccy 数据库，请确保已安装并在后台运行 Maccy。"; set_color normal
        return 1
    end

    # 提取最新的 100 条记录：ID 和 Title
    # COALESCE 兜底：纯图片等无标题条目显示为 "[图片]"，避免 fzf 出现空行
    # replace() 去掉换行符以保持 fzf 列表规整
    set -l query "SELECT Z_PK, replace(replace(COALESCE(ZTITLE, '[图片]'), char(10), ' '), char(13), '') FROM ZHISTORYITEM ORDER BY Z_PK DESC LIMIT 100;"

    # 构建 fzf 搜索关键词
    # 为传入的参数加上单引号前缀，告诉 fzf 进行"精确包含匹配"而不是"模糊拆字匹配"
    set -l fzf_query ""
    if test -n "$argv"
        set fzf_query "'$argv"
    end

    # 获取用户选中行，如果用户取消则返回
    # --select-1: 若过滤后仅剩唯一结果，则自动选中并跳过交互界面
    set -l selected (sqlite3 -separator '|' "$maccy_db" "$query" \
        | fzf \
            --with-nth 2.. \
            -d '|' \
            --query="$fzf_query" \
            --select-1 \
            --layout=reverse \
            --border \
            --preview 'maccy-preview {1}' \
            --preview-window 'right:60%:wrap' \
            --prompt '📋 Clipboard> ' \
            --header '⏎ 回车拷贝到剪贴板' \
            --height 80%)

    if test -z "$selected"
        printf "\e_Ga=d;\e\\"
        commandline -f repaint
        return 0
    end

    # 提取 ID (第一列)
    set -l item_id (string split -m 1 "|" "$selected")[1]

    # 防御性校验：ID 必须是正整数，防止 SQL 注入
    if not string match -qr '^\d+$' "$item_id"
        set_color red; echo "无效的记录 ID: '$item_id'"; set_color normal
        return 1
    end

    printf "\e_Ga=d;\e\\"

    # 根据 ID 提取最佳数据格式重新复制
    set -l best_type (sqlite3 "$maccy_db" "
SELECT ZTYPE
FROM ZHISTORYITEMCONTENT
WHERE ZITEM = $item_id AND (ZTYPE = 'public.png' OR ZTYPE = 'public.tiff' OR ZTYPE = 'public.utf8-plain-text')
ORDER BY
  CASE ZTYPE
    WHEN 'public.png' THEN 1
    WHEN 'public.tiff' THEN 2
    WHEN 'public.utf8-plain-text' THEN 3
    ELSE 4
  END
LIMIT 1;
")

    if test "$best_type" = "public.png" -o "$best_type" = "public.tiff"
        set -l tmp_img "/tmp/maccy_copy_tmp_$item_id.tiff"
        sqlite3 "$maccy_db" "SELECT writefile('$tmp_img', ZVALUE) FROM ZHISTORYITEMCONTENT WHERE ZITEM = $item_id AND ZTYPE = '$best_type' LIMIT 1;" >/dev/null 2>&1
        if test -f "$tmp_img"
            osascript -e "set the clipboard to (read (POSIX file \"$tmp_img\") as TIFF picture)"
            rm -f "$tmp_img"
            set_color green; echo "📸 已将图片重新拷贝到系统剪贴板！"; set_color normal
        else
            set_color red; echo "无法提取图片到剪贴板。"; set_color normal
        end
    else if test "$best_type" = "public.utf8-plain-text"
        sqlite3 "$maccy_db" "SELECT ZVALUE FROM ZHISTORYITEMCONTENT WHERE ZITEM = $item_id AND ZTYPE = 'public.utf8-plain-text' LIMIT 1;" | pbcopy
        set_color green; echo "📝 已将文本重新拷贝到系统剪贴板！"; set_color normal
    else
        set_color yellow; echo "不受支持的格式或内容为空。"; set_color normal
    end

    commandline -f repaint
end
