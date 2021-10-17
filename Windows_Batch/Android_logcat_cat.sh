Echo "This script will parse all .txt files in the current path and pull the top 10 uniq events with count and then show the top 10 uniq details of each."
echo "TODO: remove all timestamps for top 10 so you actualy get all the top 10 and not just the first 10 because of timestamps are uniq!"

for i in `sed -rn 's/.*([A-Z]\/.*)]/\1/p' *.txt | sort | uniq -c | sort -nr | head -n 10|awk '{print $2}'`
do
echo '################################################################################################'
echo Searching for "${i}"
sleep 2
CountLines=`grep "${i}" --no-group-separator -A 1 *.txt | grep -v "${i}"|wc -l`
echo Found "${CountLines}" lines for "${i}" show first 10 uniq with count
sleep 2
grep "${i}" --no-group-separator -A 1 *.txt | grep -v "${i}" | sort | uniq -c | sort -nr|head -n 10 
done
