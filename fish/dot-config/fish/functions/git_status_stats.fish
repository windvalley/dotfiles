function git_status_stats -d "显示 Git 状态并附带暂存区和未暂存区的增删行统计"
    # 使用独立函数承载统计逻辑，避免把过长命令直接塞进 abbr 里难以维护。
    command git status $argv
    or return $status

    set -l staged_stats (command git diff --staged --shortstat | string collect | string trim)
    set -l unstaged_stats (command git diff --shortstat | string collect | string trim)
    set -l has_staged 0
    set -l has_unstaged 0

    if test -n "$staged_stats"
        set has_staged 1
    end

    if test -n "$unstaged_stats"
        set has_unstaged 1
    end

    if test $has_staged -eq 1
        printf "staged stats:\n"
        printf "  %s\n" "$staged_stats"
    end

    if test $has_staged -eq 1 -a $has_unstaged -eq 1
        printf "\n"
    end

    if test $has_unstaged -eq 1
        printf "not staged stats:\n"
        printf "  %s\n" "$unstaged_stats"
    end
end
