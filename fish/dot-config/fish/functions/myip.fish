function myip -d "查看本机和公网 IP 及所在地"
    # 用法: myip
    
    # 获取默认网络接口 (如 en0, en8 等)
    set -l default_iface (route -n get default 2>/dev/null | awk '/interface: / {print $2}')
    set -l local_ip ""
    set -l iface_name ""

    if test -n "$default_iface"
        set local_ip (ipconfig getifaddr $default_iface 2>/dev/null)
        set iface_name $default_iface
    end
    
    # 失败则回退探测常见接口
    if test -z "$local_ip"
        set local_ip (ipconfig getifaddr en0 2>/dev/null)
        set iface_name "en0"
        
        if test -z "$local_ip"
            set local_ip (ipconfig getifaddr en1 2>/dev/null)
            set iface_name "en1"
        end
    end
    
    if test -z "$local_ip"
        set local_ip "未连接"
    else
        set local_ip "$local_ip ($iface_name)"
    end
    
    echo "🏠 本机: $local_ip"
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
