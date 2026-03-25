#!/usr/bin/env bash

set -e

echo "sourcing"

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
  FORMAT="$1"
  if [ "$FORMAT" == "opus" ]; then
    # the extra flags are deliberately not surrounded by quotes, so that they can be split into multiple flags if needed
    # shellcheck disable=2086
    opusenc $EXTRA_OPUS_FLAGS --bitrate "$TARGET_BITRATE" "$2" "$3"
  else
    echo "Unsupported format: $FORMAT"
    exit 1
  fi
}
