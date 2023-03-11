#! /bin/bash

DIRS="\
/usr/bin
/usr/lib
/usr/sbin
"

for BINDIR in ${DIRS}; do
    strip --strip-unneeded "${BINDIR}"/*
done
