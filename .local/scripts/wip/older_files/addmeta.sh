#!/bin/bash

# Example
#./addmeta "*.mov" names.txt  ' -metadata author="Dire Straits" -metadata year="1983" -metadata album_artist="Dire Straits" -metadata album="Alchemy" -metadata comments="Alchemy DVD" '

{
  IFS=$'\n' # set field separator to be only newline

  # disbale globbing to prevent *. for instance being read in from files list and executed literally, i think thats what its for ?
  set -f

  # read track names from file into an arra, first () execute command and second () put into arrayy
  var=($(cat $2))
  # this will list var: printf '%s\n' "${var[@]}"

  # enable globbing so we can use *.mov input to the script for the files to process
  set +f
}

# declare file to be an array
declare -a file

# loop through input glob such as "*.mov" and store each file in file array
for f in $1; do
  file+=("$f")
done

# loop through and add metadata to each track
for ((c = 0; c < ${#file[@]}; c++)); do
  # get the file extension
  ext=${file[c]##*.}

  # use a leading zeros track number for the first part of new filename
  printf -v cf "%02d" $((c + 1))

  # add the metadata
  ffmpeg -i "${file[c]}" -c copy -metadata title="${var[c]}" -metadata track="$cf $3" "$cf ${var[c]}.$ext"
done
