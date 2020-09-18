#! /bin/bash

LFS="/mnt/lfs"

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

# сделаем пользователя root владельцем всей системы LFS
chown -R root:root "${LFS}"/*
