#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2014/08/31
# Ver   : 1.9
################################
# Delivery mail
deliveryMail()
{
	
	if [ ! "${1}" = "null" ] && [ `echo "$1 >= ${KIJUN_TEMP}" | bc` -eq 1 ]
	then
		# NG route -> send mail
		#echo "NG temp=${1} kijun=${KIJUN_TEMP} ${2}"
		./deliver_mail.sh "TEMP" "${2}" "${1}"
	fi
}

# Create Temp Header
createHeader() {
        cat > "${WORK_FILE}" << EOF
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
<link rel="stylesheet" type="text/css" href="./css/default.css" >
<!-- AJAX API のロード -->
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">

        // Visualization API と折れ線グラフ用のパッケージのロード
        google.load("visualization", "1", {packages:["corechart"]});

        // Google Visualization API ロード時のコールバック関数の設定
        google.setOnLoadCallback(drawChart);

        // グラフ作成用のコールバック関数
        function drawChart() {
                // データテーブルの作成
                var data = google.visualization.arrayToDataTable([
                ['', '部屋の気温','部屋の湿度','不快指数','CPUの温度'],
EOF
}

# Create Tempture
createTemp() {
        if [ -e "${TODAY_FILE}" ]
        then
                if [ "${TIME}" == "00:00" ]
                then
                        # Time 00:00
                        # Move YESTERDAY_FILE
                        # Create New Today File
                        test -e ${D6_FILE} && cat ${D6_FILE} | sed 's/5_temp.html/6_temp.html/g' > ${D7_FILE}
                        test -e ${D5_FILE} && cat ${D5_FILE} | sed -e 's/6_temp.html/7_temp.html/g' -e 's/4_temp.html/5_temp.html/g' > ${D6_FILE}
                        test -e ${D4_FILE} && cat ${D4_FILE} | sed -e 's/5_temp.html/6_temp.html/g' -e 's/3_temp.html/4_temp.html/g' > ${D5_FILE}
                        test -e ${D3_FILE} && cat ${D3_FILE} | sed -e 's/4_temp.html/5_temp.html/g' -e 's/2_temp.html/3_temp.html/g' > ${D4_FILE}
                        test -e ${D2_FILE} && cat ${D2_FILE} | sed -e 's/3_temp.html/4_temp.html/g' -e 's/1_temp.html/2_temp.html/g' > ${D3_FILE}
                        test -e ${D1_FILE} && cat ${D1_FILE} | sed -e 's/2_temp.html/3_temp.html/g' -e 's/0_temp.html/1_temp.html/g' > ${D2_FILE}
                        test -e ${TODAY_FILE} && cat ${TODAY_FILE}| sed 's/1_temp.html/2_temp.html/g' > ${D1_FILE}
                        test -e ${TODAY_FILE} && rm ${TODAY_FILE}

                        # Init Today File
                        createNull
                else
                        # Cutover Exsiting Data to Temporary File
                        head -n 44 "${TODAY_FILE}" | tail -n 24 >> "${WORK_FILE}"
                        cat "${WORK_FILE}" > "${TODAY_FILE}"
                fi
                # Set Time Data
                cat "${TODAY_FILE}" | sed s/\'$TIME\',null,null,null,null/\'$TIME\',$ROOM_TEMP,$ROOM_HYD,$ROOM_RELUX,$VPN_TEMP/g > "${WORK_FILE}"
		cat "${WORK_FILE}" > "${TODAY_FILE}"
        else
                # ファイルが無い場合(システムリスタート直後等)
                createNull
        fi
}

createNull() {
                cat "${WORK_FILE}" > "${TODAY_FILE}"
                cat >> "${TODAY_FILE}" << EOF
                ['00:00',null,null,null,null],
                ['01:00',null,null,null,null],
                ['02:00',null,null,null,null],
                ['03:00',null,null,null,null],
                ['04:00',null,null,null,null],
                ['05:00',null,null,null,null],
                ['06:00',null,null,null,null],
                ['07:00',null,null,null,null],
                ['08:00',null,null,null,null],
                ['09:00',null,null,null,null],
                ['10:00',null,null,null,null],
                ['11:00',null,null,null,null],
                ['12:00',null,null,null,null],
                ['13:00',null,null,null,null],
                ['14:00',null,null,null,null],
                ['15:00',null,null,null,null],
                ['16:00',null,null,null,null],
                ['17:00',null,null,null,null],
                ['18:00',null,null,null,null],
                ['19:00',null,null,null,null],
                ['20:00',null,null,null,null],
                ['21:00',null,null,null,null],
                ['22:00',null,null,null,null],
                ['23:00',null,null,null,null]
EOF
                # Add Data
                cat "${TODAY_FILE}" | sed s/\'$TIME\',null,null,null,null/\'$TIME\',$ROOM_TEMP,$ROOM_HYD,$ROOM_RELUX,$VPN_TEMP/g > "${WORK_FILE}"
                cat "${WORK_FILE}" > "${TODAY_FILE}"
}

# Create Footer
createFooter() {
        cat >> "${TODAY_FILE}" << EOF
                ]);
                if ((navigator.userAgent.indexOf('iPhone') > 0 && navigator.userAgent.indexOf('iPad') == -1) || navigator.userAgent.indexOf('iPod') > 0 || navigator.userAgent.indexOf('Android') > 0) {
                        // グラフのオプションを設定(スマートフォン用プロパティ)
                        var options = {
                            //グラフの解像度
                            width:580,
                            height:245,
                            //縦線のフォーマット
                            vAxis:{format:'#℃',
                            //縦線の最大値と最小値
                            viewWindow:{max:90,min:0},
                            //横線の本数
                            gridlines:{count:9},
                            //文字の色
                            textStyle:{color:'white'}
                            },
                            //横線のフォーマット
                            hAxis:{
                            textStyle:{color:'white'}
                            },
                            //グラフのタイトルの表示位置
                            legend:{
                            position:'top',
                            textStyle:{color:'white'},
                            fontSize: 18,
                            },
                            //タイトル設定
                            title:"TITLEANCHOR",
                            //タイトルの色を設定
                            titleTextStyle:{color:'white'},
                            //ポイントを丸にする
                            pointSize: 7,
                            //グラフの線の太さ
                            lineWidth: 2,
                            //グラフの背景色
                            backgroundColor: {'fill':'transparent'},
                            //グラフを折れ線と棒グラフ混ぜる
                            seriesType: "line",
                            //棒グラフの太さを指定(default:61.8%)
                            bar: {'groupWidth':'75%'},
                            //要素の0-3までを折れ線にする。
                            series: {
                                    0: {
                                            type: "line",
                                            color:"red"
                                    },
                                    1: {
                                            type: "line",
                                            color:"gray"
                                    },
                                    2: {
                                            type: "line",
                                            color:"green"
                                    },
                                    3: {
                                            type: "line",
                                            color:"orange"
                                    }
                            }
                        };
                } else {
                        // グラフのオプションを設定(PC用プロパティ)
                        var options = {
                            //グラフの解像度
                            width:750,
                            height:400,
                            //縦線のフォーマット
                            vAxis:{format:'#℃',
                            //縦線の最大値と最小値
                            viewWindow:{max:90,min:0},
                            //横線の本数
                            gridlines:{count:9},
                            //文字の色
                            textStyle:{color:'white'}
                            },
                            //横線のフォーマット
                            hAxis:{
                            textStyle:{color:'white'}
                            },
                            //グラフのタイトルの表示位置
                            legend:{
                            position:'top',
                            textStyle:{color:'white'},
                            fontSize: 18,
                            },
                            //タイトル設定
                            title:"TITLEANCHOR",
                            //タイトルの色を設定
                            titleTextStyle:{color:'white'},
                            //ポイントを丸にする
                            pointSize: 9,
                            //グラフの線の太さ
                            lineWidth: 2,
                            //グラフの背景色
                            backgroundColor: {'fill':'transparent'},
                            //グラフを折れ線と棒グラフ混ぜる
                            seriesType: "line",
                            //棒グラフの太さを指定(default:61.8%)
                            bar: {'groupWidth':'75%'},
                            //要素の0-3までを折れ線にする。
                            series: {
                                    0: {
                                            type: "line",
                                            color:"red"
                                    },
                                    1: {
                                            type: "line",
                                            color:"gray"
                                    },
                                    2: {
                                            type: "line",
                                            color:"green"
                                    },
                                    3: {
                                            type: "line",
                                            color:"orange"
                                    }
                            }
                        };
                }

                // LineChart のオブジェクトの作成
                var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));

                // データテーブルとオプションを渡して、グラフを描画
                chart.draw(data, options);
        }
        </script>
