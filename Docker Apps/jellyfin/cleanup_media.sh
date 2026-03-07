#!/bin/bash

# Target directory where your movies are stored
MOVIES_DIR="/mnt/hgst-1tb/MEDIA/Movies"
# The new holding directory outside of Movies
HOLDING_DIR="/mnt/hgst-1tb/MEDIA/Holding_Area"

echo "Creating holding directory at $HOLDING_DIR..."
mkdir -p "$HOLDING_DIR"

# 1. Move the "others" folder containing home videos and clips
echo "Moving 'others' folder..."
if [ -d "$MOVIES_DIR/Other/others" ]; then
    mv "$MOVIES_DIR/Other/others" "$HOLDING_DIR/others_clips"
    echo "  -> Successfully moved to $HOLDING_DIR/others_clips"
else
    echo "  -> Note: 'others' folder not found. Skipping."
fi

# 2. Move the DVD Rip "cd" folder
echo "Moving DVD 'cd' folder..."
if [ -d "$MOVIES_DIR/Other/cd" ]; then
    mv "$MOVIES_DIR/Other/cd" "$HOLDING_DIR/DVD_RIP_cd"
    echo "  -> Successfully moved to $HOLDING_DIR/DVD_RIP_cd"
else
    echo "  -> Note: 'cd' folder not found. Skipping."
fi

# 3. Move the "bahubali trailer" folder
echo "Moving 'bahubali trailer' folder..."
if [ -d "$MOVIES_DIR/Tollywood/bahubali trailer" ]; then
    mv "$MOVIES_DIR/Tollywood/bahubali trailer" "$HOLDING_DIR/bahubali_trailers"
    echo "  -> Successfully moved to $HOLDING_DIR/bahubali_trailers"
else
    echo "  -> Note: 'bahubali trailer' folder not found. Skipping."
fi

echo "Cleanup complete! Your movies directory is now perfectly clean for Jellyfin."
