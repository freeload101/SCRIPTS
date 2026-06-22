#!/bin/bash
PATH=/home/internet/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
SP="/media/3TB/rmccurdy/stuff/PWS"
API_KEY="53b86ecf7b4047a5b86ecf7b4027a506"
NOW=$(date "+%Y-%m-%d %H:%M:%S")
NOW_HR=$(date)

get_wund() {
  local name=$1 id=$2
  local json=$(/usr/bin/curl -s "https://api.weather.com/v2/pws/observations/current?stationId=${id}&format=json&units=e&apiKey=${API_KEY}")
  echo "$json" >> "${SP}/${name}_${id}.txt"
  local rate=$(echo "$json" | grep -oP '(?<=precipRate":)(\d+\.?\d*)')
  local total=$(echo "$json" | grep -oP '(?<=precipTotal":)(\d+\.?\d*)')
  echo "\"${NOW}\",${name},${id},${rate},${total}"
}

get_ambient() {
  local name=$1 id=$2
  local json=$(/usr/bin/curl -s "https://lightning.ambientweather.net/devices?public.slug=${id}")
  echo "$json" >> "${SP}/${name}_${id}.txt"
  local rate=$(echo "$json" | grep -oP '(?<=eventrainin":)(\d+\.?\d*)')
  local total=$(echo "$json" | grep -oP '(?<=dailyrainin":)(\d+\.?\d*)')
  echo "\"${NOW}\",${name},${id},${rate},${total}"
}

{
  get_wund      "Big Creek"       "KGAROSWE236"
  get_ambient   "Big Creek"       "6ea49644cb00adbaf69e373eca58c7c7"
  get_wund      "Charleston Park" "KGACUMMI424"
  get_wund      "Charleston Park" "KGACUMMI310"
  get_wund      "Haw Creek"       "KGACUMMI192"
  get_wund      "Haw Creek"       "KGACUMMI349"
  get_wund      "Matt Park"       "KGACUMMI297"
  get_wund      "Mt. Adams"       "KGAALPHA129"
} > "${SP}/current.txt"

cat "${SP}/current.txt" >> "${SP}/history.txt"

# Build HTML
{
cat << HTML
<!DOCTYPE html><html lang="en"><head>
<meta content='width=device-width,initial-scale=1' name='viewport'/>
<meta charset="UTF-8"><title>RAMBO Rain Totals</title>
<link rel="icon" type="image/x-icon" href="./icons8-rain-100.png">
<style>
.heading{font-family:Arial,sans-serif;font-size:14px;}
.tg{border-collapse:collapse;border-spacing:0;}
.tg td,.tg th{border:1px solid black;font-family:Arial,sans-serif;font-size:14px;overflow:hidden;padding:3px 5px;word-break:normal;text-align:left;}
.tg th{font-weight:bold;padding:5px;}
</style></head><body>
<span class="heading">${NOW_HR}</span>
<table class="tg"><thead><tr>
<th>Gauge</th><th>Rate (in/hr)</th><th>Daily Total (in)</th>
</tr></thead><tbody>
HTML

while IFS=',' read -r ts loc code v1 v2; do
  if [ ${#code} -gt 20 ]; then
    url="https://ambientweather.net/dashboard/${code}"
  else
    url="https://www.wunderground.com/dashboard/pws/${code}"
  fi
  echo "<tr><td><a href=\"${url}\" target=\"_blank\" rel=\"noopener noreferrer\">${loc}</a></td><td>${v1}</td><td>${v2}</td></tr>"
done < "${SP}/current.txt"

echo '</tbody></table></body></html>'
} > "${SP}/PWS.html"