</head>
<body>
<fieldset class="console_field"><legend>気温グラフ</legend>
<center>
<table border="0" cellspacing="1" cellpadding="0">
<tr>
<td colspan="3"><div id="chart_div" style="width: 100%; height: 100%;"></div></td>
</tr>
<tr style="width: 100%; height: 100%">
<td>
<form class="form_glaph" action="1_temp.html">
<input type="submit" class="btn btn_glaph" value="前の日"/>
</form>
</td>
<td>
<form class="form_glaph" action="0_temp.html">
<input type="submit" class="btn btn_glaph" value="次の日"/>
</form>
</td>
<td>
<form class="form_glaph" action="index.php">
<input type="submit" class="btn btn_glaph" value="戻　る"/>
</form>
</td>
</tr>
</table>
</center>
</fieldset>
</body>
</html>
EOF
        # Replace "TITLEANCHOR" Day Data
        cat "${TODAY_FILE}" | sed s/TITLEANCHOR/"${DAY}"/g > "${WORK_FILE}"
        cat "${WORK_FILE}" > "${TODAY_FILE}"
        test -e "${WORK_FILE}" && rm "${WORK_FILE}"
}

# Create Html
createHtml() {
        # Create Header
        createHeader

        # Create Temp
        createTemp

        # Create Footer
        createFooter
}

