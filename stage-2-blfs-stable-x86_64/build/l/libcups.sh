#! /bin/bash

PRGNAME="libcups"
ARCH_NAME="cups"

### libcups (Common UNIX Printing System client libraries)
# Набор системных библиотек, который выступает в роли связующего звена между
# прикладным софтом и функциями печати. Он необходим для запуска многих
# современных программ (вроде Google Chrome), так как предоставляет им
# стандартные инструменты для работы с документами, без которых они технически
# не могут инициализироваться и стартовать.

# Required:    gnutls
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    cut -d - -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                \
    --prefix=/usr          \
    --disable-pam          \
    --disable-dbus         \
    --disable-gssapi       \
    --with-dnssd=no        \
    --disable-browsing     \
    --disable-raw-printing \
    --with-components=libcups || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses,locale}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Common UNIX Printing System client libraries)
#
# This package contains the shared libraries used by applications to interact
# with a CUPS server via the IPP protocol. It provides the necessary API
# (libcups.so) for software like Google Chrome, GIMP, and LibreOffice to
# initialize their printing interfaces. These libraries are required for many
# pre-compiled binaries to run, even if no local print server is installed or
# used.
#
# Home page: https://openprinting.github.io/${ARCH_NAME}/
# Download:  https://github.com/OpenPrinting/${ARCH_NAME}/releases/download/v${VERSION}/${ARCH_NAME}-${VERSION}-source.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
