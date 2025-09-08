#! /bin/bash

LFS="/mnt/lfs"
SOURCES="${LFS}/sources"
WGET_LIST="wget-list"

wget                              \
    --input-file="./${WGET_LIST}" \
    --no-check-certificate        \
    --progress=bar:force          \
    --continue                    \
    --tries=3                     \
    --wait=2                      \
    --directory-prefix="${SOURCES}"/

# если устанавливаем LFS с нуля (пакет binutils еще не установлен)
if ! [ -x "${LFS}/usr/bin/ld" ] ; then
    chown lfs:lfs "${SOURCES}"/*
fi
