#! /bin/bash

PRGNAME="numlockx"

### numlockx (Start X with NumLock Turned On)

# Required:    X Window System
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN_DIR="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}${MAN_DIR}"

./configure                      \
    --prefix=/usr                \
    --sysconfdir=/etc            \
    --localstatedir=/var         \
    --with-x                     \
    --x-libraries="/usr/lib/X11" \
    --x-includes="/usr/include/X11" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# man-страница
# help2man --no-info numlockx > numlockx.1
cp "${SOURCES}/${PRGNAME}.1" "${TMP_DIR}${MAN_DIR}/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Start X with NumLock Turned On)
#
# This little thingy allows you to start X with NumLock turned on (which is a
# feature that a lot of people seem to miss and nobody really knew how to
# achieve this).
#
# Home page: https://github.com/rg3/${PRGNAME}
# Download:  http://ponce.cc/slackware/sources/repo/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
