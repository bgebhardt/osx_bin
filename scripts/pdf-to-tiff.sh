#!/bin/sh
# Converts PDF files to TIFF files suitible for antiquated systems.
# Usage:
#   $ pdf-to-tiff.sh file1 file2
#
# Installation:
#   $ brew install ghostscript
#   $ brew install libtiff
#   $ brew install --fresh --build-from-source imagemagick --with-libtiff
#
for file in $@; do
  dir=tiff_${file%.pdf}
  mkdir $dir

  echo "Converting $file to $dir"
  for page in `identify $file | sed -e 's/\].*$/\]/'`; do
    convert -format "tiff" -density 72 -compress lzw -depth 8 -colorspace Gray "$page" "$dir/%d.tif"
  done
done
