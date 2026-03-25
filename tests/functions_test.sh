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
  verdict=$(compare_age "test/input/folder.jpg" "test/tmp/new_file")
  assert_same "older" "$verdict"

  verdict=$(compare_age "test/tmp/new_file" "test/input/folder.jpg")
  assert_same "newer" "$verdict"
}

# https://bashunit.typeddevs.com/assertions
function test_pwd() {
  # make sure the PWD is the root directory when running make test
  assert_is_file "$(pwd)/README.md"
}
