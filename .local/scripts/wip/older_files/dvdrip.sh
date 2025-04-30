#!/bin/bash

# This script takes ripped DVD files such as MKV, and creates audio and video files for each chapter
# makemkv_v1.10.2 was used to extract DVD

#### BEGIN: Requirements ####
# The chapters should look like below using ffprobe, if not then the below script needs to be modified to
# get the corect start and end times.
#
# ffprobe -i title00.mkv -v quiet -show_chapters -print_format compact | grep -n 'start_time=.*|t'
#
# 1:chapter|id=-435262111|time_base=1/1000000000|start=0|start_time=0.000000|end=76643233333|end_time=76.643233|tag:title=Chapter 01
# 2:chapter|id=-1646324549|time_base=1/1000000000|start=76643233333|start_time=76.643233|end=566699466666|end_time=566.699467|tag:title=Chapter 02
#### END: Requirements ####

# USEAGE: Rip all the MKV files in the current folder to \video and \audio subfolders
# dvdrip "*.mkv"

#   - Extracts the audio and encodes as 2ch AAC VBR 5 into \audio folder.
#     The files are labeled ch<M>_M.m4a corresponding to the M'th MKV file and N'th chapter.
#
#   - Extracts the chapters copying all streams uncompressed into separate \video folder

rip() {

  local file=$1
  local ch=$2

  local replace=(ffmpeg -i "$file" -hide_banner
    "$t" -map $dts -map $vid -c:a $ca -c:v $cv "lossy\/video\/ch$ch\_\1.mp4"
    "$t" -map $dts -c:a $ca -ac 2 "lossy\/audio\/down2ch\/ch$ch\_\1.mp4"
    "$t" -map $pcm -c:a $ca -ac 2 "lossy\/audio\/pcm\/ch$ch\_\1.mp4")

  local rep="${replace[@]}"

  run=$(ffprobe -i "$file" -v quiet -show_chapters -print_format compact |
    grep -n 'start_time=.*|t' |
    sed "s/\([0-9]*\).*start_time=\([0-9]*.[0-9]*\).*end_time=\([0-9]*.[0-9]*\).*/$rep/g ")

  if [ -n "$run" ]; then
    eval "$run"
  else
    # simple extract
  fi

}

trap "exit" INT

mkdir lossless
mkdir lossy lossy/audio lossy/video lossy/audio/pcm lossy/audio/down2ch

pcm="0:1"
dts="0:2"
vid="0:0"
t='-ss \2 -to \3'
ca="libfdk_aac -vbr 5"
cv="libx264 -crf 28 -preset fast"
copy="-c:a copy -c:v copy"

j=1

for f in $1; do
  rip "$f" "$j"
  ((j = j + 1))
done
