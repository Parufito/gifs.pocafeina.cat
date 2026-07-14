#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TAGS_FILE="$ROOT_DIR/tags.txt"
OUTPUT="$ROOT_DIR/gallery.json"
ALLOWED_EXT="jpg|jpeg|png|webp|gif|mp4"

declare -A EXISTING_TAGS

if [[ -f "$TAGS_FILE" ]]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        filename="${line%%:*}"
        tags="${line#*:}"
        tags="$(echo "$tags" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        EXISTING_TAGS["$filename"]="$tags"
    done < "$TAGS_FILE"
fi

{
echo '{'
echo '  "categories": ['

first_category=true

for root_dir in pics gifs; do
    full_path="$ROOT_DIR/$root_dir"
    [[ -d "$full_path" ]] || continue

    dirs=("$full_path")
    while IFS= read -r -d '' subdir; do
        dirs+=("$subdir")
    done < <(find "$full_path" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

    for dir in "${dirs[@]}"; do
        if [[ "$dir" == "$full_path" ]]; then
            category_name="$root_dir"
        else
            category_name="$root_dir/${dir#$full_path/}"
        fi

        if [[ "$first_category" == true ]]; then
            first_category=false
        else
            echo ','
        fi

        echo "    {"
        echo "      \"name\": \"$category_name\","
        echo "      \"files\": ["

        first_file=true

        while IFS= read -r -d '' filepath; do
            filename="$(basename "$filepath")"
            ext="${filename##*.}"
            ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"

            echo "$ext" | grep -qE "^($ALLOWED_EXT)$" || continue

            relpath="${filepath#$ROOT_DIR/}"

            media_type="image"
            if [[ "$ext" == "mp4" || "$ext" == "gif" ]]; then
                if [[ "$ext" == "mp4" ]]; then
                    media_type="video"
                fi
            fi

            if [[ "$first_file" == true ]]; then
                first_file=false
            else
                echo ","
            fi

            printf '        {"name": "%s", "path": "%s", "type": "%s", "ext": "%s"}' \
                "$filename" "$relpath" "$media_type" "$ext"

        done < <(find "$dir" -maxdepth 1 -type f -print0 | sort -z)

        echo ""
        echo "      ]"
        echo "    }"
    done
done

echo ""
echo "  ]"
echo "}"
} > "$OUTPUT"

echo "Generated $OUTPUT"

{
    echo "# Tags per fitxer"
    echo "# Format: filename: tag1, tag2, tag3"
    echo "# Deixa buit si no vols tags"
    echo "# El build.sh regenera aquest fitxer conservant els tags existents"
    echo ""

    for root_dir in pics gifs; do
        full_path="$ROOT_DIR/$root_dir"
        [[ -d "$full_path" ]] || continue

        echo "# $root_dir"
        while IFS= read -r -d '' filepath; do
            fn="$(basename "$filepath")"
            ext="${fn##*.}"
            ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
            echo "$ext" | grep -qE "^($ALLOWED_EXT)$" || continue
            tg="${EXISTING_TAGS[$fn]:-}"
            [[ -n "$tg" ]] && echo "$fn: $tg" || echo "$fn:"
        done < <(find "$full_path" -maxdepth 1 -type f -print0 | sort -z)

        while IFS= read -r -d '' subdir; do
            subname="${subdir#$full_path/}"
            echo ""
            echo "# $root_dir/$subname"
            while IFS= read -r -d '' filepath; do
                fn="$(basename "$filepath")"
                ext="${fn##*.}"
                ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
                echo "$ext" | grep -qE "^($ALLOWED_EXT)$" || continue
                tg="${EXISTING_TAGS[$fn]:-}"
                [[ -n "$tg" ]] && echo "$fn: $tg" || echo "$fn:"
            done < <(find "$subdir" -maxdepth 1 -type f -print0 | sort -z)
        done < <(find "$full_path" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    done
} > "$TAGS_FILE"

echo "Updated $TAGS_FILE"
