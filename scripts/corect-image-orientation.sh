#!/bin/bash

# script inspired by the answer to this question on Super User:
# https://superuser.com/questions/965233/scaling-and-rotation-of-image-without-depending-on-exif-data

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "ImageMagick is not installed. Please install it first with \"brew install imagemagick.\""
    exit 1
fi

# Check if an image file is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <image_file>"
    exit 1
fi

# Get the input image file
image_file="$1"

# Check if the image file exists
if [ ! -f "$image_file" ]; then
    echo "Image file '$image_file' does not exist."
    exit 1
fi

# Correct the image orientation using ImageMagick
output_file="${image_file%.*}_corrected.${image_file##*.}"
magick "$image_file" -auto-orient "$output_file"

echo "Image orientation corrected. The corrected image is saved as '$output_file'."