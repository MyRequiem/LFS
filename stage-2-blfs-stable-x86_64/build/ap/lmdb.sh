#! /bin/bash

PRGNAME="lmdb"
ARCH_NAME="LMDB"

### LMDB (Lightning Memory-Mapped Database)
# Сверхбыстрое и сверхкомпактное встроенное хранилище данных 'ключ-значение'.
# Разработан для проекта OpenLDAP

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d _ -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

tar xvf "${SOURCES}/${ARCH_NAME}_${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${ARCH_NAME}_${VERSION}"               || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

cd "./libraries/liblmdb" || exit 1

make || exit 1
# не устанавливаем статическую библиотеку liblmdb.a
sed -i 's| liblmdb.a||' Makefile
# пакет не имеет набора тестов
make prefix=/usr install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Lightning Memory-Mapped Database)
#
# The lmdb package is a fast, compact, key-value embedded data store. It uses
# memory-mapped files, so it has the read performance of a pure in-memory
# database while still offering the persistence of standard disk-based
# databases, and is only limited to the size of the virtual address space.
# Developed for the OpenLDAP Project.
#
# Home page: https://www.symas.com/symas-embedded-database-${PRGNAME}
# Download:  https://github.com/${ARCH_NAME}/${PRGNAME}/archive/${ARCH_NAME}_${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
