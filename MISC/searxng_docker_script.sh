
# backup /etc/searxng/settings.yml
cp /etc/searxng/settings.yml /etc/searxng/settings.yml.bak

# remove comments etc but not the secret!!
grep -Ev '(^#|^\s+#)' /etc/searxng/settings.yml > ./settings.yml

# set my settings!
sed 's/simple_style: auto/simple_style: dark/g'  ./settings.yml  -i.bak 
sed 's/infinite_scroll: false/infinite_scroll: true/g'  ./settings.yml  -i.bak 
sed 's/debug: false/debug: true/g'  ./settings.yml  -i.bak 
sed 's/query_in_title: false/query_in_title: true/g'  ./settings.yml  -i.bak 
sed 's/infinite_scroll: false/infinite_scroll: true/g'  ./settings.yml  -i.bak 


# remove google 
# can't get this to work for the life of me !!! 
# remove google by hand and enable bing ... ?!? 
# sed '/- name: google./,/shortcut: gos./d' ./settings.yml   -i.bak 

# overwrite config
cp ./settings.yml  /etc/searxng/settings.yml 

# replace PNG
wget 'https://github.com/freeload101/SCRIPTS/blob/master/MISC/searxng.png?raw=true' -O ./searxng.png
find / -iname "searxng.png" -exec cp ./searxng.png '{}' \;
find / -iname "favicon.png" -exec cp ./searxng.png '{}' \;

# replace logo with mine
sed '/<div id=\"search_header\">/,/<\/a>/s/.*/NULL/'  /usr/local/searxng/searx/templates/simple/search.html | uniq | sed 's/NULL/<a id=\"search_logo\" href=\"\/" tabindex=\"0\"><img height=\"40\"src=\".\/static\/themes\/simple\/img\/searxng.png\"><\/a>/g' > ./search.html
cp ./search.html   /usr/local/searxng/searx/templates/simple/search.html
