#! /bin/bash

PRGNAME="unzip"
VERSION="6.0"

### UnZip (ZIP extraction utilities)
# Утилиты для распаковки ZIP-архивов

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/unzip60".tar.?z* || exit 1
cd unzip60 || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-consolidated_fixes-1.patch" || exit 1

make -f unix/Makefile generic || exit 1

# набор тестов не работает для текущей цели "generic"

make                                       \
    prefix="${TMP_DIR}/usr"                \
    MANDIR="${TMP_DIR}/usr/share/man/man1" \
    -f unix/Makefile install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ZIP extraction utilities)
#
# The UnZip package contains ZIP extraction utilities. These are useful for
# extracting files from ZIP archives. ZIP archives are created with PKZIP or
# Info-ZIP utilities, primarily in a DOS environment.
#
# Home page: https://sourceforge.net/projects/infozip/
# Download:  https://downloads.sourceforge.net/infozip/unzip60.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
