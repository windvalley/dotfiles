function gdoctor -d "诊断并检查当前 Git 仓库的健康状态"
    # 定义局部颜色打印函数，用于保持 UI 风格统一
    function __gdoctor_info
        printf "%s[INFO]%s %s\n" (set_color blue) (set_color normal) "$argv"
    end
    function __gdoctor_item
        printf "%s[-]%s %s\n" (set_color brblack) (set_color normal) "$argv"
    end
    function __gdoctor_suggest
        # 子项目统一占 3 个字符宽 (如 [!]、[✓]、[-])，加上紧随其后的 1 个空格，共计 4 个字符偏置。
        # 这里用 4 个空格将💡严丝合缝地对齐在大括号下方
        printf "    %s💡 修复建议:%s %s\n" (set_color cyan) (set_color normal) "$argv"
    end
    function __gdoctor_success
        printf "%s[✓]%s %s\n" (set_color green) (set_color normal) "$argv"
    end
    function __gdoctor_warn
        printf "%s[!]%s %s\n" (set_color yellow) (set_color normal) "$argv"
    end
    function __gdoctor_error
        printf "%s[✗]%s %s\n" (set_color red) (set_color normal) "$argv"
    end

    # 为什么需要这一步？
    # 诊断工具必须确保当前处于工作区，否则后续的所有 Git 命令都会报错。
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        __gdoctor_error "当前目录不是一个 Git 仓库"
        return 1
    end

    set -l has_warnings 0
    set -l has_errors 0

    echo ""
    __gdoctor_info "开始诊断 Git 仓库健康状态..."
    echo ""

    # =====================================================================
    # 维度一：工作流健康度 (Workflow Health)
    # =====================================================================
    __gdoctor_info "① 检查工作流状态..."

    # 为什么检查中断操作？
    # 用户在 rebase/merge/cherry-pick/bisect 等交互式操作中途放弃后，
    # 仓库会长期处于"半吊子"状态，后续任何 git 操作都可能产生意外行为或报错。
    set -l git_dir (git rev-parse --git-dir 2>/dev/null)
    set -l interrupted 0
    if test -f "$git_dir/MERGE_HEAD"
        __gdoctor_warn "检测到未完成的合并操作 (merge in progress)"
        __gdoctor_suggest "继续合并 (git merge --continue) 或放弃 (git merge --abort)"
        set interrupted 1
    end
    if test -d "$git_dir/rebase-merge"; or test -d "$git_dir/rebase-apply"
        __gdoctor_warn "检测到未完成的变基操作 (rebase in progress)"
        __gdoctor_suggest "继续变基 (git rebase --continue) 或放弃 (git rebase --abort)"
        set interrupted 1
    end
    if test -f "$git_dir/CHERRY_PICK_HEAD"
        __gdoctor_warn "检测到未完成的挑拣操作 (cherry-pick in progress)"
        __gdoctor_suggest "继续挑拣 (git cherry-pick --continue) 或放弃 (git cherry-pick --abort)"
        set interrupted 1
    end
    if test -f "$git_dir/BISECT_LOG"
        __gdoctor_warn "检测到未完成的二分查找操作 (bisect in progress)"
        __gdoctor_suggest "继续二分 (git bisect good/bad) 或结束 (git bisect reset)"
        set interrupted 1
    end
    if test "$interrupted" -eq 1
        set has_warnings 1
    else
        __gdoctor_success "无中断的操作"
    end

    
    # 为什么检查工作区？
    # 如果工作区很脏，可能导致切换分支失败或由于误操作丢失未提交代码，提前警告用户清理。
    set -l is_dirty 0
    if not git diff --quiet 2>/dev/null
        set is_dirty 1
    else if not git diff --cached --quiet 2>/dev/null
        set is_dirty 1
    else
        set -l untracked (git ls-files --others --exclude-standard)
        if test -n "$untracked"
            set is_dirty 1
        end
    end

    if test "$is_dirty" -eq 1
        __gdoctor_warn "工作区不干净，存在未提交的更改或未跟踪的文件"
        __gdoctor_suggest "提示清理或提交 (git clean -fd / git commit / git stash)"
        set has_warnings 1
    else
        __gdoctor_success "工作区干净"
    end

    # 为什么检查 Detached HEAD？
    # 在这个状态下提交的代码很容易丢失（变成悬空对象），必须提醒用户切回固定分支。
    if not git symbolic-ref -q HEAD >/dev/null 2>&1
        __gdoctor_warn "当前处于 Detached HEAD 状态 (游离的 HEAD)"
        __gdoctor_suggest "切回有效分支 (git switch <branch-name>)"
        set has_warnings 1
    else
        set -l current_branch (git branch --show-current)
        __gdoctor_success "分支状态正常 ($current_branch)"
    end

    # 为什么检查 Stash 区？
    # 很多开发者习惯 stash 保存临时代码但常常遗忘，导致 stash list 越来越长，变成僵尸代码堆积。
    set -l stash_count (git stash list | wc -l | tr -d ' ')
    if test "$stash_count" -gt 0
        if test "$stash_count" -gt 5
            __gdoctor_warn "存在较多过期的储藏记录 (stash count: $stash_count)"
            __gdoctor_suggest "清理已失效的历史储藏 (git stash clear 或 git stash drop)"
            set has_warnings 1
        else
            __gdoctor_item "存在储藏记录 (stash count: $stash_count)"
        end
    else
        __gdoctor_success "储藏区 (stash) 干净"
    end

    echo ""

    # =====================================================================
    # 维度二：远程同步健康度 (Remote Sync Health)
    # =====================================================================
    __gdoctor_info "② 检查远程同步状态..."
    set -l current_branch (git branch --show-current)
    if test -n "$current_branch"
        set -l upstream (git for-each-ref --format='%(upstream:short)' refs/heads/$current_branch 2>/dev/null)
        if test -z "$upstream"
            # 没有追踪远程分支，如果是新分支比较常见，但也可能导致 pull/push 操作需要频繁指定远程和分支名
            __gdoctor_warn "当前分支 ($current_branch) 尚未配置上游追踪分支"
            __gdoctor_suggest "git push -u origin $current_branch"
            set has_warnings 1
        else
            # 为什么检查差异？
            # 如果本地领先或落后远程，提醒用户同步代码，避免产生未预期的合流冲突或覆盖问题。
            set -l sync_status (git rev-list --left-right --count "$current_branch"..."$upstream" 2>/dev/null)
            if test -n "$sync_status"; and test "$sync_status" != "0	0"
                set -l ahead (echo "$sync_status" | awk '{print $1}')
                set -l behind (echo "$sync_status" | awk '{print $2}')
                
                if test "$ahead" -gt 0; or test "$behind" -gt 0
                    __gdoctor_warn "当前分支与远程不同步 (领先 $ahead 个提交，落后 $behind 个提交)"
                    __gdoctor_suggest "考虑同步代码 (git pull / git push)"
                    set has_warnings 1
                else
                    __gdoctor_success "与远程分支 ($upstream) 同步正常"
                end
            else
                __gdoctor_success "与远程分支 ($upstream) 同步正常"
            end
        end
    end

    # 为什么检查 gone 分支？
    # 有时候远程分支已经被合并后删除了，本地的追踪分支仍然存在，长时间积累会导致分支列表极端膨胀。
    set -l gone_branches (git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == "[gone]" {print $1}')
    if test -n "$gone_branches"
        __gdoctor_warn "存在已被远程删除的失效本地分支: "(string join ", " $gone_branches)
        __gdoctor_suggest "考虑清理失效分支 (git fetch -p 然后 git branch -d <branch-name>)"
        set has_warnings 1
    end

    # 为什么检查已合并但未删除的本地分支？
    # 功能分支合并进主分支后如果不清理，`git branch` 列表会越来越长，增加认知负担。
    set -l main_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if test -z "$main_branch"
        set main_branch main
    end
    set -l merged_branches (git branch --merged $main_branch 2>/dev/null | string trim | string match -rv '^\*|^'$main_branch'$')
    if test -n "$merged_branches"
        set -l merged_count (count $merged_branches)
        __gdoctor_warn "存在 $merged_count 个已合并但未删除的本地分支"
        __gdoctor_suggest "考虑清理 (git branch -d "(string join " " $merged_branches)")"
        set has_warnings 1
    else
        __gdoctor_success "无已合并的冗余本地分支"
    end

    echo ""

    # =====================================================================
    # 维度三：性能与存储臃肿度 (Performance & Space Bloat)
    # =====================================================================
    __gdoctor_info "③ 检查性能与存储..."
    
    # 为什么检查松散对象？
    # 松散对象过多会严重影响 git 性能，并占用大量磁盘小碎文件。
    set -l count_objects (git count-objects -v 2>/dev/null)
    set -l loose_objects (echo "$count_objects" | awk '/^count:/ {print $2}')
    if test -n "$loose_objects"; and test "$loose_objects" -gt 1000
        __gdoctor_warn "存在大量未打包的松散对象 ($loose_objects)"
        __gdoctor_suggest "运行垃圾回收提升性能 (git gc)"
        set has_warnings 1
    else
        if test -z "$loose_objects"
            set loose_objects 0
        end
        __gdoctor_success "存储对象状态良好 (松散对象: $loose_objects)"
    end

    echo ""

    # =====================================================================
    # 维度四：数据完整性检查 (Data Integrity)
    # =====================================================================
    __gdoctor_info "④ 检查数据完整性 (这可能需要几秒钟)..."
    
    # 为什么屏蔽 dangling 警告？
    # 开发者在 rebase 或重置过程中产生 dangling 提交和树对象属于正常态不是报错。
    # 我们只关心 error/fatal 级别的真实对象损坏（corrupt/missing）。
    if git fsck --no-dangling >/dev/null 2>&1
        __gdoctor_success "数据完整性检查通过"
    else
        __gdoctor_error "数据损坏或存在不一致，请手动运行 git fsck 检查详细错误！"
        __gdoctor_suggest "这是非常危险的底层状态，建议立即备份或基于远程仓库重新 clone"
        set has_errors 1
    end

    echo ""
    # =====================================================================
    # 总结输出
    # =====================================================================
    if test "$has_errors" -gt 0
        __gdoctor_error "诊断结束: 仓库存在严重错误，这是高优警报，请尽快修复！"
        return 1
    else if test "$has_warnings" -gt 0
        printf "%s[WARN]%s 诊断结束: 仓库存在一些警告项，建议根据提示进行日常维护。\n" (set_color yellow) (set_color normal)
        return 0
    else
        __gdoctor_success "诊断结束: 当前仓库状态非常健康！ 🎉"
        return 0
    end
end
