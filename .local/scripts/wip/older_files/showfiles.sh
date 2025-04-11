#!/bin/bash
#toggle AppleShowAllFiles

current_value=$(defaults read com.apple.finder AppleShowAllFiles)

if [ $current_value = "TRUE" ]; then
  defaults write com.apple.finder AppleShowAllFiles FALSE
else
  defaults write com.apple.finder AppleShowAllFiles TRUE
fi

killall Finder

current_value=$(defaults read com.apple.finder AppleShowAllFiles)
echo "Current value is $current_value"
