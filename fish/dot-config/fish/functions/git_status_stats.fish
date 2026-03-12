function git_status_stats -d "显示 Git 状态并附带暂存区和未暂存区的增删行统计"
    # 使用独立函数承载统计逻辑，避免把过长命令直接塞进 abbr 里难以维护。
    command git status $argv
    or return $status

    set -l staged_stats (command git diff --staged --shortstat | string collect | string trim)
    set -l unstaged_stats (command git diff --shortstat | string collect | string trim)

    printf "\nstaged stats:\n"
    if test -n "$staged_stats"
        printf "  %s\n" "$staged_stats"
    else
        printf "  (none)\n"
    end

    printf "\nnot staged stats:\n"
    if test -n "$unstaged_stats"
        printf "  %s\n" "$unstaged_stats"
    else
        printf "  (none)\n"
    end
end
