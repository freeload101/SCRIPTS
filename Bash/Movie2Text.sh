# export IFS=$'\n';
# for i in `find . -iname "*.mp3"` ; do echo "$i"; nice -n -100 ./Movie2Text.sh "$i";done



#pip install vtt2text
#pip install git+https://github.com/LIAAD/yake 
#python3 -m pip install --no-deps -U yt-dlp
#python3 -m pip install -U yt-dlp
#python3 -m pip install pystache
#python3 -m pip install vosk
# wget https://alphacephei.com/vosk/models/vosk-model-en-us-0.42-gigaspeech.zip
# wget https://github.com/alphacep/vosk-api/raw/master/python/example/test_simple.py
# yake is broken as it has not output options 
export IFS=$'\n';


kill -9 `ps aufx|grep vosk-transcriber| awk '{print $2}'`


filename="$1.wav"

if [ -f "${filename}_vosk_out.txt" ]; then
    echo "${filename}_vosk_out.txt exists."
else 
    echo "${filename}_vosk_out.txt does not exist."

	echo `date` "DEBUG: comverting with ffmpegg "${1}" to wav"

	ffmpeg  -y -i "${1}" -b:a 192K -vn "${filename}"

	echo `date` "DEBUG: Convert wav to text with vosk"
	#python3 test_simple.py "${filename}" > "${filename}_vosk_out.txt"
	vosk-transcriber -m "./vosk-model-en-us-0.42-gigaspeech" -i "${filename}" -o "${filename}_vosk_out.txt"

	echo `date` 'DEBUG: Extract 100 "keyword extraction" using yake'
	# we could look to more of "text classification" as in find the catagories insted of just keywords ..
	# https://www.interviewquery.com/blog-keyword-extraction/
	# https://towardsdatascience.com/using-keyword-extraction-for-unsupervised-text-classification-in-nlp-10433a1c0cf9
	yake -i "${filename}_vosk_out.txt" -t 100  > "${filename}_yake.txt"

	echo `date` "DEBUG: Showing randome 10 results"
	shuf -n 10 "${filename}_yake.txt"

fi
