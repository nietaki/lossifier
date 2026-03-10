# Lossifier - FLAC to Opus/mp3 converter for your music collection

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/nietaki/lossifier/main.yml)

[![Docker Image Size](https://img.shields.io/docker/image-size/nietaki/lossifier)](https://hub.docker.com/r/nietaki/lossifier)

## Overview

Lossifier is a docker image that takes your lossless FLAC music collection and creates a "mirror" of it in a lossy format (.opus or .mp3), for use with DAPs or other mobile devices.

It's designed to work idempotently, so you can run it on a schedule as you add music to the flac collection - subsequent runs will only run faster.

## Features

### Maintaining directory structure

You can use an arbitrary directory structure in the input collection and it will be maintained in the result - the main thing that will change is the file sizes and music format.

### Configurable format and encoder options

If the default target bitrate is 192kbps, and the opus encoder is configured with `--no-phase-inv --downmix-stereo` flags, to avoid any issues when played on mono systems (phones, bluetooth speakers, some DJ uses).

The encoder options can be set arbitrarily with env vars.

### Ignoring hidden files

The script deliberately ignores hidden files and directories. This behaviour has a number of benefits, but the most noticeable is ignoring trash files created by MacOS.

### Extra file handling

You can specify extra file extensions to copy from the input directory to the output directory. This is useful for copying cover art, lyrics, playlists files, or music files that couldn't be obtained in FLAC, but should be included in the resulting lossy collection.

## Usage

Available on DockerHub: https://hub.docker.com/r/nietaki/lossifier

### Docker CLI

Basic usage:

```bash
$ export UID=$(id -u)
$ export GID=$(id -g)
$ docker run -it --rm \
  -u "$UID:$GID" \
  -v /path/to/flac/music:/data/input:ro \
  -v /path/of/target/directory:/data/output \
  -e TARGET_FORMAT=opus \
  nietaki/lossifier:latest
```

You can see the input/output directory mounts and a sample env var for configuration. The UID/GID helps make sure you don't get a bunch of root-owned files in the output directory. The input directory can be mounted read-only to ensure your source collection is safe from any harm.

So in the project root, a test run could look like this:

```bash
$ export UID=$(id -u)
$ export GID=$(id -g)
$ docker run -it --rm \
  -u "$UID:$GID" \
  -v ./test/input:/data/input:ro \
  -v ./test/output:/data/output \
  -e TARGET_FORMAT=opus \
  nietaki/lossifier:latest
```

### Configuration

For convenience, the script is configured with environment variables. The following variables are available:

| ENV var name | description | possible values | default value |
|--------------|-------------|-----------------|---------------|
| `TARGET_FORMAT` | the lossy format you want to convert to | `opus` (`mp3` coming soon) | `opus` |
| `TARGET_BITRATE` | the target average bitrate of the converted files in kbps | usually between `11` and `320` | `192` |
| `EXTRA_OPUS_FLAGS` | extra flags to pass to the opus encoder (ignored if `TARGET_FORMAT` is not `opus`) | any valid flags for `opusenc` | `--no-phase-inv --downmix-stereo` |
| `OVERWRITE_MODE` | how to handle existing files in the output directory.  | `always`, `if_newer`, `never` | `if_newer` |
| `EXTRA_FILE_EXTENSIONS` | extra file extensions to copy from the input directory to the output directory (comma-separated) | comma-separated file extensions (without the dot) | `jpg,jpeg,png,txt,mp3,nfo` |


You can see the supported ENV vars and their default values by inspecting the docker image:

```bash
$ docker pull nietaki/lossifier:latest
$ docker inspect nietaki/lossifier:latest | jq 'map(.Config.Env)[0]'

[
  "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  "INPUT_DIR=/data/input",
  "OUTPUT_DIR=/data/output",
  "TARGET_FORMAT=opus",
  "TARGET_BITRATE=192",
  "EXTRA_OPUS_FLAGS=--no-phase-inv --downmix-stereo",
  "OVERWRITE_MODE=if_newer",
  "EXTRA_FILE_EXTENSIONS=jpg,jpeg,png,txt,mp3,nfo"
]
```


## TODO - functionality

- [x] handle opus
- [x] handle extra files
- [ ] handle mp3  ( https://linux.die.net/man/1/lame , https://manpages.debian.org/trixie/flac/metaflac.1.en.html)
  - [ ] handle mp3 cover art
- [ ] (configurable) playlist creation
- [ ] handle `OVERWRITE_MODE` ( https://stackoverflow.com/questions/14802807/compare-files-date-bash )

## TODO - build process

- [x] shellcheck
- [x] handle env-var configuration
- [x] smoke tests
- [ ] docker-based tests
- [x] github image build pipeline (https://docs.docker.com/build/ci/github-actions/multi-platform/ )
- [x] github test pipeline
- [x] write dockerhub readme text / usage
- [ ] pushing dockherhub readme ( https://github.com/peter-evans/dockerhub-description ?)

