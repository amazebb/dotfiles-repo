#!/bin/bash

ffprobe -i "$1" -v quiet -show_chapters -print_format compact 
