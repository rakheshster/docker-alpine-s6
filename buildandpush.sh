#!/bin/bash

ALPINE_VERSION=3.12
S6_VERSION=2.0.0.1

docker buildx build --platform linux/amd64,linux/arm64,linux/386,linux/arm/v7,linux/arm/v6 . --push -t rakheshster/alpine-s6:${ALPINE_VERSION}-${S6_VERSION} --progress=plain
