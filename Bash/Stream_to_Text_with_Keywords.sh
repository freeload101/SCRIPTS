# yake is broken as it has not output options 
IFS=$'\n';

echo `date` "DEBUG: Only supports (en) English with youtube URLs"
echo `date` "DEBUG: Eats Youtube Playlist and Channel URLs"

while read -r i
do


echo `date` "DEBUG: Downloading "${i}" with youtube-dl and convert to wav"



#check if youtube then just ripp the sub titles ...
if [[ "${i}"  == *youtube*  ]]
then
echo `date` "DEBUG: URL detected Youtube ripping subtitles from youtube direct"
#export filename=`youtube-dl  --write-auto-sub --convert-subs=srt --skip-download  --get-filename -o "%(title)s" "${i}"`
youtube-dl  --write-auto-sub --convert-subs=srt --skip-download  -o  "%(title)s" "${i}"

find . -iname "*.vtt" -exec python vtt2text.py '{}' \;

rm *.vtt

echo `date` 'DEBUG: Extract 100 "keyword extraction" using yake this may take a while on a lot of videos'
find . -name '*\.en\.txt'  -type f ! -iregex '.*(vosk|yake|vtt2text)\.txt$' -exec sh -c 'yake -t 100 -i  "$0" >"$0_yake.txt"' {} \;
find . -iname '*\.en\.txt' -exec mv '{}' '{}'.vtt2text.txt \;



else


echo `date` "DEBUG: URL NOT Youtube ripping audio"
export filename=`youtube-dl  --get-filename -o "%(title)s.wav" "${i}"`
youtube-dl --extract-audio --audio-format wav  --postprocessor-args "-ac 1"  -o "%(title)s.wav" "${i}"

echo `date` "DEBUG: Convert wav to text with vosk"
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



fi



done < in
