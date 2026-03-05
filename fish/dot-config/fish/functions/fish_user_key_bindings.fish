function fish_user_key_bindings
    # 官方推荐混合模式：emacs 绑定 → insert 模式，vi 叠加覆盖
    # Ctrl-a/Ctrl-e/Ctrl-f/Ctrl-p 等在 insert 模式下全部可用
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
    # Ctrl-e: normal 模式用 $EDITOR (hx) 编辑命令行
    # insert 模式保留 emacs 的 end-of-line
    bind \ce edit_command_buffer
    # aichat 终端 AI 客户端 shell 集成 (https://github.com/sigoden/aichat)
    # 绑定 Alt+e (\ee) 自动调出 AI 辅助生成命令
    function _aichat_fish
        # 捕获并强制使用当前光标位置及缓冲区内容
        set -l _old (commandline)
        if test -n "$_old"
            # 给出视觉反馈，表明已在执行操作
            echo -n "⌛ "
            commandline -f repaint
            # 使用 -e 执行当前缓冲区的自然语言指令
            commandline (aichat -e "$_old")
        end
    end
    bind \ee _aichat_fish
end
