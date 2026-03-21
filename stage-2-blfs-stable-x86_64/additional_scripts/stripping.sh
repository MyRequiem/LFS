#! /bin/bash

BINARY="$(find "${TMP_DIR}" -type f -not -path "*/usr/share/qemu/*" -print0 | \
    xargs -0 file 2>/dev/null | \
    /usr/bin/grep -e "executable" -e "shared object" | \
    /usr/bin/grep "ELF" | \
    /usr/bin/grep -v "unknown arch" | \
    /usr/bin/grep -v "32-bit" | \
    /usr/bin/grep -v "no machine" | cut -f 1 -d :)"

for BIN in ${BINARY}; do
    strip --strip-unneeded "${BIN}" &>/dev/null
done
