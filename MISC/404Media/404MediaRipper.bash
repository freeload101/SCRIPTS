#!/bin/bash

# replace a44XXXXXXXXXX3 with your private rss feed ID ! 
curl -s "https://subscribers.transistor.fm/a44XXXXXXXXXX3" | \
xmlstarlet sel -t -m "//item" \
  -v "concat(translate(podcast:episode, ' /', '_-'), '_', itunes:title, '.mp3')" -n \
  -v "enclosure/@url" -n | \
while read -r filename && read -r url; do
  [ -n "$url" ] && curl -L -o "$filename" "$url"
done
