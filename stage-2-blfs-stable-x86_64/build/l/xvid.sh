#! /bin/bash

PRGNAME="xvid"
ARCH_NAME="xvidcore"

### XviD (MPEG-4 compliant video CODEC)
# Видеокодек, совместимый с MPEG-4

# Required:    no
# Recommended: no
# Optional:    yasm или nasm

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd build/generic || exit 1

# исправляем ошибку, возникающую при запуске 'make install' при переустановке
# или обновлении пакета
sed -i 's/^LN_S=@LN_S@/& -f -v/' platform.inc.in || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1

# пакет не имеет набора тестов

# отключаем установку статической библиотеки
sed -i '/libdir.*STATIC_LIB/ s/^/#/' Makefile || exit 1
make install DESTDIR="${TMP_DIR}"

chmod -v 755 "${TMP_DIR}/usr/lib/lib${ARCH_NAME}.so."*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (MPEG-4 compliant video CODEC)
#
# XviD is an MPEG-4 compliant video CODEC
#
# Home page: https://www.${PRGNAME}.com/
# Download:  https://downloads.${PRGNAME}.com/downloads/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
