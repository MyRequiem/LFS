#! /bin/bash

PRGNAME="utimer"

### uTimer (Open-Source Multifunction "Timer" Tool For Linux)
# Многофункциональный таймер командной строки (таймер, обратный отсчет и
# секундомер)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -p1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fno-common.patch" || exit 1
patch --verbose -p1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-locale.patch"     || exit 1

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Open-Source Multifunction "Timer" Tool For Linux)
#
# uTimer (pronounced as "micro-timer") is a command-line multifunction timer
# tool. It features a timer, a countdown, and a stopwatch. This is an open
# source (GPL) project developed in C using Glib. uTimer runs on GNU/Linux
# systems.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
