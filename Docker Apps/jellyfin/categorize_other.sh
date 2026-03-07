#!/bin/bash

BASE_DIR="/mnt/hgst-1tb/MEDIA/Movies"

# Function to safely move movie directories
safe_move() {
    local source_dir="$1"
    local target_parent="$2"
    local movie_name=$(basename "$source_dir")
    local target_dir="$target_parent/$movie_name"

    if [ -d "$target_dir" ]; then
        echo "  -> '$movie_name' already exists in $(basename $target_parent). Merging..."
        find "$source_dir" -mindepth 1 -maxdepth 1 -exec mv -t "$target_dir/" {} +
        rmdir "$source_dir" 2>/dev/null
    else
        echo "  -> Moving '$movie_name' to $(basename $target_parent)/"
        mv "$source_dir" "$target_parent/"
    fi
}

echo "Carefully categorizing movies from 'Other'..."

# Step 1: Handle Hollywood_Other first (all go to Hollywood)
if [ -d "$BASE_DIR/Hollywood_Other/Normal" ]; then
    echo "Processing Hollywood_Other..."
    for dir in "$BASE_DIR/Hollywood_Other/Normal"/*; do
        [ -d "$dir" ] && safe_move "$dir" "$BASE_DIR/Hollywood/Normal"
    done
    rmdir "$BASE_DIR/Hollywood_Other/Normal" 2>/dev/null
    rmdir "$BASE_DIR/Hollywood_Other" 2>/dev/null
fi

# Step 2: Categorize 'Other' folder
if [ -d "$BASE_DIR/Other" ]; then
    echo "Processing 'Other'..."
    for dir in "$BASE_DIR/Other"/*; do
        if [ -d "$dir" ]; then
            movie_name=$(basename "$dir")
            movie_lower=$(echo "$movie_name" | tr '[:upper:]' '[:lower:]')
            
            # BOLLYWOOD MATCHES
            if [[ "$movie_lower" == *"hindi"* ]] || \
               [[ "$movie_lower" == *"bollywood"* ]] || \
               [[ "$movie_lower" == *"awara"* ]] || \
               [[ "$movie_lower" == *"cocktail"* ]] || \
               [[ "$movie_lower" == *"kesari"* ]] || \
               [[ "$movie_lower" == *"mughal-e-azam"* ]] || \
               [[ "$movie_lower" == *"no one killed jessica"* ]] || \
               [[ "$movie_lower" == *"ramayana"* ]] || \
               [[ "$movie_lower" == *"rang de basanti"* ]] || \
               [[ "$movie_lower" == *"satyamev jayate"* ]] || \
               [[ "$movie_lower" == *"tanu weds manu"* ]] || \
               [[ "$movie_lower" == *"iditos"* ]] || \
               [[ "$movie_lower" == *"shaqzaadey"* ]]; then
               
                safe_move "$dir" "$BASE_DIR/Bollywood/Normal"
            
            # SOUTH INDIAN MATCHES
            elif [[ "$movie_lower" == *"telugu"* ]] || \
                 [[ "$movie_lower" == *"tamil"* ]] || \
                 [[ "$movie_lower" == *"kannada"* ]] || \
                 [[ "$movie_lower" == *"malayalam"* ]] || \
                 [[ "$movie_lower" == *"amma nanna"* ]] || \
                 [[ "$movie_lower" == *"anand full"* ]] || \
                 [[ "$movie_lower" == *"aneethi"* ]] || \
                 [[ "$movie_lower" == *"bahadhur"* ]] || \
                 [[ "$movie_lower" == *"bahubaali"* ]] || \
                 [[ "$movie_lower" == *"bhaktha prahlada"* ]] || \
                 [[ "$movie_lower" == *"brother ("* ]] || \
                 [[ "$movie_lower" == *"choo mantar"* ]] || \
                 [[ "$movie_lower" == *"current ("* ]] || \
                 [[ "$movie_lower" == *"daddy telugu"* ]] || \
                 [[ "$movie_lower" == *"godavari"* ]] || \
                 [[ "$movie_lower" == *"indra"* ]] || \
                 [[ "$movie_lower" == *"jayam"* ]] || \
                 [[ "$movie_lower" == *"kanchana"* ]] || \
                 [[ "$movie_lower" == *"kuladalli"* ]] || \
                 [[ "$movie_lower" == *"kushi"* ]] || \
                 [[ "$movie_lower" == *"lava kusa"* ]] || \
                 [[ "$movie_lower" == *"little hearts"* ]] || \
                 [[ "$movie_lower" == *"love and love not"* ]] || \
                 [[ "$movie_lower" == *"mahavatar"* ]] || \
                 [[ "$movie_lower" == *"malli malli"* ]] || \
                 [[ "$movie_lower" == *"malliswari"* ]] || \
                 [[ "$movie_lower" == *"manada"* ]] || \
                 [[ "$movie_lower" == *"manasantha"* ]] || \
                 [[ "$movie_lower" == *"mr. perfect"* ]] || \
                 [[ "$movie_lower" == *"murari"* ]] || \
                 [[ "$movie_lower" == *"nuvvu leka"* ]] || \
                 [[ "$movie_lower" == *"pawan kalyan"* ]] || \
                 [[ "$movie_lower" == *"pizza"* ]] || \
                 [[ "$movie_lower" == *"radhaamadhavam"* ]] || \
                 [[ "$movie_lower" == *"raja rani"* ]] || \
                 [[ "$movie_lower" == *"rajini"* ]] || \
                 [[ "$movie_lower" == *"rangam"* ]] || \
                 [[ "$movie_lower" == *"sampathige"* ]] || \
                 [[ "$movie_lower" == *"sankranti"* ]] || \
                 [[ "$movie_lower" == *"santosham"* ]] || \
                 [[ "$movie_lower" == *"shankar dada"* ]] || \
                 [[ "$movie_lower" == *"sura sundaranga"* ]] || \
                 [[ "$movie_lower" == *"thaandavam"* ]] || \
                 [[ "$movie_lower" == *"thadakha"* ]] || \
                 [[ "$movie_lower" == *"ughram"* ]] || \
                 [[ "$movie_lower" == *"vaana"* ]] || \
                 [[ "$movie_lower" == *"ondu sarala"* ]] || \
                 [[ "$movie_name" == *"జయం"* ]] || \
                 [[ "$movie_name" == *"అమ్మ నాన్న"* ]] || \
                 [[ "$movie_name" == *"మురారి"* ]] || \
                 [[ "$movie_name" == *"పిజ్జా"* ]] || \
                 [[ "$movie_name" == *"ಸುರಸುಂದರಾಂಗ"* ]]; then
                 
                safe_move "$dir" "$BASE_DIR/South_Indian/Normal"
                
            # ASIAN CINEMA MATCHES
            elif [[ "$movie_lower" == *"36th chamber"* ]] || \
                 [[ "$movie_lower" == *"his motorbike, her island"* ]]; then
                safe_move "$dir" "$BASE_DIR/Asian_Cinema/Normal"

            # DEFAULT TO HOLLYWOOD
            else
                safe_move "$dir" "$BASE_DIR/Hollywood/Normal"
            fi
        fi
    done
    rmdir "$BASE_DIR/Other" 2>/dev/null
fi

echo "Phase 2 Smart Categorization Complete!"
