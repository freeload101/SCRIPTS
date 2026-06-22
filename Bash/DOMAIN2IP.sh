lynx -width=999 -nolist -dump "https://crt.sh/?q=%25${1}%25" | awk '{gsub(" ","\n"); print}' | grep '\.' | sed 's/\*\.//g' | sort -u > tmp
nmap -n -T5 -sP -iL tmp -oA tmp
cat tmp.gnmap | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u
