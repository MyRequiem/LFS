#! /bin/bash

PRGNAME="gtkmm3"
ARCH_NAME="gtkmm"

### GTKmm3 (C++ interface for GTK+3)
# C++ интерфейс для популярной библиотеки графического интерфейса GTK+3.
# Основные моменты это безопасные обратные вызовы и полный набор виджетов,
# которые легко расширяются с помощью наследования.

# Required:    atkmm22
#              gtk+3
#              pangomm24
# Recommended: no
# Optional:    doxygen    (для сборки документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-3*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir "${PRGNAME}3-build"
cd "${PRGNAME}3-build" || exit 1

meson setup                      \
    --prefix=/usr                \
    --buildtype=release          \
    -D build-x11-api=true        \
    -D build-tests=false         \
    -D build-documentation=false \
    .. || exit 1

ninja || exit 1
# тесты нужно запускать в графической среде
# ninja test
DESTDIR="${TMP_DIR}" ninja install

DOC_DIR="${TMP_DIR}/usr/share/doc/${PRGNAME}"
if [ -d "${DOC_DIR}-3.0" ]; then
    mv  "${DOC_DIR}-3.0" "${DOC_DIR}-${VERSION}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++ interface for GTK+3)
#
# gtkmm3 is the official C++ interface for the popular GUI library GTK+3.
# Highlights include typesafe callbacks, and a comprehensive set of widgets
# that are easily extensible via inheritance.
#
# Home page: https://www.${ARCH_NAME}.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
