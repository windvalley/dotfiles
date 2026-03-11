function __confirm_exit -d "双击 Ctrl+D 确认退出，防止误关终端或面板"
    # 如果命令行不为空，则执行默认的删除字符操作（Ctrl-D 的标准行为之一）
    set -l cmd (commandline)
    if test -n "$cmd"
        commandline -f delete-char
        return
    end

    # === 双击确认退出逻辑 ===
    # 第一次按 Ctrl+D: 记录时间戳并显示警告
    # 第二次按 Ctrl+D (500ms 内): 真正退出
    # NOTE: macOS 自带 date 不支持毫秒，借助 perl (macOS 内置) 获取毫秒级整数时间戳
    set -l now (perl -MTime::HiRes -e 'printf "%d", Time::HiRes::time() * 1000')
    set -l threshold 500  # 两次按键的间隔阈值（毫秒）

    if set -q __confirm_exit_ts
        set -l elapsed (math "$now - $__confirm_exit_ts")
        if test "$elapsed" -le "$threshold"
            # 在阈值内再次按了 Ctrl+D，确认退出
            set -e __confirm_exit_ts
            exit
        end
    end

    # 记录本次按键时间戳
    set -g __confirm_exit_ts $now

    # 显示提示：再按一次 Ctrl+D 即可退出
    echo
    set_color yellow
    echo "󰈆 Press Ctrl+D again to exit"
    set_color normal
    commandline -f repaint
end
