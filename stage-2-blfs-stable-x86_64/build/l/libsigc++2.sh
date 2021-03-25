#! /bin/bash

PRGNAME="libsigc++2"
ARCH_NAME="libsigc++"

### libsigc++ version 2 (typesafe callback system for standard C++)
# Библиотека реализует систему безопасных обратных вызовов (callbacks) для
# стандарта C++

# Required:    no
# Recommended: boost
#              libxslt
# Optional:    docbook-utils (для сборки документации)
#              doxygen       (для сборки документации)
#              mm-common     (http://download-fallback.gnome.org:8000/sources/mm-common/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

API_DOCS="false"
# command -v doxygen &>/dev/null && API_DOCS="true"

mkdir build_
cd build_ || exit 1

meson                                   \
    --prefix=/usr                       \
    -Dbuild_documentation="${API_DOCS}" \
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
