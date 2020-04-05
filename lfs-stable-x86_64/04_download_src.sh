#! /bin/bash

wget                         \
    --input-file=./wget-list \
    --no-check-certificate   \
    --progress=bar:force     \
    --continue               \
    --tries=3                \
    --wait=2                 \
    --directory-prefix=/mnt/lfs/sources/
