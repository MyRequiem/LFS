#! /bin/bash

LFS="/mnt/lfs"
SOURCES="${LFS}/sources"
WGET_LIST="wget-list"
DOWNLOAD_URL="http://www.linuxfromscratch.org/lfs/downloads/stable"

wget "${DOWNLOAD_URL}/${WGET_LIST}" && \
wget                                   \
    --input-file=./${WGET_LIST}        \
    --no-check-certificate             \
    --progress=bar:force               \
    --continue                         \
    --tries=3                          \
    --wait=2                           \
    --directory-prefix="${SOURCES}"/

chown lfs:lfs "${SOURCES}"/*
