curl -s https://archive.org/services/collection-rss.php\?collection\=hackerpublicradio | grep -iPo '(?<=media:content url=")\w+.*(?=" type)' > in

apt-get install aria2 -y
aria2c --file-allocation=none -c -x 16 -s 16 -d "./" -i in
