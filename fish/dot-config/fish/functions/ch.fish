function ch -d "查询 cheat.sh 快速获取命令帮助"
    if test (count $argv) -eq 0; or contains -- $argv[1] -h --help
        echo "Query cheat.sh for quick command help"
        echo ""
        echo "Usage:"
        echo "  ch <command>          Get cheat sheet for the specified command"
        echo "  ch help | -h          Show this help message"
        echo ""
        echo "Example:"
        echo "  ch tar"
        echo "  ch curl"
        return 0
    end
    curl cheat.sh/$argv[1]
end
