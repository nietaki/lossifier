#!/usr/bin/env bash

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

function get_mp3_tag() {
  local file="$1"
  local tagname="$2"

  assert_file_exists "$file"

  ffprobe -hide_banner "$file" 2>&1 | grep -E "^\s*$tagname\s*:" | sed -E "s/.*:\s*//" | xargs
}