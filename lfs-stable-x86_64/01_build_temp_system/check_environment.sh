#! /bin/bash

if [[ "$(whoami)" != "lfs" ]]; then
    echo "You need to login as lfs user"
    exit 1
fi

if [ -z "${LFS}" ]; then
    echo "Environment variable LFS is empty. Why?"
    echo "Check your ~/.bashrc file. It must be set to a variable:"
    echo 'LFS="/mnt/lfs"'
    exit 1
fi

if [ -z "${LFS_TGT}" ]; then
    echo "Environment variable LFS_TGT is empty. Why?"
    echo "Check your ~/.bashrc file. It must be set to a variable:"
    echo 'LFS_TGT=$(uname -m)-lfs-linux-gnu'
    exit 1
fi

if [[ "${PATH}" != "/tools/bin:/bin:/usr/bin" ]]; then
    echo "Environment variable PATH musb be '/tools/bin:/bin:/usr/bin'."
    echo "Now PATH=${PATH}"
    echo "Why?"
    echo "Check your ~/.bashrc file. It must be set to a variable:"
    echo "PATH=/tools/bin:/bin:/usr/bin"
    exit 1
fi
