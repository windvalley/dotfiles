function wt -d "查询近3日天气预报 (默认本地, 支持指定城市)"
    # 用法: wt          - 查本地天气
    #       wt Beijing  - 查北京天气
    curl -s "wttr.in/$argv[1]?format=v2&F"
    echo "🌬 风级参考: ≤1微风 | 6轻风 | 12和风 | 20清风 | 29劲风 | 39强风 | 50大风 | 62烈风 (km/h)"
end
