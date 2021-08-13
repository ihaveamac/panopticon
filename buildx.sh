#!/bin/sh
# https://www.docker.com/blog/multi-arch-images/
# this will attempt to push immediately after building, so it probably won't work for you
docker buildx build --platform linux/amd64,linux/arm64 -t ianburgwin/panopticon --push .
