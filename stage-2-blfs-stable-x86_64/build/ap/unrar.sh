#! /bin/bash

PRGNAME="unrar"
ARCH_NAME="unrarsrc"

### UnRar (Extract, test and view RAR archives)
# Утилита, необходимая исключительно для извлечения файлов из архивов формата
# .rar. Полезно для работы с файлами, пришедшими из среды Windows.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make -f makefile
# пакет не имеет набора тестов
install -v -m755 -D unrar "${TMP_DIR}/usr/bin/unrar"

source "${ROOT}/stripping.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Extract, test and view RAR archives)
#
# The UnRAR utility is a freeware program, distributed with source code and
# developed for extracting, testing and viewing the contents of archives
# created with the RAR archiver version 1.50 and above.
#
# Home page: https://www.rarlab.com/rar_add.htm
# Download:  https://www.rarlab.com/rar/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
