#! /bin/bash

PRGNAME="kdsoap-ws-discovery-client"

### kdsoap-ws-discovery-client (support for the WS-Discovery protocol)
# Библиотека, предоставляющая поддержку протокола WS-Discovery

# Required:    doxygen
#              extra-cmake-modules
#              kdsoap
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd    build || exit 1

cmake                              \
    -D CMAKE_INSTALL_PREFIX=/usr   \
    -D CMAKE_BUILD_TYPE=Release    \
    -D CMAKE_SKIP_INSTALL_RPATH=ON \
    -D QT_MAJOR_VERSION=6          \
    -W no-dev                      \
    .. || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

mv -v "${TMP_DIR}/usr/share/doc"/KDSoapWSDiscoveryClient{,"-${VERSION}"}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (support for the WS-Discovery protocol)
#
# The kdsoap-ws-discovery-client package contains a library that provides
# support for the WS-Discovery protocol, a recent protocol used to discover
# services available on a local network
#
# Home page: https://github.com/KDE/${PRGNAME}
# Download:  https://download.kde.org/stable/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
