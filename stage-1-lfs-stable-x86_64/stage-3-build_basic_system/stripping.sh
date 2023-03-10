#! /bin/bash

BINARY="$(find "${TMP_DIR}" -type f -not -path "*/usr/share/qemu/*" -print0 | \
    xargs -0 file 2>/dev/null | /bin/grep -e "executable" -e "shared object" | \
    /bin/grep ELF | /bin/grep -v "32-bit" | cut -f 1 -d :)"

for BIN in ${BINARY}; do
    strip --strip-unneeded "${BIN}"
done
