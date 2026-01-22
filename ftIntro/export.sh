#!/bin/bash

# Configuration
INPUT_DIR="./videoFrames"
OUTPUT_DIR="./exports"
INPUT_PATTERN="frame-%06d.png" # Matches frame-000001.png, etc.

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# 1. Prompt for FPS
read -p "Enter FPS (e.g., 30, 60): " fps

# 2. Prompt for Video Name
read -p "Enter video name (without extension): " video_name

# Construct full output path
OUTPUT_FILE="${OUTPUT_DIR}/${video_name}.mp4"

echo "----------------------------------------"
echo "Starting render..."
echo "Input: ${INPUT_DIR}/${INPUT_PATTERN}"
echo "Output: ${OUTPUT_FILE}"
echo "----------------------------------------"

# 3. Execute ffmpeg
# -y                 : Overwrite output file if it exists
# -framerate "$fps"  : Set the input frame rate
# -i ...             : Input file pattern
# -c:v libx264       : Use H.264 codec (standard for mp4)
# -pix_fmt yuv420p   : Ensure compatibility with standard media players
ffmpeg -y -framerate "$fps" -i "${INPUT_DIR}/${INPUT_PATTERN}" \
    -c:v libx264 -pix_fmt yuv420p \
    "$OUTPUT_FILE"

# 4. Check success and cleanup
# $? stores the exit code of the last command (0 = success)
if [ $? -eq 0 ]; then
    echo "----------------------------------------"
    echo "✅ Success! Video saved to: $OUTPUT_FILE"
    
    echo "🗑️  Deleting image sequence in $INPUT_DIR..."
    rm "${INPUT_DIR}"/frame-*.png
    echo "Done."
else
    echo "----------------------------------------"
    echo "❌ Error: ffmpeg failed to generate the video."
    echo "⚠️  Image sequence has been PRESERVED for debugging."
    exit 1
fi
