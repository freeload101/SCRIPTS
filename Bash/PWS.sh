PATH=/home/internet/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

while true; do
export SavePath="/rmccurdy/stuff/PWS/"



function GetJson(){
        date_YMD=$(date "+%Y-%m-%d %H:%M:%S")
        date_YMD_HR=$(date)
        date_epoch=$(date "+%s")
        local SiteName=${1}
        local StationID=${2}
        VarJSON=$(/usr/bin/curl -s "https://api.weather.com/v2/pws/observations/current?stationId=${StationID}&format=json&units=e&apiKey=53b86ecf7b4047a5b86ecf7b4027a506"   )
        #echo "+ GetJson SiteName:${SiteName} StationID: ${StationID}"
        echo $VarJSON >> "${SavePath}/${SiteName}_${StationID}.txt"

        # precipRate refers to the instantaneous rate of precipitation, such as the rate of rainfall measured in inches per hour at the current moment.
        VarprecipRate=$(echo "${VarJSON}" | grep -oP '(?<=precipRate":)(\d+.\d+|\d+)')

        # precipTotal refers to the accumulated precipitation for a given time period, such as the total rainfall measured in inches over the past hour.
        VarprecipTotal=$(echo "${VarJSON}" | grep -oP '(?<=precipTotal":)(\d+.\d+|\d+)')

        echo "\"${date_YMD}\",${SiteName},${StationID},${VarprecipRate},${VarprecipTotal}"
}

function GetJson_ambientweather(){
        date_YMD=$(date "+%Y-%m-%d %H:%M:%S")
        date_epoch=$(date "+%s")

        local SiteName=${1}
        local StationID=${2}
        # device ID in url NOT MAC .. API is complicated ...
        VarJSON=$(/usr/bin/curl -s "https://lightning.ambientweather.net/devices?public.slug=${StationID}" )

        echo $VarJSON >> "${SavePath}/${SiteName}_${StationID}.txt"
        # eventrainin AKA precipRate ?
        VarprecipRate=$(echo "${VarJSON}" |  grep -oP '(?<=eventrainin":)(\d+.\d+|\d+)')

        # dailyrainin AKA precipTotal ?
        VarprecipTotal=$(echo "${VarJSON}" | grep -oP '(?<=dailyrainin":)(\d+.\d+|\d+)')

        echo "\"${date_YMD}\",${SiteName},${StationID},${VarprecipRate},${VarprecipTotal}"
}

function TODO(){
echo test
# calc av for each site excluding 0s

# error checking
# : if all 0 for all stations for a site then check ~10 near by stations to make sure it's not raining around the area and send text if rain is high for the nearby stations ?
# : if error level then send email ( bad feed station down etc ? )

}

GetJson "Big Creek" "KGAROSWE59" > "${SavePath}/current.txt"
GetJson_ambientweather "Big Creek" "6ea49644cb00adbaf69e373eca58c7c7" >> "${SavePath}/current.txt"

GetJson "Charleston Park" "KGACUMMI424" >> "${SavePath}/current.txt"
GetJson "Charleston Park" "KGACUMMI310" >> "${SavePath}/current.txt"

GetJson "Haw Creek " "KGACUMMI192" >> "${SavePath}/current.txt"
GetJson "Haw Creek " "KGACUMMI349" >> "${SavePath}/current.txt"

GetJson "Matt Park" "KGACUMMI297" >> "${SavePath}/current.txt"

GetJson "Mt. Adams" "KGAALPHA129" >> "${SavePath}/current.txt"



cat "${SavePath}/current.txt"  >> "${SavePath}/history.txt"



## HTML hell

echo '<!DOCTYPE html><html lang="en"><head> <meta content='width=device-width, initial-scale=1' name='viewport'/> <meta charset="UTF-8"> <title>RAMBO Rain Totals</title> <link rel="icon" type="image/x-icon" href="./icons8-rain-100.png"> <style> .heading {font-family:Arial, sans-serif;font-size:14px;} .tg {border-collapse:collapse;border-spacing:0;} .tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px; overflow:hidden;padding:3px 5px;word-break:normal;text-align:left} .tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px; font-weight:bold;overflow:hidden;padding:5px 5px;word-break:normal;text-align:left} </style></head><body><span class="heading">'"${date_YMD_HR}"'</span><table class="tg"> <thead> <tr> <th>Gauge</th> <th>Rate (in/hr)</th> <th>Daily Total (in)</th> </tr> </thead> <tbody>' > /rmccurdy/stuff/PWS/PWS.html

while IFS=',' read -r timestamp location code value1 value2
do
        echo '<tr>' >> /rmccurdy/stuff/PWS/PWS.html

        if [ ${#code} -gt 20 ]
        then
                echo '<td><a href="https://ambientweather.net/dashboard/'"${code}"'" target="_blank" rel="noopener noreferrer">'"${location}"'</a></td>' >> /rmccurdy/stuff/PWS/PWS.html
        else
                echo '<td><a href="https://www.wunderground.com/dashboard/pws/'"${code}"'" target="_blank" rel="noopener noreferrer">'"${location}"'</a></td>' >> /rmccurdy/stuff/PWS/PWS.html
        fi

        echo '<td>'"${value1}"'</td>' >> /rmccurdy/stuff/PWS/PWS.html
        echo '<td>'"${value2}"'</td>' >> /rmccurdy/stuff/PWS/PWS.html
done < /rmccurdy/stuff/PWS/current.txt

echo '</tbody></table></body></html>' >> /rmccurdy/stuff/PWS/PWS.html
echo Sleeping 900 Seconds
sleep 900
