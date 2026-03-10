#!/usr/bin/env bash

set -e

# print all the env vars
echo "TARGET_FORMAT: $TARGET_FORMAT"
echo "TARGET_BITRATE: $TARGET_BITRATE"
echo "OVERWRITE_MODE: $OVERWRITE_MODE"


ls -la "$INPUT_DIR"
ls -la "$OUTPUT_DIR"

if [ "$TARGET_FORMAT" != "opus" ] && [ "$TARGET_FORMAT" != "mp3" ]; then
    echo "Invalid TARGET_FORMAT: $TARGET_FORMAT. Must be 'opus' or 'mp3'."
    exit 1
fi

FILE_COUNT=$(find "$INPUT_DIR" -type f -not -path '*/[@.]*' -name "*.flac" | wc -l)
echo "Found $FILE_COUNT FLAC files to convert."
# if no files found, exit
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "No .flac files found to convert. Exiting."
    exit 1
fi

shopt -s lastpipe

FILE_NO=0

find "$INPUT_DIR" -type f -not -path '*/[@.]*' -name "*.flac" | while read -r FLAC_FILE; do
    FILE_NO=$((FILE_NO + 1))
    # every 100 files, print progress
    if (( FILE_NO % 100 == 0 )); then
        PERCENT=$(( FILE_NO * 100 / FILE_COUNT ))
        echo "$PERCENT%: $FILE_NO / $FILE_COUNT files."
    fi

    # Determine the relative path of the FLAC file with respect to the input directory
    RELATIVE_PATH="${FLAC_FILE#"$INPUT_DIR"/}"
    
    # Determine the output directory and create it if it doesn't exist
    OUTPUT_SUBDIR="$(dirname "$OUTPUT_DIR/$RELATIVE_PATH")"
    mkdir -p "$OUTPUT_SUBDIR"
    
    # Determine the output file name by replacing .flac with .<target_format>
    OUTPUT_FILE="$OUTPUT_SUBDIR/$(basename "${RELATIVE_PATH%.flac}.$TARGET_FORMAT")"

    # https://stackoverflow.com/questions/14802807/compare-files-date-bash
    # check if the file already exists
    if [ -f "$OUTPUT_FILE" ]; then
        # echo "Skipping '$FLAC_FILE' as '$OUTPUT_FILE' already exists."
        continue
    fi

    printf "Converting %s\n" "$FLAC_FILE"
    
    # Convert the FLAC file to OPUS format using opusenc
    # opusenc --no-phase-inv --downmix-stereo --bitrate "$TARGET_BITRATE" "$FLAC_FILE" "$OUTPUT_FILE"

    ./convert_to_"$TARGET_FORMAT".sh "$FLAC_FILE" "$OUTPUT_FILE"
done

echo "$FILE_NO files checked for conversion."

# remove any whitespace from the EXTRA_FILE_EXTENSIONS variable
EXTRA_FILE_EXTENSIONS=$(echo "$EXTRA_FILE_EXTENSIONS" | tr -d '[:space:]')

# split all the extensions by comma, run a loop for each extension and copy the files
for EXT in ${EXTRA_FILE_EXTENSIONS//,/ }; do
    # echo "Processing extra file extension: $EXT"

    find "$INPUT_DIR" -type f -not -path '*/[@.]*' -name "*.$EXT" | while read -r EXTRA_FILE; do
        RELATIVE_PATH="${EXTRA_FILE#"$INPUT_DIR"/}"
        OUTPUT_FILE="$OUTPUT_DIR/$RELATIVE_PATH"
        OUTPUT_SUBDIR="$(dirname "$OUTPUT_FILE")"
        mkdir -p "$OUTPUT_SUBDIR"
        echo "Copying extra file '$EXTRA_FILE'"
        cp "$EXTRA_FILE" "$OUTPUT_FILE"
    done
done


# # now create playlists for all the opus files in the OUTPUT_DIR/Music/Playlists

# mkdir -p "$OUTPUT_DIR/Playlists"
# PLAYLIST_DIR="$OUTPUT_DIR/Music/Playlists"

# # iterate through all the directories in OUTPUT_DIR/Music/Playlists
# find "$PLAYLIST_DIR" -type d | while read -r DIR; do
#     PLAYLIST_NAME="$(basename "$DIR").m3u"
#     PLAYLIST_PATH="$OUTPUT_DIR/Playlists/$PLAYLIST_NAME"
#     echo "Re-creating playlist '$PLAYLIST_PATH'"
#     # delete the file if exists and re-create it
#     rm -f "$PLAYLIST_PATH"
#     touch "$PLAYLIST_PATH"
#     # find all opus files in the directory and add them to the playlist
#     find "$DIR" -type f -name "*.opus" | while read -r OPUS_FILE; do
#         # strip "$OUTPUT_DIR" from the beginning of the path
#         OPUS_FILE="${OPUS_FILE#$OUTPUT_DIR/}"
#         echo "../$OPUS_FILE" >> "$PLAYLIST_PATH"
#         echo "../$OPUS_FILE"
#     done
#     echo "\n"
# done

# # do the same, but in the Music directory itself


# mkdir -p "$OUTPUT_DIR/Music/m3us"
# PLAYLIST_DIR="$OUTPUT_DIR/Music/Playlists"

# # iterate through all the directories in OUTPUT_DIR/Music/Playlists
# find "$PLAYLIST_DIR" -type d | while read -r DIR; do
#     PLAYLIST_NAME="$(basename "$DIR").m3u"
#     PLAYLIST_PATH="$OUTPUT_DIR/Music/m3us/$PLAYLIST_NAME"
#     echo "Re-creating playlist '$PLAYLIST_PATH'"
#     # delete the file if exists and re-create it
#     rm -f "$PLAYLIST_PATH"
#     touch "$PLAYLIST_PATH"
#     # find all opus files in the directory and add them to the playlist
#     find "$DIR" -type f -name "*.opus" | while read -r OPUS_FILE; do
#         # strip "$OUTPUT_DIR/Music" from the beginning of the path
#         OPUS_FILE="${OPUS_FILE#$OUTPUT_DIR/Music/}"
#         echo "../$OPUS_FILE" >> "$PLAYLIST_PATH"
#         echo "../$OPUS_FILE"
#     done
#     echo "\n"
# done

echo "we're out"
