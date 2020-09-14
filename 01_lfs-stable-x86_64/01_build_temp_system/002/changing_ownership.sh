#! /bin/bash

# сделаем пользователя root владельцем всей системы LFS
LFS="/mnt/lfs"
chown -R root:root "${LFS}"/*
