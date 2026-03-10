#!/usr/bin/env bash

# the extra flags are deliberately not surrounded by quotes, so that they can be split into multiple flags if needed
opusenc $EXTRA_OPUS_FLAGS --bitrate "$TARGET_BITRATE" "$1" "$2"
