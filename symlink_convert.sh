#!/bin/bash
# Edit path to target directory
directory_path="/data"

process_directory() {
    local dir="$1"
    local current_dir
  
    find "$dir" -type l -exec bash -c '
        target=$(readlink "$0")

        if [[ "$target" == /* ]]; then
            link_dir=$(dirname "$0")

            ln -sf "$(realpath --relative-to="$link_dir" "$target")" "$0"
        fi
    ' {} \;
  
    while IFS= read -r -d '' current_dir; do
        process_directory "$current_dir"
    done < <(find "$dir" -mindepth 1 -type d -print0)
}

process_directory "$directory_path"
