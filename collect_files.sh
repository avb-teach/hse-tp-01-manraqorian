#!/bin/bash

input_dir="$1"
output_dir="$2"

copy_files() {
  local source_dir="$1"

  find "$source_dir" -type f -print0 | while IFS= read -r -d $'\0' file; do
    filename=$(basename "$file")

    output_file="$output_dir/$filename"
    i=1
    while [ -f "$output_file" ]; do
      name="${filename%.*}"
      ext="${filename##*.}"
      output_file="$output_dir/${name}_${i}.${ext}"
      i=$((i+1))
    done

    cp "$file" "$output_file"
  done
}

process_directory() {
  local dir="$1"

  copy_files "$dir"

  find "$dir" -type d -print0 | while IFS= read -r -d $'\0' subdir; do
    if [ "$subdir" != "$dir" ]; then
      process_directory "$subdir"
    fi
  done
}

process_directory "$input_dir"
