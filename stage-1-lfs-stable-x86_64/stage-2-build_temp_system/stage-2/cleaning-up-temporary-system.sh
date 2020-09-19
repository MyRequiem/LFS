#! /bin/bash

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

# Файлы libtool *.la полезны только при компоновке со статическими
# библиотеками, но они не нужны и потенциально опасны при использовании
# динамических (shared) библиотек
find /usr/{lib,libexec} -name "*.la" -delete

# удалим документацию временных инструментов, чтобы она не попала в
# окончательную систему
rm -rf /usr/share/{info,man,doc}/*
