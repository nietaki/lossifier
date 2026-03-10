#!/usr/bin/env bash

function set_up() {
  FOO="foo"
}

function test_example() {
  assert_same "foo" "$FOO"
}

# https://bashunit.typeddevs.com/assertions
function test_pwd() {
  # make sure the PWD is the root directory when running make test
  assert_is_file "$(pwd)/README.md"
}

