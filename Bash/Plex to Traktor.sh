# rename Plex offline to Traktor import ...
# C:\Users\internet\AppData\Local\Plexamp\Plexamp\Offline
#for i in `find . -type f \( ! -iname "*.flac" ! -iname "*.mp3" ! -iname "*.ogg"  \) `
# cd /cygdrive/c/Users/internet/AppData/Local/Plexamp/Plexamp/Offline
for i in `find . `
do
export FileName="$i"
export FileType=`file "$FileName"`
echo $i
echo $FileType

	if [[ "$FileType"  == *MPEG*  ]]
	then
		mv "$FileName" "${FileName}.mp3"
	fi
	
	if [[ "$FileType"  == *FLAC*  ]]
	then
		mv "$FileName" "${FileName}.flac"
	fi
	if [[ "$FileType"  == *Ogg*  ]]
	then
		mv "$FileName" "${FileName}.ogg"
	fi

	
done

