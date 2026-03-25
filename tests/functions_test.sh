#!/usr/bin/env bash

function set_up() {
  rm -f "test/tmp/*"
  source "./functions.sh"
}

function test_compare_age_same_age() {
  touch test/tmp/single_file
  verdict=$(compare_age "test/tmp/single_file" "test/tmp/single_file")
  assert_same "same" "$verdict"
}

function test_compare_age_different() {
  touch test/tmp/new_file
  verdict=$(compare_age "test/input/Playlists/Assorted Techno/folder.jpg" "test/tmp/new_file")
  assert_same "older" "$verdict"

  verdict=$(compare_age "test/tmp/new_file" "test/input/Playlists/Assorted Techno/folder.jpg")
  assert_same "newer" "$verdict"
}

function get_opus_tag() {
  local file="$1"
  local tagname="$2"

  assert_file_exists "$file"

  opusinfo "$file" | grep "\s$tagname=" | sed "s/$tagname=//" | xargs
}

function get_opus_bitrate() {
  local file="$1"

  assert_file_exists "$file"

  opusinfo "$file" 2>&1 | grep "Average bitrate" | sed 's/.*w\/o overhead: \([0-9.]*\).*/\1/'
}

function test_convert_to_opus() {
  local input_flac="test/input/Playlists/Assorted Techno/Interpunkcja (test).flac"
  local output_opus="test/tmp/test_output.opus"

  TARGET_BITRATE="64" convert_to opus "$input_flac" "$output_opus"

  assert_file_exists "$output_opus"

  assert_same "Interpunkcja (feat marcia)" "$(get_opus_tag "$output_opus" "TITLE")"
  assert_same "1" "$(get_opus_tag "$output_opus" "DISCNUMBER")"
  assert_same "2" "$(get_opus_tag "$output_opus" "DISCTOTAL")"
  assert_same "DJ ostatni podryg" "$(get_opus_tag "$output_opus" "ARTIST")"
  assert_same "nietaki" "$(get_opus_tag "$output_opus" "ALBUMARTIST")"
  assert_same "test comment, please ignore" "$(get_opus_tag "$output_opus" "COMMENT")"
  assert_same "Techno" "$(get_opus_tag "$output_opus" "GENRE")"
  assert_same "2026" "$(get_opus_tag "$output_opus" "DATE")"
  assert_same "14" "$(get_opus_tag "$output_opus" "TRACKNUMBER")"
  assert_same "Jacek Królikowski" "$(get_opus_tag "$output_opus" "COMPOSER")"
  assert_same "unpublished" "$(get_opus_tag "$output_opus" "ALBUM")"
}

function test_opus_bitrate_in_range() {
  local input_flac="test/input/Playlists/Assorted Techno/Interpunkcja (test).flac"
  local output_opus="test/tmp/test_bitrate.opus"

  TARGET_BITRATE="64" convert_to opus "$input_flac" "$output_opus"

  local bitrate
  bitrate=$(get_opus_bitrate "$output_opus")

  local bitrate_int=${bitrate%.*}
  assert_greater_than "50" "$bitrate_int"
  assert_less_than "128" "$bitrate_int"
}
