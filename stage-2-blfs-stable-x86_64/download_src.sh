#! /bin/bash

SOURCES="/mnt/lfs/root/src/"
mkdir -p "${SOURCES}"

wget                         \
    --input-file=./wget-list \
    --no-check-certificate   \
    --progress=bar:force     \
    --continue               \
    --tries=3                \
    --wait=2                 \
    --directory-prefix="${SOURCES}"
