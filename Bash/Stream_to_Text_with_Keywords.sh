for i in `cat in`
do


echo `date` "DEBUG: Downloading "${i}" with youtube-dl and convert to wav"
export filename=`youtube-dl  --get-filename -o "%(title)s.wav" "${i}"`
#export filename=`youtube-dl  --get-filename -o "%(title)s.%(ext)s" "${i}"|sed 's/(.*)\.(.*)$/\1\.wav/g'`
youtube-dl --extract-audio --audio-format wav  --postprocessor-args "-ac 1"  -o "%(title)s.%(ext)s" "${i}" 

echo `date` "DEBUG: Run vosk on wav file and output text to text"
python3 /media/moredata/docker/vosk-api/python/example/test_simple.py "${filename}" > "${filename}_vosk_out.txt"


echo `date` "DEBUG: Normalize the output and remove beginning TTS stuff and common keywords"
grep '\"text\"' "${filename}_vosk_out.txt"  | sed 's/\"text\" ://g' | sed 's/\"\"//g' | uniq |grep -Ev "this is public radio episode|tonight show entitled|brought to you by an honest|brought to you by an honest|brought to you by an honest" > "${filename}_vosk_out_normalized.txt"

echo `date` 'DEBUG: Extract 100 "keyword extraction" using yake'
# we could look to more of "text classification" as in find the catagories insted of just keywords ..
# https://www.interviewquery.com/blog-keyword-extraction/
# https://towardsdatascience.com/using-keyword-extraction-for-unsupervised-text-classification-in-nlp-10433a1c0cf9
yake -i "${filename}_vosk_out_normalized.txt" -t 100 | grep -Evia "(hacker public|creative commons|free public|commons attribution|show notes|public radio|keyword|--------|today show|free software)" > "${filename}_yake.txt"

echo `date` "DEBUG: Showing randome 10 results"
shuf -n 10 "${filename}_yake.txt"



done
