find . -iname "index.jsp" -exec sed 's/\"home\.view\"/\"home\.view\?listSize=200\&listType=newest\"/g'  -i.bak   '{}' \;
