function fish_user_key_bindings
    # 官方推荐混合模式：emacs 绑定 → insert 模式，vi 叠加覆盖
    # Ctrl-a/Ctrl-e/Ctrl-f/Ctrl-p 等在 insert 模式下全部可用
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
    # Ctrl-e: normal 模式用 $EDITOR (hx) 编辑命令行
    # insert 模式保留 emacs 的 end-of-line
    bind \ce edit_command_buffer
end
