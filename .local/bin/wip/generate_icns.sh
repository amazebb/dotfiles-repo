#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to handle PNG files using sips
generate_from_png() {
    # Input file has to be 1024x1024 PNG
    local input_file="$1"
    local iconset_dir="$2"

    echo "Generating iconset from PNG..."
    sips -z 16 16 "$input_file" --out "$iconset_dir/icon_16x16.png"
    sips -z 32 32 "$input_file" --out "$iconset_dir/icon_16x16@2x.png"
    sips -z 32 32 "$input_file" --out "$iconset_dir/icon_32x32.png"
    sips -z 64 64 "$input_file" --out "$iconset_dir/icon_32x32@2x.png"
    sips -z 64 64 "$input_file" --out "$iconset_dir/icon_64x64.png"
    sips -z 128 128 "$input_file" --out "$iconset_dir/icon_64x64@2x.png"
    sips -z 128 128 "$input_file" --out "$iconset_dir/icon_128x128.png"
    sips -z 256 256 "$input_file" --out "$iconset_dir/icon_128x128@2x.png"
    sips -z 256 256 "$input_file" --out "$iconset_dir/icon_256x256.png"
    sips -z 512 512 "$input_file" --out "$iconset_dir/icon_256x256@2x.png"
    sips -z 512 512 "$input_file" --out "$iconset_dir/icon_512x512.png"
    cp "$input_file" "$iconset_dir/icon_512x512@2x.png"
}

# Function to handle SVG files using ImageMagick
generate_from_svg() {
    local input_file="$1"
    local iconset_dir="$2"

    echo "Generating iconset from SVG..."
    convert -resize 16x16 "$input_file" "$iconset_dir/icon_16x16.png"
    convert -resize 32x32 "$input_file" "$iconset_dir/icon_16x16@2x.png"
    convert -resize 32x32 "$input_file" "$iconset_dir/icon_32x32.png"
    convert -resize 64x64 "$input_file" "$iconset_dir/icon_32x32@2x.png"
    convert -resize 64x64 "$input_file" "$iconset_dir/icon_64x64.png"
    convert -resize 128x128 "$input_file" "$iconset_dir/icon_64x64@2x.png"
    convert -resize 128x128 "$input_file" "$iconset_dir/icon_128x128.png"
    convert -resize 256x256 "$input_file" "$iconset_dir/icon_128x128@2x.png"
    convert -resize 256x256 "$input_file" "$iconset_dir/icon_256x256.png"
    convert -resize 512x512 "$input_file" "$iconset_dir/icon_256x256@2x.png"
    convert -resize 512x512 "$input_file" "$iconset_dir/icon_512x512.png"
    convert -resize 1024x1024 "$input_file" "$iconset_dir/icon_512x512@2x.png"
}

# Main script logic
if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 <path-to-file> [iconset-name]"
    echo "The file can be a .png or .svg. The iconset-name is optional."
    exit 1
fi

input_file="$1"

# Derive the iconset directory name from the second argument or the input file name
if [[ $# -eq 2 ]]; then
    iconset_dir="./$2.iconset"
else
    # Derive the name by removing the file extension
    base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    iconset_dir="./${base_name}.iconset"
fi

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' not found."
    exit 1
fi

# Create the .iconset directory
mkdir -p "$iconset_dir"

# Determine the file type
file_type=$(file --mime-type -b "$input_file")

if [[ "$file_type" == "image/png" ]]; then
    generate_from_png "$input_file" "$iconset_dir"
elif [[ "$file_type" == "image/svg+xml" ]]; then
    generate_from_svg "$input_file" "$iconset_dir"
else
    echo "Error: Unsupported file type. Please provide a .png or .svg file."
    exit 1
fi

# Convert the iconset to .icns
echo "Converting iconset to .icns..."
iconutil -c icns "$iconset_dir"

# Cleanup
rm -r "$iconset_dir"
echo "Icon successfully created: ${iconset_dir}.icns"
