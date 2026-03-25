#!/usr/bin/env bash

source ./tests/helpers.sh

function set_up() {
  rm -f "test/tmp/*"
  source "./functions.sh"
}

function test_compare_age_same_age() {
  touch test/tmp/single_file
  local verdict
  verdict=$(compare_age "test/tmp/single_file" "test/tmp/single_file")

  assert_same "same" "$verdict"
}

function test_compare_age_different() {
  touch test/tmp/new_file
  local verdict
  verdict=$(compare_age "test/input/Playlists/Assorted Techno/folder.jpg" "test/tmp/new_file")

  assert_same "older" "$verdict"

  verdict=$(compare_age "test/tmp/new_file" "test/input/Playlists/Assorted Techno/folder.jpg")
  assert_same "newer" "$verdict"
}

function test_should_process_always_returns_create_for_missing_target() {
  local result
  result=$(should_process "always" "test/input/Playlists/Assorted Techno/folder.jpg" "test/tmp/nonexistent.jpg")
  assert_same "create" "$result"
}

function test_should_process_always_returns_overwrite_for_existing_target() {
  touch test/tmp/existing.jpg
  local result
  result=$(should_process "always" "test/input/Playlists/Assorted Techno/folder.jpg" "test/tmp/existing.jpg")
  assert_same "overwrite" "$result"
}

function test_should_process_never_returns_create_for_missing_target() {
  local result
  result=$(should_process "never" "test/input/Playlists/Assorted Techno/folder.jpg" "test/tmp/nonexistent.jpg")
  assert_same "create" "$result"
}

function test_should_process_never_returns_skip_for_existing_target() {
  touch test/tmp/existing.jpg
  local result
  result=$(should_process "never" "test/input/Playlists/Assorted Techno/folder.jpg" "test/tmp/existing.jpg")
  assert_same "skip" "$result"
}

function test_should_process_if_newer_returns_create_for_missing_target() {
  local result
  result=$(should_process "if_newer" "test/input/Playlists/Assorted Techno/folder.jpg" "test/tmp/nonexistent.jpg")
  assert_same "create" "$result"
}

function test_should_process_if_newer_returns_overwrite_when_source_newer() {
  touch test/tmp/older_file.jpg
  sleep 1
  touch test/tmp/newer_file.jpg
  local result
  result=$(should_process "if_newer" "test/tmp/newer_file.jpg" "test/tmp/older_file.jpg")
  assert_same "overwrite" "$result"
}

function test_should_process_if_newer_returns_skip_when_source_older() {
  touch test/tmp/older_file.jpg
  sleep 1
  touch test/tmp/newer_file.jpg
  local result
  result=$(should_process "if_newer" "test/tmp/older_file.jpg" "test/tmp/newer_file.jpg")
  assert_same "skip" "$result"
}

function test_should_process_if_newer_returns_skip_for_same_age() {
  touch test/tmp/same_file.jpg
  local result
  result=$(should_process "if_newer" "test/tmp/same_file.jpg" "test/tmp/same_file.jpg")
  assert_same "skip" "$result"
}

function test_should_process_fails_with_invalid_mode() {
  local result
  result=$(should_process "invalid" "test/input/Playlists/Assorted Techno/folder.jpg" "test/tmp/output.jpg" 2>&1)
  assert_same "Error: Invalid overwrite_mode: invalid" "$result"
}

function test_should_process_fails_with_missing_source() {
  local result
  result=$(should_process "always" "test/tmp/nonexistent.jpg" "test/tmp/output.jpg" 2>&1)
  assert_same "Error: Source file does not exist: test/tmp/nonexistent.jpg" "$result"
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

  local bitrate
  bitrate=$(get_opus_bitrate "$output_opus")

  local bitrate_int=${bitrate%.*}
  assert_greater_than "50" "$bitrate_int"
  assert_less_than "128" "$bitrate_int"
}

function test_convert_to_mp3() {
  local input_flac="test/input/Playlists/Assorted Techno/Interpunkcja (test).flac"
  local output_mp3="test/tmp/test_output.mp3"

  TARGET_BITRATE="164" convert_to mp3 "$input_flac" "$output_mp3"

  assert_file_exists "$output_mp3"

  assert_same "Interpunkcja (feat marcia)" "$(get_mp3_tag "$output_mp3" "title")"
  assert_same "DJ ostatni podryg" "$(get_mp3_tag "$output_mp3" "artist")"
  assert_same "unpublished" "$(get_mp3_tag "$output_mp3" "album")"
  assert_same "2026" "$(get_mp3_tag "$output_mp3" "date")"
  assert_same "14" "$(get_mp3_tag "$output_mp3" "track")"
  assert_same "Techno" "$(get_mp3_tag "$output_mp3" "genre")"
  assert_same "nietaki" "$(get_mp3_tag "$output_mp3" "album_artist")"
  assert_same "Jacek Królikowski" "$(get_mp3_tag "$output_mp3" "composer")"
  assert_same "1/2" "$(get_mp3_tag "$output_mp3" "disc")"
}
