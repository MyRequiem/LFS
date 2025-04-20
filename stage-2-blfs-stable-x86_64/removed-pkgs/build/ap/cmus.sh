#! /bin/bash

PRGNAME="cmus"

### cmus (ncurses based music player)
# Небольшой и быстрый консольный музыкальный проигрыватель

# Required:    no
# Recommended: no
# Optional:    ffmpeg
#              faad2
#              opus
#              opusfile       (http://www.opus-codec.org)
#              libmp4v2       (https://github.com/sergiomb2/libmp4v2)
#              musepack-tools (https://www.musepack.net/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    DEBUG=0 \
    prefix=/usr || exit 1

make V=2 || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ncurses based music player)
#
# cmus is a small and fast text mode music player for Linux and many other UNIX
# like operating systems.
#
# Home page: https://${PRGNAME}.github.io/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
