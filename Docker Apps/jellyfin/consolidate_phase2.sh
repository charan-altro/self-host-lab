#!/bin/bash

BASE_DIR="/mnt/hgst-1tb/MEDIA/Movies"

echo "Applying Phase 2 Consolidation Fixes..."

# 1. Fix the "Directory not empty" errors from Hollywood_Other -> Hollywood
echo "Merging remaining Hollywood_Other folders..."
for movie_dir in "$BASE_DIR/Hollywood_Other/Normal"/*; do
    if [ -d "$movie_dir" ]; then
        movie_name=$(basename "$movie_dir")
        
        # If the folder already exists in the destination, we merge the contents instead of moving the whole folder.
        if [ -d "$BASE_DIR/Hollywood/Normal/$movie_name" ]; then
            echo "  -> Merging files for '$movie_name'"
            find "$movie_dir" -mindepth 1 -maxdepth 1 -exec mv -t "$BASE_DIR/Hollywood/Normal/$movie_name/" {} +
            rmdir "$movie_dir" 2>/dev/null
        else
            echo "  -> Moving folder '$movie_name'"
            mv "$movie_dir" "$BASE_DIR/Hollywood/Normal/"
        fi
    fi
done
# Clean up Hollywood_Other
rmdir "$BASE_DIR/Hollywood_Other/Normal" 2>/dev/null
rmdir "$BASE_DIR/Hollywood_Other" 2>/dev/null

# 2. Merge the massive "Other" folder into Hollywood/Normal
# The "Other" folder contains 100+ loose movies that are almost entirely Hollywood/Western.
echo "Moving 'Other' movies into 'Hollywood/Normal'..."
for movie_dir in "$BASE_DIR/Other"/*; do
    if [ -d "$movie_dir" ]; then
        movie_name=$(basename "$movie_dir")
        
        # If the folder already exists in Hollywood/Normal, merge contents
        if [ -d "$BASE_DIR/Hollywood/Normal/$movie_name" ]; then
            echo "  -> Merging files into existing '$movie_name'"
            find "$movie_dir" -mindepth 1 -maxdepth 1 -exec mv -t "$BASE_DIR/Hollywood/Normal/$movie_name/" {} +
            rmdir "$movie_dir" 2>/dev/null
        else
            echo "  -> Moving '$movie_name'"
            mv "$movie_dir" "$BASE_DIR/Hollywood/Normal/"
        fi
    fi
done
# Clean up Other
rmdir "$BASE_DIR/Other" 2>/dev/null

echo "Phase 2 Complete! Your structure is now perfectly optimized into 4 main categories."
