#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$ROOT_DIR/gallery.json"
ALLOWED_EXT="jpg|jpeg|png|webp|gif|mp4"

emit_category() {
    local dir="$1"
    local name="$2"
    local -a entries=()

    while IFS= read -r -d '' filepath; do
        local filename ext
        filename="$(basename "$filepath")"
        ext="${filename##*.}"
        ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
        echo "$ext" | grep -qE "^($ALLOWED_EXT)$" || continue

        local relpath="${filepath#$ROOT_DIR/}"
        local media_type="image"
        [[ "$ext" == "mp4" ]] && media_type="video"

        entries+=("$(printf '        {"name": "%s", "path": "%s", "type": "%s", "ext": "%s"}' \
            "$filename" "$relpath" "$media_type" "$ext")")
    done < <(find "$dir" -maxdepth 1 -type f -print0 | sort -z)

    [[ ${#entries[@]} -eq 0 ]] && return 1

    if [[ "$first_category" == true ]]; then
        first_category=false
    else
        echo ','
    fi

    echo "    {"
    echo "      \"name\": \"$name\","
    echo "      \"files\": ["
    local i
    for i in "${!entries[@]}"; do
        if [[ $i -lt $((${#entries[@]} - 1)) ]]; then
            echo "${entries[$i]},"
        else
            echo "${entries[$i]}"
        fi
    done
    echo "      ]"
    echo -n "    }"
}

{
echo '{'
echo '  "categories": ['

first_category=true

for root_dir in pics gifs; do
    full_path="$ROOT_DIR/$root_dir"
    [[ -d "$full_path" ]] || continue

    emit_category "$full_path" "$root_dir" || true

    while IFS= read -r -d '' subdir; do
        emit_category "$subdir" "$root_dir/${subdir#$full_path/}" || true
    done < <(find "$full_path" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
done

echo ""
echo "  ]"
echo "}"
} > "$OUTPUT"

echo "Generated $OUTPUT"
