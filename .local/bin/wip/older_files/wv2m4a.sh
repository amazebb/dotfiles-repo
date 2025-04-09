#!/bin/bash

f=$1

# Extract the metadata
ffmpeg -y -loglevel quiet -i "$f" -f ffmetadata "${f%.*}_meta.txt"

# Replace WMA tags with there AAC equivalents
sed -e 's:WM/Year:date:' -e \
	's:WM/Lyrics:lyrics:' -e \
	'/^WM/d' -e \
	'/DeviceConformanceTemplate/d' -e \
	'/IsVBR/d' -e \
	'/comment/d' -e \
	'/encoder/d' <"${f%.*}_meta.txt" >"${f%.*}_meta2.txt"

artist=$(grep "^artist=" "${f%.*}"_meta2.txt | sed s/artist=//)
album=$(grep "^album=" "${f%.*}"_meta2.txt | sed s/album=//)

ffmpeg -y -loglevel quiet -i "$f" -i "${f%.*}_meta2.txt" -map_metadata 1 -c:a alac "${f%.*}.m4a"
