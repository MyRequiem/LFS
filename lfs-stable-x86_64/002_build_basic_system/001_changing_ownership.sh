#! /bin/bash

# команды в дальнейшем должны выполняться от пользователя root, а не от
# пользователя lfs
if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

# сделаем пользователя root владельцем всей системы LFS
LFS="/mnt/lfs"
chown -R root:root "${LFS}"/*
