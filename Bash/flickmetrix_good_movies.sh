# Note the end of line is \ no spaces etc ...
curl -s 'https://flickmetrix.com/api2/values/getFilms?amazonRegion=us&cast=&comboScoreMax=100&comboScoreMin=61&countryCode=us&criticRatingMax=100&criticRatingMin=0&criticReviewsMax=1000&criticReviewsMin=0&currentPage=0&deviceID=1&director=&excludeGenres=horror&format=movies&genreAND=false&imdbRatingMax=10&imdbRatingMin=0&imdbVotesMax=2600000&imdbVotesMin=0&inCinemas=true&includeDismissed=false&includeSeen=false&includeWantToWatch=true&isCastSearch=false&isDirectorSearch=false&isPersonSearch=false&language=en&letterboxdScoreMax=100&letterboxdScoreMin=0&letterboxdVotesMax=1200000&letterboxdVotesMin=0&metacriticRatingMax=100&metacriticRatingMin=0&metacriticReviewsMax=100&metacriticReviewsMin=0&onAmazonPrime=false&onAmazonVideo=false&onDVD=false&onNetflix=false&pageSize=100&person=&plot=&queryType=GetFilmsToSieve&searchTerm=&sharedUser=&sortOrder=dateDesc&title=&token=&watchedRating=0&writer=&yearMax=2022&yearMin=2022' \
  --compressed | \
awk '{gsub(",\\\\\"","\n"); print}'| \
grep -E "(Title|Trailer|Genre|PosterPath|Cast|imdbRating|Plot)"  | \
sed -r \
-e 's/[\\]//g' \
-e 's/PosterPath\":\"(.*)\"/<img width=30% src=https:\/\/image.tmdb.org\/t\/p\/w342\1>/g' \
-e 's/Trailer\":\"(.*)\"/<a target=_blank href=\"https:\/\/www\.youtube\.com\/watch\?v=\1\">Trailer<\/a>/g' \
-e 's/Title/<hr>Title/g' \
-e 's/$/<br>/g' > /rmccurdy/.scripts/MOVIES.html
