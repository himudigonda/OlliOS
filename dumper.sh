#!/bin/bash
# This script was used to dump code. No changes needed.
# Keep it as is.
# If desired, you can remove or keep this script.

process_file() {
    local file=$1
    if [[ $file == *"/__pycache__/"* ]] ||
        [[ $file == */.git/* ]] ||
        [[ $file == *"/xcuserdata/"* ]] ||
        [[ $file == *"/DerivedData/"* ]] ||
        [[ $file == *"/build/"* ]] ||
        [[ $file == *".DS_Store"* ]] ||
        [[ $file == *".pytest_cache/"* ]]; then
        return
    fi
    if [ -d "$file" ]; then
        for f in "$file"/*; do
            process_file "$f"
        done
    elif [ -f "$file" ]; then

        echo "=== File: $file ==="
        echo "----------------------------------------"
        cat "$file"
        echo -e "\n----------------------------------------\n"
    fi
}

process_file "."