###########################
# Main Function
###########################
# Parameter Setting
WORK_FILE="/tmp/work_temp.html"
TODAY_FILE="/tmp/0_temp.html"
D1_FILE="/tmp/1_temp.html"
D2_FILE="/tmp/2_temp.html"
D3_FILE="/tmp/3_temp.html"
D4_FILE="/tmp/4_temp.html"
D5_FILE="/tmp/5_temp.html"
D6_FILE="/tmp/6_temp.html"
D7_FILE="/tmp/7_temp.html"

# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

# Day Setting
DAY=`date "+%Y年%m月%d日(%a)"`
TIME=`date "+%H:%M"`

# CPU Temp
work=`cat /sys/class/thermal/thermal_zone0/temp`
VPN_TEMP=`echo "scale=1;$work / 1000" | bc`

# Room Temp
work=`tempsensor -s`
ROOM_TEMP=`echo ${work} | cut -d "," -f 1`
ROOM_HYD=`echo ${work} | cut -d "," -f 2`

# Relux Point
ROOM_RELUX=`echo "scale=2; 0.81*$ROOM_TEMP+0.01*$ROOM_HYD*(0.99*$ROOM_TEMP-14.3)+46.3" | bc | cut -d "." -f 1`

# Kijun Temp
KIJUN_TEMP=60.0

# Data Check
echo "${VPN_TEMP}" | grep -Eq [[:digit:]] || VPN_TEMP=null
echo "${ROOM_TEMP}" | grep -Eq [[:digit:]] || ROOM_TEMP=null
echo "${ROOM_RELUX}" | grep -Eq [[:digit:]] || ROOM_RELUX=null

# Debug
#echo $DAY
#echo $TIME
#TIME=01:00
#VPN_TEMP=49.7
#ROOM_TEMP=20.7
#echo "${VPN_TEMP}"
#echo "${ROOM_TEMP}"

# Call AddData method
createHtml

# Delivery Mail
# Debug
#VPN_TEMP=58
#VPN_TEMP=null

deliveryMail "${VPN_TEMP}" "VPN"

