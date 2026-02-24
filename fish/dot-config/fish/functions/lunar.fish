function lunar -d "万年历 (公历+农历+生肖+干支)"
    # 用法: lunar          - 查今天
    #      lunar 2025-01-29 - 查指定日期
    command cal
    echo ""
    python3 -c "
from zhdate import ZhDate
import datetime, sys
date_str = sys.argv[1] if len(sys.argv) > 1 else None
try:
    dt = datetime.datetime.strptime(date_str, '%Y-%m-%d') if date_str else datetime.datetime.now()
except ValueError:
    print('❌ 日期格式错误, 请使用 YYYY-MM-DD'); sys.exit(1)
zh = ZhDate.from_datetime(dt)
tg = '甲乙丙丁戊己庚辛壬癸'[(zh.lunar_year - 4) % 10]
dz = '子丑寅卯辰巳午未申酉戌亥'[(zh.lunar_year - 4) % 12]
sx = '鼠牛虎兔龙蛇马羊猴鸡狗猪'[(zh.lunar_year - 4) % 12]
yue = '正二三四五六七八九十冬腊'[zh.lunar_month - 1]
ri = ['初一','初二','初三','初四','初五','初六','初七','初八','初九','初十','十一','十二','十三','十四','十五','十六','十七','十八','十九','二十','廿一','廿二','廿三','廿四','廿五','廿六','廿七','廿八','廿九','三十'][zh.lunar_day - 1]
print(f'📅 农历 {tg}{dz}年 {yue}月{ri}  🐲 {sx}年')
" $argv 2>/dev/null; or echo "⚠️  需要 zhdate: pip3 install zhdate"
end
