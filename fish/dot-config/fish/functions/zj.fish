#!/bin/bash
# shellcheck disable=SC2148
# Fish function wrapper - Shellcheck should ignore since it's fish script but we just disable header check

function zj -d "项目感知型的 Zellij 启动器"
    argparse 'h/help' -- $argv
    or return

    if set -q _flag_help
        echo "用法: zj [选项]"
        echo ""
        echo "项目感知型的 Zellij 启动器。根据当前目录的内容自动选择合适的布局启动 Zellij 会话。"
        echo ""
        echo "选项:"
        echo "  -h, --help    显示此帮助信息并退出"
        echo ""
        echo "功能:"
        echo "  1. 如果已在 Zellij 会话中，通过新 Ghostty 窗口创建/连接会话。"
        echo "  2. 如果已存在同名会话，自动连接。"
        echo "  3. 自动检测全栈项目 (包含前后端目录)。"
        echo "  4. 自动检测单体项目 (Node, Go, Rust, Python, C++, etc.)。"
        echo ""
        echo "提示: 切换已有会话请使用 Ctrl+o w 打开会话管理器。"
        return 0
    end

    # 如果已经在一个 Zellij 会话中，通过 Ghostty AppleScript 在新窗口中创建/连接会话
    # 新窗口中不存在 ZELLIJ 环境变量，zj 会正常走创建/attach 流程
    if set -q ZELLIJ
        # 动态获取当前 fish 的完整路径，兼容 Intel (/usr/local/bin) 和 Apple Silicon (/opt/homebrew/bin)
        set -l fish_path (status fish-path)
        echo "Opening new Ghostty window to create/attach Zellij session..."
        osascript -e '
tell application "Ghostty"
    set cfg to new surface configuration
    set initial working directory of cfg to "'"$PWD"'"
    set command of cfg to "'"$fish_path"' -c \"zj\""
    set win to new window with configuration cfg
end tell
' 2>/dev/null
        if test $status -ne 0
            echo "Error: Failed to open new Ghostty window via AppleScript."
            echo "Please ensure Ghostty is running and AppleScript is enabled (macos-applescript = true)."
            return 1
        end
        return 0
    end

    # 以下是裸终端中的正常创建/attach 逻辑

    # 生成当前基于目录的会话名 (移除非字母数字_-字符以防格式问题)
    set -l session_name (basename $PWD | string replace -a -r '[^a-zA-Z0-9_-]' '_')

    # 检查会话是否已存在，如果存在直接 Attach，不再重新应用 Layout
    if zellij list-sessions -s 2>/dev/null | string match -q "$session_name"
        echo "Session '$session_name' already exists, attaching..."
        zellij attach "$session_name"
        return
    end

    set -l layout "default"
    set -l has_fe 0
    set -l has_be 0
    set -l fe_dir ""
    set -l be_dir ""

    # 1. 优先检测是否为包含前后端的综合工作区
    for dir in */
        if test -f "$dir/package.json"
            set has_fe 1
            set fe_dir (string trim -r -c / "$dir")
        end
        if test -f "$dir/go.mod"; or test -f "$dir/Cargo.toml"; or test -f "$dir/pyproject.toml"; or test -f "$dir/pom.xml"
            set has_be 1
            set be_dir (string trim -r -c / "$dir")
        end
    end

    if test $has_fe -eq 1; and test $has_be -eq 1
        set layout "layout-fullstack"
        echo "Detected fullstack workspace, starting layout '$layout' with fe='$fe_dir', be='$be_dir'"

        set -l tmp_layout "/tmp/zellij_fullstack_"(random)".kdl"
        cat ~/.config/zellij/layouts/layout-fullstack.kdl | sed "s|{{fe_dir}}|$fe_dir|g" | sed "s|{{be_dir}}|$be_dir|g" > "$tmp_layout"
        zellij --layout "$tmp_layout" options --session-name "$session_name" --attach-to-session false
        rm -f "$tmp_layout"
        return
    else if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        # 2. 回退到单体项目检测机制
        if test -f package.json
            set layout "layout-node"
        else if test -f go.mod
            set layout "layout-go"
        else if test -f Cargo.toml
            set layout "layout-rust"
        else if test -f pyproject.toml; or test -f requirements.txt
            set layout "layout-python"
        else if test -f CMakeLists.txt; or test -f Makefile; or test -f configure
            set layout "layout-cpp"
        end
    end

    if test "$layout" != "default"
        echo "Detected project type, starting layout: $layout (Session: $session_name)"
        zellij --layout $layout options --session-name "$session_name" --attach-to-session false
    else
        # 既不是全栈工作区，也不是单体仓库，使用默认工作区
        echo "Starting default workspace (Session: $session_name)"
        zellij --layout dev-workspace options --session-name "$session_name" --attach-to-session false
    end
end
