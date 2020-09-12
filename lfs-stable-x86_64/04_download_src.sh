#! /bin/bash

! [ -d /mnt/lfs/sources ] && mkdir -pv /mnt/lfs/sources

! [ -r ./wget-list ] && \
    wget http://www.linuxfromscratch.org/lfs/downloads/stable/wget-list

wget                         \
    --input-file=./wget-list \
    --no-check-certificate   \
    --progress=bar:force     \
    --continue               \
    --tries=3                \
    --wait=2                 \
    --directory-prefix=/mnt/lfs/sources/
