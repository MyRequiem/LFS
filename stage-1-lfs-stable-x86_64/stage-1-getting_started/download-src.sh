#! /bin/bash

LFS_IS_INSTALLED="false"
[ -f /etc/lfs-release ] && LFS_IS_INSTALLED="true"

PREFIX=""
[ "${LFS_IS_INSTALLED}" == "false" ] && PREFIX="/mnt/lfs"

wget                         \
    --input-file=./wget-list \
    --no-check-certificate   \
    --progress=bar:force     \
    --continue               \
    --tries=3                \
    --wait=2                 \
    --directory-prefix="${PREFIX}/sources"

[ "${LFS_IS_INSTALLED}" == "false" ] && chown lfs:lfs "${PREFIX}/sources"/*
