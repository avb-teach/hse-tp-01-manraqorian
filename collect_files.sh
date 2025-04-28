#!/bin/bash

input_dir="$1"
output_dir="$2"
max_depth=""

if [ "$3" == "--max_depth" ]; then
    max_depth="$4"
    shift 2
fi

collect_files() {
    local current_dir="$1"
    local current_depth="$2"

    if [ -n "$max_depth" ] && [ "$current_depth" -gt "$max_depth" ]; then
        return
    fi

    find "$current_dir" -maxdepth 1 -type f ! -path "$current_dir" -print0 | while IFS= read -r -d $'\0' file; do
        filename=$(basename "$file")

        output_file="$output_dir/$filename"
        if [ -f "$output_file" ]; then
            i=1
            name="${filename%.*}"
            ext="${filename##*.}"
            while [ -f "$output_dir/${name}_${i}.${ext}" ]; do
                i=$((i+1))
            done
            filename="${name}_${i}.${ext}"
        fi
        
        cp "$file" "$output_dir/$filename"
    done

    find "$current_dir" -maxdepth 1 -type d ! -path "$current_dir" -print0 | while IFS= read -r -d $'\0' dir; do
        next_depth=$((current_depth + 1))
        collect_files "$dir" "$next_depth"
    done
}


if [ -z "$input_dir" ] || [ -z "$output_dir" ]; then
    echo "Использование такого $0 <input_dir> <output_dir> [--max_depth <depth>]"
    exit 1
fi


collect_files "$input_dir" 1

