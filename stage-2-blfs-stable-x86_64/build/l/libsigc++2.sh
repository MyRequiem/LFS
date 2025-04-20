#! /bin/bash

PRGNAME="libsigc++2"

### libsigc++ version 2 (typesafe callback system for standard C++)
# Библиотека реализует систему безопасных обратных вызовов (callbacks) для
# стандарта C++

# Required:    no
# Recommended: boost
#              libxslt
# Optional:    --- для сборки документации ---
#              docbook-utils
#              docbook-xml
#              doxygen
#              fop
#              mm-common (https://download.gnome.org/sources/mm-common/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1

SOURCES="${ROOT}/src"
ARCH_NAME="libsigc++"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-2*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${ARCH_NAME}-${VERSION}"
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

mkdir bld
cd bld || exit 1

meson setup                     \
    --prefix=/usr               \
    --buildtype=release         \
    -Dbuild-documentation=false \
    -Dbuild-examples=false      \
    -Dbuild-tests=false         \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (typesafe callback system for standard C++)
#
# libsigc++ (version 2) implements a typesafe callback system for standard C++.
# It allows you to define signals and to connect those signals to any callback
# function, either global or a member function, regardless of whether it is
# static or virtual. It also contains adaptor classes for connection of
# dissimilar callbacks and has an ease of use unmatched by other C++ callback
# libraries.
#
# Home page: https://libsigcplusplus.github.io/libsigcplusplus/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
