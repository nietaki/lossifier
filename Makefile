SHELL := /bin/bash

export TIMESTAMP=$(shell date +"%s")
export pwd=$(shell pwd)
export APP_VERSION=$(shell cat APP_VERSION.txt)
export IMAGE_NAME=lossifier
export UID=$(shell id -u)
export GID=$(shell id -g)

.PHONY: all
all: check test

.PHONY: mac-install
mac-install:
	brew install shellcheck flac opus-tools lame

.PHONY: debian-install
debian-install:
	apt-get update && apt-get install -y --no-install-recommends opus-tools lame flac 

.PHONY: check
check:
	@echo "Running shellcheck..."
	shellcheck ./*.sh

.PHONY: clean
clean:
	rm -rf ./test/output/* || true
	@rm -rf ./test/output/.DS_Store || true # I'm sorry...

.PHONY: build_tmp
build_tmp:
	docker build --load -t $(IMAGE_NAME):tmp .

.PHONY: bash
bash:
	docker run -it --entrypoint "/bin/bash" --volume ./test/input:/data/input:ro --volume ./test/output:/data/output $(IMAGE_NAME):tmp

.PHONY: run
run: build_tmp
	docker run -it -u $(UID):$(GID) --volume ./test/input:/data/input:ro --volume ./test/output:/data/output $(IMAGE_NAME):tmp

.PHONY: smoke-test-local
smoke-test-local:
	@echo "Running local smoke test..."
	INPUT_DIR=$(pwd)/test/input OUTPUT_DIR=$(pwd)/test/output TARGET_FORMAT=opus TARGET_BITRATE=192 EXTRA_OPUS_FLAGS="--no-phase-inv --downmix-stereo" OVERWRITE_MODE="if_newer" EXTRA_FILE_EXTENSIONS="jpg, jpeg,png,txt,mp3, nfo" bash ./lossify.sh

.PHONY: smoke-test-docker
smoke-test-docker: clean build_tmp
	@echo "Running docker smoke test..."
	docker run -it -u $(UID):$(GID) --volume ./test/input:/data/input:ro --volume ./test/output:/data/output $(IMAGE_NAME):tmp

.PHONY: push-tag
push-tag:
	if [[ -n $$(git status --porcelain) ]]; then \
		echo "There are uncommited changes. Please commit or stash them before pushing a tag."; \
		exit 1; \
	fi
	git tag -a v$(APP_VERSION) -m "Release version $(APP_VERSION)"
	git push origin v$(APP_VERSION)
	awk -F. -v OFS=. '{$$NF++; print}' APP_VERSION.txt > APP_VERSION.txt.tmp && mv APP_VERSION.txt.tmp APP_VERSION.txt
	echo "version automatically bumped to $(shell cat APP_VERSION.txt)"
