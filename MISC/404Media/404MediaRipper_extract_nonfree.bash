#!/bin/bash

# Define variables
#input_file="37_Shrimp Jesus.mp3"
#timestamp=3453.68
#output_file="37_Shrimp Jesus	anscript_nonfree_only.mp3"

# Use ffmpeg to cut the audio file from the specified timestamp to the end
#ffmpeg -i "$input_file" -ss $timestamp -c copy "$output_file"

IFS=$'\n'

for i in `ls ./mp3/*.mp3`
do
echo '================================================' 
echo "SUCCESS: $i"
export vartrim=`echo $i|sed 's/\.mp3/_transcript\.txt/g'|sed 's/\.\/mp3/\.\/transcripts/g'`
#echo "Vartrim: ${vartrim}"
#ls -laht ${vartrim}
grep -iaE "(the free version)" "${vartrim}" -A 1 | tr -d '\n' | grep -ia but

export varClip=`grep -iaE "(the free version)" "${vartrim}" -A 1 | tr -d '\n' | grep -ia but | awk '{print $1}' | sed 's/\[//g'`

#grep -iaE "(.*free version.*subscr.*|.*but.*subscri.*|.*free version.*but.*)" "${vartrim}" -A 1
#echo 'WARNING:'
#grep -iaE "(play us|free verson|paied|bonus)" "${vartrim}" -A 1

 
 
#read -p "Type a timestamp: " timestamp
export varbounspath=`echo $i|sed 's/\.\/mp3/\.\/BonusOnly/g'| sed 's/\.mp3/_Bonus_Audio_only\.mp3/g'`

#echo "WARNING: varbounspath: $varbounspath "


echo  ffmpeg -y -i "$i" -ss $varClip -c copy "${varbounspath}_Bonus_Audio_only.mp3"
ffmpeg -y -i "$i" -ss $varClip -c copy "${varbounspath}_Bonus_Audio_only.mp3"

done
exit
quit


#grep -A 1 | tr -d 
#subscriber
#.*free version.*subscr.*
#.*but.*subscri.*
 

FYI FFMPEG DOES NOT LIKE THESE EPS!!! 

#[mjpeg @ 0x60fc9e1e94c0] bits 250 is invalid
Error while decoding stream #0:1: Invalid data found when processing input
eps 41,42,43 



#[mp3 @ 0x59129b925980] dimensions not set
#Could not write header for output file #0 (incorrect codec parameters ?): Invalid argument
#Error initializing output stream 0:1 --
eps 44,46,47,48,49


