function fish_user_key_bindings
    # 官方推荐混合模式：emacs 绑定 → insert 模式，vi 叠加覆盖
    # Ctrl-a/Ctrl-e/Ctrl-f/Ctrl-p 等在 insert 模式下全部可用
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
    # Ctrl-e: normal 模式用 $EDITOR (hx) 编辑命令行
    # insert 模式保留 emacs 的 end-of-line
    bind \ce edit_command_buffer
    # aichat 终端 AI 客户端 shell 集成 (https://github.com/sigoden/aichat)
    # 绑定 Ctrl+y (\cy) 自动调出 AI 辅助生成命令（逻辑见 _aichat_fish 函数）
    # 约定：描述必须以 # 开头（否则一律按“命令 -> 解释”处理）
    # 在 vi 插入模式和默认模式都绑定，避免仅在单一 keymap 生效
    bind -M insert \cy _aichat_fish
    bind -M default \cy _aichat_fish
end
