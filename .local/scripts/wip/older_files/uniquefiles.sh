#!/bin/bash
#
function helpfun {
  echo ""
  echo "UNIQUEFILES Find total number of each unique file and the storage space consumed"
  echo ""
  echo "Example: Find all unique filetypes"
  echo "  ~/bin/uniquefiles.sh"
  echo ""
  echo "Example: Find only FLAC and MP3 files"
  echo "  ~/bin/uniquefiles.sh  '*.flac' '*.mp3'"

}

[[ $@ ]] || {
  helpfun
  exit 1
}

filesummary() {

  # FILESUMMARY
  # For a filetype f, return the total size in MB, and the count of all such files

  local f=$1

  # FIND all the files of type f, then call LS to get the size of the file
  files=$(find . -type f -name "*.${f}" -exec ls -al {} \;)

  # - pipe to AWK and extract the 5th column
  # - create our expression using PASTE to ADD '+' signs between the sizes of each file
  #   ie: 123+345+....
  # - pipe to SED to return as megabytes by surrounding the expression
  #   with scale=n;(expression)/1024^2. n=number of decimal places
  # - finally call BC to do the actual calculation
  size=$(echo "$files" | awk '{print $5}' | paste -sd+ - | sed \
    s/^/scale=2\;\(/ | sed s/$/\)\\/1024^2/ | bc)

  # count the number of files by counting number of lines
  nfiles=$(echo "$files" | wc -l)

  # format the result nicely by piping to AWK
  ff=$(echo "$f $size $nfiles" | awk '{ printf "%-7s %-12s %-10s\n", $1, $2, $3}')

  # this is our returned value
  eval "$2='$ff'"
}

# Get filetype from user input

# declare our array index as an integer, we can increment using c+=1
declare -i c=0

# check to see if user input filetype arguments
if [ $# -gt 0 ]; then
  for ff in "$@"; do
    # FIND finds all files of the requested type, then
    # pipe to SED stripping out everything but the extension, then pipe to
    # SORT to  get unique filetypes
    files[c]=$(find . -type f -name "$ff" | sed 's|.*\.||' | sort -u)
    c+=1
  done
  # unwrap the array
  files=$(printf "%s\n" "${files[@]}")
else
  files=$(find . -type f -name '*.*' | sed 's|.*\.||' | sort -u)
fi

# declare our array index as an integer, we can increment using c+=1
declare -i c=0

for f in $files; do
  # because we cant return values from a function we create a dummy variable
  # returnvar, this will then be assigned within filesummary using eval
  returnvar=''

  # call our main function
  filesummary "$f" returnvar

  # add the file size and number information to our array
  a[c]=$returnvar

  # increment array index counter by one
  c+=1
done

# display header lines
echo
echo "File Size:MB NumFiles" | awk '{ printf "%-7s %-12s %-10s\n", $1, $2 ,$3}'
echo "---- ------- --------" | awk '{ printf "%-7s %-12s %-10s\n", $1, $2 ,$3}'

# print the array out
bar=$(printf "%s\n" "${a[@]}")

# SORT by megabyte, column (2), numeric (n), and in descending/reverse order (r)
echo "$bar" | sort -k +2nr
