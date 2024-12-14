# Note the end of line is \ no spaces etc ...
curl --path-as-is -i -s -k -X $'GET' \
    -H $'Host: flickmetrix.com' -H $'Response: application/json' -H $'Sec-Ch-Ua-Platform: \"Windows\"' -H $'Accept-Language: en-US,en;q=0.9' -H $'Accept: application/json, text/plain, */*' -H $'Sec-Ch-Ua: \"Chromium\";v=\"131\", \"Not_A Brand\";v=\"24\"' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6778.86 Safari/537.36' -H $'Sec-Ch-Ua-Mobile: ?0' -H $'Sec-Fetch-Site: same-origin' -H $'Sec-Fetch-Mode: cors' -H $'Sec-Fetch-Dest: empty' -H $'Referer: https://flickmetrix.com/movies' -H $'Accept-Encoding: gzip, deflate, br' -H $'Priority: u=1, i' \
    $'https://flickmetrix.com/api2/values/getFilms?amazonRegion=us&cast=&comboScoreMax=100&comboScoreMin=61&countryCode=us&criticRatingMax=100&criticRatingMin=0&criticReviewsMax=1000&criticReviewsMin=0&currentPage=2&deviceID=1&director=&excludeGenres=horror&format=movies&genreAND=false&googleScoreMax=100&googleScoreMin=0&imdbRatingMax=10&imdbRatingMin=0&imdbVotesMax=2800000&imdbVotesMin=0&inCinemas=true&includeDismissed=false&includeSeen=false&includeWantToWatch=true&isCastSearch=false&isDirectorSearch=false&isPersonSearch=false&language=all&letterboxdScoreMax=100&letterboxdScoreMin=0&letterboxdVotesMax=2000000&letterboxdVotesMin=0&metacriticRatingMax=100&metacriticRatingMin=0&metacriticReviewsMax=100&metacriticReviewsMin=0&onAmazonPrime=false&onAmazonVideo=false&onDVD=false&onNetflix=false&pageSize=100&path=%2Fmovies&person=&plot=&queryType=GetFilmsToSieve&searchTerm=&sharedUser=&sortOrder=metacriticRatingDesc&title=&token=&watchedRating=0&writer=&yearMax=2024&yearMin=2024' \
  --compressed | \
awk '{gsub(",\\\\\"","\n"); print}'| \
grep -E "(Title|Trailer|Genre|PosterPath|Cast|imdbRating|Plot)"  | \
sed -r \
-e 's/[\\]//g' \
-e 's/PosterPath\":\"(.*)\"/<img width=30% src=https:\/\/image.tmdb.org\/t\/p\/w342\1>/g' \
-e 's/Trailer\":\"(.*)\"/<a target=_blank href=\"https:\/\/www\.youtube\.com\/watch\?v=\1\">Trailer<\/a>/g' \
-e 's/Title/<hr>Title/g' \
-e 's/$/<br>/g' > /rmccurdy/.scripts/MOVIES.html
