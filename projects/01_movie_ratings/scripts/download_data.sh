#!/usr/bin/env bash

set -e   # stop if any command fails

#----------------------
# Configuration
#----------------------
DATA_DIR="../data"
URL="https://files.grouplens.org/datasets/movielens/ml-latest-small.zip"
ZIP_FILE="ml-latest-small.zip"

#----------------------
# Create data directory
#----------------------

mkdir -p "$DATA_DIR"

#----------------------
# Download dataset
#----------------------
echo "Downloading MovieLens dataset..."
wget -O "$DATA_DIR/$ZIP_FILE" "$URL"

#----------------------
# UNzip dataset
#----------------------
echo "Unzipping dataset..."
unzip -o "$DATA_DIR/$ZIP_FILE" -d "$DATA_DIR"

#----------------------
# Cleanup
#----------------------
echo "Cleaning up zip files..."
rm "$DATA_DIR/$ZIP_FILE" 

echo "Download complete!"
