PATH=/home/internet/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
 
while true; do 
export SavePath="/rmccurdy/stuff/PWS/"

function GetJson(){
	date_YMD=$(date "+[%Y-%m-%d %H:%M:%S%z (%Z)]")
	date_epoch=$(date "+%s")
	local SiteName=${1} 
	local StationID=${2}
	VarJSON=$(/usr/bin/curl -s "https://api.weather.com/v2/pws/observations/current?stationId=${StationID}&format=json&units=e&apiKey=XXXXXXXXXXXXXXXXXXXXXXXXXX"   )
	#echo "+ GetJson SiteName:${SiteName} StationID: ${StationID}"
	echo $VarJSON >> "${SavePath}/${SiteName}_${StationID}.txt"
	 
	# precipRate refers to the instantaneous rate of precipitation, such as the rate of rainfall measured in inches per hour at the current moment.
	VarprecipRate=$(echo "${VarJSON}" | grep -oP '(?<=precipRate":)(\d+.\d+|\d+)')

	# precipTotal refers to the accumulated precipitation for a given time period, such as the total rainfall measured in inches over the past hour.
	VarprecipTotal=$(echo "${VarJSON}" | grep -oP '(?<=precipTotal":)(\d+.\d+|\d+)')

	echo "\"${date_YMD}\",${SiteName},${StationID},${VarprecipRate},${VarprecipTotal}"
}

function GetJson_ambientweather(){
	date_YMD=$(date "+[%Y-%m-%d %H:%M:%S%z (%Z)]")
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
echo Sleeping 900 Seconds
sleep 900
done
