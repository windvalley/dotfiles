function __copy_commandline_to_clipboard -d "复制当前命令行到 macOS 系统剪贴板"
    set -l current_command (commandline -b)

    printf "%s" "$current_command" | pbcopy
    commandline -f repaint
end
