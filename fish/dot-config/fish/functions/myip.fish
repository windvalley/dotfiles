function myip -d "查看本机和公网 IP 及所在地"
    # 用法: myip
    set -l local_ip (ipconfig getifaddr en0 2>/dev/null)
    if test -z "$local_ip"
        set local_ip "未连接 (en0)"
    end
    
    echo "🏠 本机: "$local_ip
    echo "🌍 公网: "(curl -s ipinfo.io/json | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    ip = d.get("ip", "未知")
    country = d.get("country", "")
    region = d.get("region", "")
    city = d.get("city", "")
    loc = " ".join(filter(None, [country, region, city]))
    print(ip + " (" + loc + ")" if loc else ip)
except Exception as e:
    print("获取失败: " + str(e))
')
end
