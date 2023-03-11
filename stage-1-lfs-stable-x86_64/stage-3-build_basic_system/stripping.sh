#! /bin/bash

DIRS="\
/bin
/lib
/sbin
/usr/bin
/usr/lib
/usr/sbin
"

for BINDIR in ${DIRS}; do
    [ -d "${TMP_DIR}${BINDIR}" ] && \
        strip --strip-unneeded "${TMP_DIR}${BINDIR}"/* &>/dev/null
done
