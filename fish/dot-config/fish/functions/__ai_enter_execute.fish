function __ai_enter_execute -d "Execute commandline; treat ?? as ai_diag_last"
    set -l buf (commandline -b | string trim)

    if test "$buf" = '??'; or test "$buf" = '?'
        commandline -r ai_diag_last
    end

    commandline -f execute
end
