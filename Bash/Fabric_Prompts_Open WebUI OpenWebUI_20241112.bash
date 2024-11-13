for i in `cat WIPE.txt`
do

echo TITLE: $i

curl --path-as-is -i -k -X $'DELETE' \
    -H $'Host: gpt.xn--neellco-cvb.com' -H $'Sec-Ch-Ua-Platform: \"Windows\"' -H $'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImQzMzc3ZDFkLTlkMjItNGZmZC1iZGMyLTJkYjA4MWMzNDNlNiJ9.a-jTEdYWdrLBYM5NVUMy0P53Hg6tZ2nxdKzcL6LrroI' -H $'Accept-Language: en-US,en;q=0.9' -H $'Sec-Ch-Ua: \"Not?A_Brand\";v=\"99\", \"Chromium\";v=\"130\"' -H $'Sec-Ch-Ua-Mobile: ?0' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.6723.70 Safari/537.36' -H $'Accept: application/json' -H $'Content-Type: application/json' -H $'Origin: https://gpt.xn--neellco-cvb.com' -H $'Sec-Fetch-Site: same-origin' -H $'Sec-Fetch-Mode: cors' -H $'Sec-Fetch-Dest: empty' -H $'Referer: https://gpt.xn--neellco-cvb.com/workspace/prompts' -H $'Accept-Encoding: gzip, deflate, br' -H $'Priority: u=1, i' -H $'Connection: keep-alive' \
    -b $'token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImQzMzc3ZDFkLTlkMjItNGZmZC1iZGMyLTJkYjA4MWMzNDNlNiJ9.a-jTEdYWdrLBYM5NVUMy0P53Hg6tZ2nxdKzcL6LrroI' \
    "https://gpt.xn--neellco-cvb.com/api/v1/prompts/command/$i/delete" &
	sleep .01
done