function wt -d "查询天气预报 (支持指定城市或使用 all 参数查询所有热点城市)"
    if test (count $argv) -gt 0; and contains -- $argv[1] -h --help
        echo "Weather Forecast Tool"
        echo ""
        echo "Usage:"
        echo "  wt [city]             Query weather for a specific city (default: Beijing)"
        echo "  wt all                Query weather overview for all major cities"
        echo "  wt -h | --help        Show this help message"
        echo ""
        echo "Supported Cities:"
        echo "  Beijing, Shanghai, Guangzhou, Shenzhen, Hangzhou, Chengdu, Nanjing, "
        echo "  Wuhan, Xi'an, Harbin, Sanya, Haikou, Beihai, Xishuangbanna"
        return 0
    end

    # 内部城市映射函数
    function __get_city_info
        set -l input (string lower -- "$argv[1]")
        switch "$input"
            case shanghai 上海
                echo "101020100|上海"
            case guangzhou 广州
                echo "101280101|广州"
            case shenzhen 深圳
                echo "101280601|深圳"
            case hangzhou 杭州
                echo "101210101|杭州"
            case chengdu 成都
                echo "101270101|成都"
            case wuhan 武汉
                echo "101200101|武汉"
            case nanjing 南京
                echo "101190101|南京"
            case harbin 哈尔滨
                echo "101050101|哈尔滨"
            case sanya 三亚
                echo "101310201|三亚"
            case xishuangbanna 西双版纳 景洪
                echo "101291601|西双版纳"
            case beihai 北海
                echo "101301301|北海"
            case haikou 海口
                echo "101310101|海口"
            case xian 西安
                echo "101110101|西安"
            case beijing 北京 ""
                echo "101010100|北京"
            case "*"
                echo unknown
        end
    end

    if test "$city_arg" = all
        set -l cities 北京 上海 广州 深圳 杭州 成都 南京 武汉 西安 哈尔滨 三亚 海口 北海 西双版纳
        echo "📡 正在获取热点城市天气概览 (14 个城市)..."

        # 构建 ID 列表传给 Python 内部处理，避免 Shell 管道截断问题
        set -l ids
        for city in $cities
            set -l info (__get_city_info "$city")
            set ids $ids (string split -f1 "|" -- "$info")
        end

        echo $ids | python3 -c "
import sys, json, re, unicodedata, urllib.request
from concurrent.futures import ThreadPoolExecutor

def get_width(s):
    plain = re.sub(r'\x1b\[[0-9;]*[mGJKH]', '', s)
    width = 0
    for char in plain:
        if unicodedata.east_asian_width(char) in ('W', 'F'): width += 2
        else: width += 1
    return width

def pad(s, target):
    return s + ' ' * (target - get_width(s))

def fetch(city_id):
    try:
        url = f'http://t.weather.sojson.com/api/weather/city/{city_id}'
        with urllib.request.urlopen(url, timeout=5) as response:
            return json.loads(response.read().decode('utf-8'))
    except: return None

def draw():
    ids = sys.stdin.read().split()
    headers = ['城市', '天气', '温度', '温差范围', '风力', '湿度', 'PM2.5', '空气质量', '更新时间']

    with ThreadPoolExecutor(max_workers=min(len(ids), 20)) as executor:
        results = list(executor.map(fetch, ids))

    rows = []
    for d in results:
        if not d or d.get('status') != 200: continue
        data = d.get('data', {}); f = data.get('forecast', [{}])[0]
        rows.append([
            d['cityInfo']['city'],
            f.get('type', '-'),
            f\"{data.get('wendu', '-')}°C\",
            f\"{f.get('low','')}\".replace('低温 ','').replace('℃','') + ' ~ ' + f\"{f.get('high','')}\".replace('高温 ','').replace('℃','°C'),
            f.get('fl', '-'),
            data.get('shidu', '-'),
            str(int(data.get('pm25', 0))),
            data.get('quality', '-'),
            d['time'].split(' ')[1]
        ])

    if not rows: return
    col_ws = [max([get_width(headers[i])] + [get_width(r[i]) for r in rows]) for i in range(len(headers))]
    H, V = '─', '│'; TL, TM, TR = '┌', '┬', '┐'; LM, MM, RM = '├', '┼', '┤'; BL, BM, BR = '└', '┴', '┘'
    def bline(ch): sys.stdout.write(ch[0] + ch[1].join(H*(w+2) for w in col_ws) + ch[2] + '\\n')
    COLORS = {'优': '\\033[32m', '良': '\\033[33m', '轻度': '\\033[31m', '中度': '\\033[35m', '重度': '\\033[41;37m'}

    bline((TL, TM, TR))
    h_row = V
    for h, w in zip(headers, col_ws): h_row += f\" \\033[1;34m{pad(h, w)}\\033[0m \" + V
    sys.stdout.write(h_row + '\\n'); bline((LM, MM, RM))
    for r in rows:
        r_row = V
        for i, val in enumerate(r):
            if i == 7: s = f\"{COLORS.get(val, '')}{pad(val, col_ws[i])}\\033[0m\"
            elif i == 2: s = f\"\\033[1m{pad(val, col_ws[i])}\\033[0m\"
            else: s = pad(val, col_ws[i])
            r_row += f\" {s} \" + V
        sys.stdout.write(r_row + '\\n')
    bline((BL, BM, BR))

