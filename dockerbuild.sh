#!/bin/sh
docker build --build-arg COMMIT=$(git rev-parse HEAD) -t ianburgwin/panopticon .
