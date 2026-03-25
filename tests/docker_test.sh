#!/usr/bin/env bash

source ./tests/helpers.sh

function set_up_before_script() {
  make build_tmp
}

function set_up() {
  make clean

  # INPUT_FLAC="test/input/Playlists/Assorted Techno/Interpunkcja (test).flac"
  OUTPUT_OPUS="test/output/Playlists/Assorted Techno/Interpunkcja (test).opus"
  OUTPUT_MP3="test/output/Playlists/Assorted Techno/Interpunkcja (test).mp3"
  INPUT_FOLDER_IMAGE="test/input/Playlists/Assorted Techno/folder.jpg"
  OUTPUT_FOLDER_IMAGE="test/output/Playlists/Assorted Techno/folder.jpg"
  PLAYLIST_ONE="test/output/m3us/Assorted Techno.m3u"
  PLAYLIST_TWO="test/output/Playlists/Assorted Techno.m3u"
  PLAYLIST_ONE_MP3="test/output/m3us/Assorted Techno.m3u"
  PLAYLIST_TWO_MP3="test/output/Playlists/Assorted Techno.m3u"
  assert_file_not_exists "$OUTPUT_OPUS"
  assert_file_not_exists "$OUTPUT_MP3"
  assert_file_not_exists "$OUTPUT_FOLDER_IMAGE"
  assert_file_not_exists "$PLAYLIST_ONE"
  assert_file_not_exists "$PLAYLIST_TWO"
  assert_file_not_exists "$PLAYLIST_ONE_MP3"
  assert_file_not_exists "$PLAYLIST_TWO_MP3"
}


# @tag docker
function test_example_conversion() {
  make smoke-test-docker

  assert_file_exists "$OUTPUT_OPUS"
  assert_file_exists "$OUTPUT_FOLDER_IMAGE"
  assert_files_equals "$INPUT_FOLDER_IMAGE" "$OUTPUT_FOLDER_IMAGE"

  assert_same "Interpunkcja (feat marcia)" "$(get_opus_tag "$OUTPUT_OPUS" "TITLE")"
  assert_same "1" "$(get_opus_tag "$OUTPUT_OPUS" "DISCNUMBER")"
  assert_same "2" "$(get_opus_tag "$OUTPUT_OPUS" "DISCTOTAL")"
  assert_same "DJ ostatni podryg" "$(get_opus_tag "$OUTPUT_OPUS" "ARTIST")"
  assert_same "nietaki" "$(get_opus_tag "$OUTPUT_OPUS" "ALBUMARTIST")"
  assert_same "test comment, please ignore" "$(get_opus_tag "$OUTPUT_OPUS" "COMMENT")"
  assert_same "Techno" "$(get_opus_tag "$OUTPUT_OPUS" "GENRE")"
  assert_same "2026" "$(get_opus_tag "$OUTPUT_OPUS" "DATE")"
  assert_same "14" "$(get_opus_tag "$OUTPUT_OPUS" "TRACKNUMBER")"
  assert_same "Jacek Królikowski" "$(get_opus_tag "$OUTPUT_OPUS" "COMPOSER")"
  assert_same "unpublished" "$(get_opus_tag "$OUTPUT_OPUS" "ALBUM")"

  assert_file_exists "$PLAYLIST_ONE"
  assert_same "1" "$(wc -l < "$PLAYLIST_ONE" | xargs)"
  assert_same "../Playlists/Assorted Techno/Interpunkcja (test).opus" "$(head -n 1 "$PLAYLIST_ONE")"

  assert_file_exists "$PLAYLIST_TWO"
  assert_same "1" "$(wc -l < "$PLAYLIST_TWO" | xargs)"
  assert_same "Assorted Techno/Interpunkcja (test).opus" "$(head -n 1 "$PLAYLIST_TWO")"
}

# @tag docker
function test_example_mp3_conversion() {
  make smoke-test-docker-mp3

  assert_file_exists "$OUTPUT_MP3"
  assert_file_exists "$OUTPUT_FOLDER_IMAGE"
  assert_files_equals "$INPUT_FOLDER_IMAGE" "$OUTPUT_FOLDER_IMAGE"

  assert_same "Interpunkcja (feat marcia)" "$(get_mp3_tag "$OUTPUT_MP3" "title")"
  assert_same "DJ ostatni podryg" "$(get_mp3_tag "$OUTPUT_MP3" "artist")"
  assert_same "nietaki" "$(get_mp3_tag "$OUTPUT_MP3" "album_artist")"
  assert_same "Techno" "$(get_mp3_tag "$OUTPUT_MP3" "genre")"
  assert_same "2026" "$(get_mp3_tag "$OUTPUT_MP3" "date")"
  assert_same "14" "$(get_mp3_tag "$OUTPUT_MP3" "track")"
  assert_same "Jacek Królikowski" "$(get_mp3_tag "$OUTPUT_MP3" "composer")"
  assert_same "unpublished" "$(get_mp3_tag "$OUTPUT_MP3" "album")"
  assert_same "1/2" "$(get_mp3_tag "$OUTPUT_MP3" "disc")"

  assert_file_exists "$PLAYLIST_ONE_MP3"
  assert_same "1" "$(wc -l < "$PLAYLIST_ONE_MP3" | xargs)"
  assert_same "../Playlists/Assorted Techno/Interpunkcja (test).mp3" "$(head -n 1 "$PLAYLIST_ONE_MP3")"

  assert_file_exists "$PLAYLIST_TWO_MP3"
  assert_same "1" "$(wc -l < "$PLAYLIST_TWO_MP3" | xargs)"
  assert_same "Assorted Techno/Interpunkcja (test).mp3" "$(head -n 1 "$PLAYLIST_TWO_MP3")"
}
