#!/usr/bin/env bash

set -e

function rp() {
    # compatibility with GNU realpath on MacOS obtained from Homebrew coreutils
    if command -v grealpath > /dev/null 2>&1; then
        grealpath "$@"
    else
        realpath "$@"
    fi
}

function compare_age() {
  local left_file="$1"
  local right_file="$2"

  if [ ! -e "$left_file" ] || [ ! -e "$right_file" ]; then
    echo "Error: One or both files do not exist" >&2
    return 1
  fi

  local left_mod
  local right_mod
  if [[ $OSTYPE == darwin* ]]; then
    left_mod=$(stat -f %m "$left_file")
    right_mod=$(stat -f %m "$right_file")
  else
    left_mod=$(stat -c %Y "$left_file")
    right_mod=$(stat -c %Y "$right_file")
  fi

  if [ "$left_mod" -lt "$right_mod" ]; then
    echo "older"
  elif [ "$left_mod" -gt "$right_mod" ]; then
    echo "newer"
  else
    echo "same"
  fi
}

function convert_to() {
  local FORMAT="$1"
  if [ "$FORMAT" == "opus" ]; then
    # shellcheck disable=2086
    opusenc $EXTRA_OPUS_FLAGS --bitrate "$TARGET_BITRATE" "$2" "$3"
  elif [ "$FORMAT" == "mp3" ]; then
    convert_to_mp3 "$2" "$3"
  else
    echo "Unsupported format: $FORMAT"
    exit 1
  fi
}

function get_flac_tag() {
  local file="$1"
  local tag="$2"
  metaflac --show-tag="$tag" "$file" 2>/dev/null | sed "s/^$tag=//"
}

function convert_to_mp3() {
  local input_flac="$1"
  local output_mp3="$2"

  local temp_art
  local has_art=false

  temp_art=$(mktemp --suffix=.jpg)
  if metaflac --export-picture-to="$temp_art" "$input_flac" 2>/dev/null; then
    has_art=true
  fi

  local lame_args=()
  lame_args+=(--abr "$TARGET_BITRATE")
  # shellcheck disable=SC2086,SC2206
  lame_args+=($EXTRA_LAME_FLAGS)
  lame_args+=(--add-id3v2)

  local title artist album date comment track genre albumartist composer discnum disctotal

  title=$(get_flac_tag "$input_flac" "TITLE")
  artist=$(get_flac_tag "$input_flac" "ARTIST")
  album=$(get_flac_tag "$input_flac" "ALBUM")
  date=$(get_flac_tag "$input_flac" "DATE")
  comment=$(get_flac_tag "$input_flac" "COMMENT")
  track=$(get_flac_tag "$input_flac" "TRACKNUMBER")
  genre=$(get_flac_tag "$input_flac" "GENRE")
  albumartist=$(get_flac_tag "$input_flac" "ALBUMARTIST")
  composer=$(get_flac_tag "$input_flac" "COMPOSER")
  discnum=$(get_flac_tag "$input_flac" "DISCNUMBER")
  disctotal=$(get_flac_tag "$input_flac" "DISCTOTAL")

  [[ -n "$title" ]] && lame_args+=(--tt "$title")
  [[ -n "$artist" ]] && lame_args+=(--ta "$artist")
  [[ -n "$album" ]] && lame_args+=(--tl "$album")
  [[ -n "$date" ]] && lame_args+=(--ty "$date")
  [[ -n "$comment" ]] && lame_args+=(--tc "$comment")
  [[ -n "$track" ]] && lame_args+=(--tn "$track")
  [[ -n "$genre" ]] && lame_args+=(--tg "$genre")

  [[ -n "$albumartist" ]] && lame_args+=(--tv "TPE2=$albumartist")
  [[ -n "$composer" ]] && lame_args+=(--tv "TCOM=$composer")

  if [[ -n "$discnum" ]]; then
    if [[ -n "$disctotal" ]]; then
      lame_args+=(--tv "TPOS=$discnum/$disctotal")
    else
      lame_args+=(--tv "TPOS=$discnum")
    fi
  fi

  if $has_art; then
    lame_args+=(--ti "$temp_art")
  fi

  flac -d -c "$input_flac" | lame "${lame_args[@]}" - "$output_mp3"

  rm -f "$temp_art"
}
