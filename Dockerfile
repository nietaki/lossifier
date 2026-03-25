FROM debian:13.3

RUN mkdir -p /app
RUN mkdir /data
RUN chmod ugo+rwx /app
RUN chmod ugo+rwx /data

# enable nonfree - file location should be correct for trixie onwards
RUN sed -i -e's/ main/ main contrib non-free/g' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  opus-tools lame flac \
  shellcheck coreutils locales && \
  sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
  locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

COPY ./*.sh /app
RUN chmod ugo+x /app/*.sh


VOLUME /data/input
VOLUME /data/output

# setting the default values
ENV INPUT_DIR=/data/input
ENV OUTPUT_DIR=/data/output
ENV TARGET_FORMAT=opus
ENV TARGET_BITRATE=192
ENV EXTRA_OPUS_FLAGS="--no-phase-inv --downmix-stereo"
ENV EXTRA_LAME_FLAGS="-q 1"
ENV OVERWRITE_MODE="if_newer"
ENV EXTRA_FILE_EXTENSIONS="jpg,jpeg,png,txt,mp3"
ENV PLAYLISTS_DIR=""
ENV M3U_DIRS=""

ENTRYPOINT "/app/lossify.sh"
