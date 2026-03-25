#!/usr/bin/env bash

function get_opus_tag() {
  local file="$1"
  local tagname="$2"

  assert_file_exists "$file"

  opusinfo "$file" | grep -i "	$tagname=" | sed "s/^[^=]*=//" | tr '\n' ';' | sed 's/;$//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

function get_opus_bitrate() {
  local file="$1"

  assert_file_exists "$file"

  opusinfo "$file" 2>&1 | grep "Average bitrate" | sed 's/.*w\/o overhead: \([0-9.]*\).*/\1/'
}

function get_mp3_tag() {
  local file="$1"
  local tagname="$2"

  assert_file_exists "$file"

  ffprobe -hide_banner "$file" 2>&1 | grep -iE "^\s*$tagname\s*:" | sed -E "s/^[^:]+:\s*//" | tr '\n' ';' | sed 's/;$//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

function extract_mp3_art() {
  local mp3_file="$1"
  local output_file="$2"

  assert_file_exists "$mp3_file"

  exiftool -b -Picture "$mp3_file" > "$output_file" 2>/dev/null
}

function extract_flac_art() {
  local flac_file="$1"
  local output_file="$2"

  assert_file_exists "$flac_file"

  metaflac --export-picture-to="$output_file" "$flac_file" 2>/dev/null
}