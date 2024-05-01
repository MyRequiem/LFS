#! /bin/bash

PRGNAME="numlockx"

### numlockx (Start X with NumLock Turned On)
# утилита позволяет запускать X с включенным NumLock

# Required:    Graphical Environments
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                      \
    --prefix=/usr                \
    --sysconfdir=/etc            \
    --localstatedir=/var         \
    --with-x                     \
    --x-libraries="/usr/lib/X11" \
    --x-includes="/usr/include/X11" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

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
# Download:  https://ponce.cc/slackware/sources/repo/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
