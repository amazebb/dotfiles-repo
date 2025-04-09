#!/bin/bash

wma2alac_aac () {

    # Add title to bash terminal
    echo -n -e "\033]0;Converting WMA to M4A ...\\007";

    local f=$1
    local ROOTFOLDER=$2
    local EXISTCOVER=1 

    # Get cover art by looking for jpegs or gifs in the current folder
    if [ -a *.jpg ] 
    then  
        cover=*.jpg
    elif [ -a *.jpeg ]
    then
        cover=*.jpeg
    elif [ -a *.gif ]
    then
        cover=*.gif 
    else
        EXISTCOVER=0
    fi

    # Extract the metadata
    ffmpeg -y -loglevel quiet -i "$f" -f ffmetadata "${f%.*}_meta.txt";

    # Replace WMA tags with there AAC equivalents
    sed -e 's:WM/Year:date:' -e  \
        's:WM/Lyrics:lyrics:' -e \
        '/^WM/d' -e \
        '/DeviceConformanceTemplate/d' -e \
        '/IsVBR/d' -e \
        '/comment/d' -e \
        '/encoder/d' <"${f%.*}_meta.txt" >"${f%.*}_meta2.txt";

    artist=$(grep "^artist=" "${f%.*}"_meta2.txt | sed s/artist=//) 
    album=$(grep "^album=" "${f%.*}"_meta2.txt | sed s/album=//)

    FOLDER="${ROOTFOLDER}/lossless"                 
    FOLDERA=$FOLDER/$artist
    FOLDERDIR=$FOLDERA/$album

    if [ ! -d "$FOLDERDIR" ] 
    then
        mkdir -p "$FOLDERDIR"
    fi


    # Transcode to ALAC and add the new tags 
    ffmpeg -y -loglevel quiet -i "$f" -i "${f%.*}_meta2.txt" -map_metadata 1 -c:a alac "${f%.*}.m4a";

    # Add cover art to the ALAC file
    if [ EXISTCOVER == 1 ]
    then 
        mp4art --add $cover "${f%.*}.m4a"
    fi

    ##
    ## This is the lossy AAC section
    ##

    # Make sure lossy folder exists
    LOSSY="${ROOTFOLDER}/lossy"
    LOSSYA=$LOSSY/$artist
    LOSSYDIR=$LOSSYA/$album


    if [ ! -d "$LOSSYDIR" ]
    then
        mkdir -p "$LOSSYDIR"
    fi


    # Convert to lossy AAC using afconvert
    #
    # https://developer.apple.com/library/mac/technotes/tn2271/_index.html 
    #
    # -ue needed for VBR
    # -vbrq for VBR with quality in the range 0...127 (90 is ~ 190kbps and sounds fine on iPod touch 5g)
    # -s (0=CBR 1=ABR 2=VBR_constrained 3=VBR)  
    afconvert "${f%.*}.m4a" -d aac -f m4af -ue vbrq 90 -s 3 "$LOSSYDIR/${f%.*}.m4a"

    # Add cover art to lossy AAC file
    if [ EXISTCOVER == 1 ]
    then 
        mp4art --add $cover "$LOSSYDIR/${f%.*}.m4a"
    fi

    # Add the meta data to the lossy AAC as afconvert does not copy over tags
    ffmpeg -y -loglevel quiet -i "$LOSSYDIR/${f%.*}.m4a" -i "${f%.*}_meta2.txt" -map_metadata 1 -c:a copy "$LOSSYDIR/${f%.*}.m4a2";

    # Remove meta data files 
    rm -f "${f%.*}_meta.txt"
    rm -f "${f%.*}_meta2.txt"

}

# Loop through each file and convert
for f in *.wma; 
do
    wma2alac_aac "$f"  &
done

wait

# reset the bash terminal title
echo -n -e "\033]0;bash\\007"
