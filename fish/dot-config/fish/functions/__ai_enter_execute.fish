function __ai_enter_execute -d "Execute commandline; treat ?/?? as AI shortcuts"
    set -l buf (commandline -b | string trim)

    if test "$buf" = '??'
        commandline -r ai_diag_last
    else if test "$buf" = '?'
        commandline -r __ai_cmd
    end

    commandline -f execute
end