draw()
"
    else
        set -l info (__get_city_info "$city_arg")
        if test "$info" = unknown
            echo "❌ 暂不支持该城市。支持列表: 北京, 上海, 广州, 深圳, 杭州, 成都, 南京, 武汉, 西安, 哈尔滨, 三亚, 海口, 北海, 西双版纳"
            return 1
        end

        set -l id (string split -f1 "|" -- "$info")
        set -l city_name (string split -f2 "|" -- "$info")

        curl -s "http://t.weather.sojson.com/api/weather/city/$id" | python3 -c "
import sys, json, re, unicodedata

def get_width(s):
    plain = re.sub(r'\x1b\[[0-9;]*[mGJKH]', '', s)
    width = 0
    for char in plain:
        if unicodedata.east_asian_width(char) in ('W', 'F'): width += 2
        else: width += 1
    return width

def pad(s, target):
    return s + ' ' * (target - get_width(s))

def get_quality(aqi):
    if aqi <= 50: return '优'
    if aqi <= 100: return '良'
    if aqi <= 150: return '轻度'
    if aqi <= 200: return '中度'
    return '重度'

try:
    d = json.load(sys.stdin)
    if d['status'] == 200:
        city = d['cityInfo']['city']
        data = d.get('data', {})
        forecasts = data.get('forecast', [])
        quality = data.get('quality', '-')
        COLORS = {'优': '\\033[32m', '良': '\\033[33m', '轻度': '\\033[31m', '中度': '\\033[35m', '重度': '\\033[41;37m'}
        q_color = COLORS.get(quality, '')

        print(f'\\033[1;36m🏙 {city}\\033[0m \\033[90m(更新: {d[\"time\"]})\\033[0m')
        print(f'🌡 \\033[1m{data.get(\"wendu\", \"-\")}°C\\033[0m | 💧 \\033[1m{data.get(\"shidu\", \"-\")}\\033[0m | PM2.5: \\033[1m{int(data.get(\"pm25\", 0))}\\033[0m | 空气: {q_color}\\033[1m{quality}\\033[0m')
        print(f'\\033[3m✨ 提醒: {data.get(\"ganmao\", \"-\")}\\033[0m')

        headers = ['日期', '周', '天气', '温度范围', 'PM2.5', '空气', '风力', '提示']
        rows = []
        for f in forecasts:
            rows.append([
                f.get('ymd', '-'),
                f.get('week', '-'),
                f.get('type', '-'),
                f\"{f.get('low','')}\".replace('低温 ','').replace('℃','') + ' ~ ' + f\"{f.get('high','')}\".replace('高温 ','').replace('℃','°C'),
                str(int(f.get('aqi', 0))) if f.get('aqi') is not None else '-',
                f.get('quality') or (get_quality(f.get('aqi')) if f.get('aqi') else '-'),
                f.get('fl', '-'),
                f.get('notice', '-')
            ])

        col_ws = [max([get_width(headers[i])] + [get_width(r[i]) for r in rows]) for i in range(len(headers))]
        H, V = '─', '│'; TL, TM, TR = '┌', '┬', '┐'; LM, MM, RM = '├', '┼', '┤'; BL, BM, BR = '└', '┴', '┘'
        def bline(ch): sys.stdout.write(ch[0] + ch[1].join(H*(w+2) for w in col_ws) + ch[2] + '\\n')

        bline((TL, TM, TR))
        h_row = V
        for h, w in zip(headers, col_ws): h_row += f\" \\033[1;34m{pad(h, w)}\\033[0m \" + V
        sys.stdout.write(h_row + '\\n'); bline((LM, MM, RM))
        for r in rows:
            r_row = V
            for i, val in enumerate(r):
                if i == 5: s = f\"{COLORS.get(val, '')}{pad(val, col_ws[i])}\\033[0m\"
                else: s = pad(val, col_ws[i])
                r_row += f\" {s} \" + V
            sys.stdout.write(r_row + '\\n')
        bline((BL, BM, BR))
    else:
        print(f'❌ API 错误: {d.get(\"message\", \"未知错误\")}')
except Exception as e:
    print(f'❌ 解析失败: {e}')
"
    end
end
