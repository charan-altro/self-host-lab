#!/bin/bash

BASE_DIR="/mnt/hgst-1tb/MEDIA/Movies"

echo "Starting Media Consolidation..."

# -------------------------------------------------------------
# 1. First, create the 4 main structures
# -------------------------------------------------------------
echo "Creating base directory structures..."
mkdir -p "$BASE_DIR/Hollywood/Normal" "$BASE_DIR/Hollywood/Adults" "$BASE_DIR/Hollywood/Kids"
mkdir -p "$BASE_DIR/Bollywood/Normal" "$BASE_DIR/Bollywood/Adults" "$BASE_DIR/Bollywood/Kids"
mkdir -p "$BASE_DIR/South_Indian/Normal" "$BASE_DIR/South_Indian/Adults" "$BASE_DIR/South_Indian/Kids"
mkdir -p "$BASE_DIR/Asian_Cinema/Normal" "$BASE_DIR/Asian_Cinema/Adults" "$BASE_DIR/Asian_Cinema/Kids"

# Function to carefully move contents from Source to Destination
move_contents() {
    local src="$1"
    local dest="$2"
    
    # Only try to move if the source directory actually exists
    if [ -d "$src" ]; then
        echo "Moving everything from '$src' to '$dest'..."
        
        # We loop through checking if there are actually files to move to avoid bash * expansion errors
        # -A gives us all files/folders including hidden ones (but not . or ..)
        # Since we are low on storage (50GB free), we MUST use 'mv'.
        # 'mv' on the same drive doesn't copy data, it just instantly repoints the file table (0 bytes used).
        if [ "$(ls -A "$src" 2>/dev/null)" ]; then
            # Move everything inside the source folder to the destination folder
            # Note: We use find and exec to safely move files without hitting wildcard limits
            find "$src" -mindepth 1 -maxdepth 1 -exec mv -t "$dest/" {} +
            rmdir "$src"
        else
            echo "  -> '$src' is empty, just removing it."
            rmdir "$src"
        fi
    fi
}

# -------------------------------------------------------------
# 2. Fix the loose Tollywood movies first
# -------------------------------------------------------------
echo "Fixing loose Tollywood folders..."
# Move any folder in Tollywood that IS NOT Named Kids, Normal, or Adults into Normal.
find "$BASE_DIR/Tollywood" -mindepth 1 -maxdepth 1 -type d ! -name "Kids" ! -name "Normal" ! -name "Adults" | while read -r folder; do
    echo "  -> Moving '$folder' to Tollywood/Normal"
    # Ensure Tollywood/Normal exists
    mkdir -p "$BASE_DIR/Tollywood/Normal"
    mv "$folder" "$BASE_DIR/Tollywood/Normal/"
done

# -------------------------------------------------------------
# 3. Merge into HOLLYWOOD
# -------------------------------------------------------------
for sub in "Normal" "Kids" "Adults"; do
    move_contents "$BASE_DIR/Hollywood_Other/$sub" "$BASE_DIR/Hollywood/$sub"
    move_contents "$BASE_DIR/Other/$sub" "$BASE_DIR/Hollywood/$sub"
    move_contents "$BASE_DIR/World_Cinema/$sub" "$BASE_DIR/Hollywood/$sub"
    move_contents "$BASE_DIR/German_Cinema/$sub" "$BASE_DIR/Hollywood/$sub"
    move_contents "$BASE_DIR/Spanish_Cinema/$sub" "$BASE_DIR/Hollywood/$sub"
done
# Remove empty parent folders
rmdir "$BASE_DIR/Hollywood_Other" "$BASE_DIR/Other" "$BASE_DIR/World_Cinema" "$BASE_DIR/German_Cinema" "$BASE_DIR/Spanish_Cinema" 2>/dev/null

# -------------------------------------------------------------
# 4. Merge into SOUTH INDIAN
# -------------------------------------------------------------
for sub in "Normal" "Kids" "Adults"; do
    move_contents "$BASE_DIR/Tollywood/$sub" "$BASE_DIR/South_Indian/$sub"
    move_contents "$BASE_DIR/Kollywood/$sub" "$BASE_DIR/South_Indian/$sub"
    move_contents "$BASE_DIR/Sandalwood/$sub" "$BASE_DIR/South_Indian/$sub"
    move_contents "$BASE_DIR/Mollywood/$sub" "$BASE_DIR/South_Indian/$sub"
done
# Ensure that loose Premam folder is moved
if [ -d "$BASE_DIR/Kollywood/Premam (2015) - 720p mHD - Blu-Ray - x264 - 5.1 AAC - Esubs [DDR]" ]; then
    mv "$BASE_DIR/Kollywood/Premam (2015) - 720p mHD - Blu-Ray - x264 - 5.1 AAC - Esubs [DDR]" "$BASE_DIR/South_Indian/Normal/"
fi
# Remove empty parent folders
rmdir "$BASE_DIR/Tollywood" "$BASE_DIR/Kollywood" "$BASE_DIR/Sandalwood" "$BASE_DIR/Mollywood" 2>/dev/null

# -------------------------------------------------------------
# 5. Merge into ASIAN CINEMA
# -------------------------------------------------------------
for sub in "Normal" "Kids" "Adults"; do
    move_contents "$BASE_DIR/Hallyuwood/$sub" "$BASE_DIR/Asian_Cinema/$sub"
    move_contents "$BASE_DIR/J-Cinema/$sub" "$BASE_DIR/Asian_Cinema/$sub"
    move_contents "$BASE_DIR/C-Cinema/$sub" "$BASE_DIR/Asian_Cinema/$sub"
done
# Remove empty parent folders
rmdir "$BASE_DIR/Hallyuwood" "$BASE_DIR/J-Cinema" "$BASE_DIR/C-Cinema" 2>/dev/null

echo "============================================="
echo "Consolidation complete! Your structure is now:"
echo "1. Hollywood"
echo "2. Bollywood"
echo "3. South_Indian"
echo "4. Asian_Cinema"
echo "============================================="
