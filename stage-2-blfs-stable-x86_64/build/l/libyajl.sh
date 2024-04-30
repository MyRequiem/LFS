#! /bin/bash

PRGNAME="libyajl"
ARCH_NAME="yajl"

### libyajl (Yet Another JSON Library)
# Небольшой анализатор JSON, управляемый событиями (в стиле SAX), написанный на
# ANSI C, а так же JSON генератор

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                \
    -DCMAKE_INSTALL_PREFIX=/usr      \
    -DCMAKE_BUILD_TYPE=Release       \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    .. || exit 1

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Yet Another JSON Library)
#
# YAJL is a small event-driven (SAX-style) JSON parser written in ANSI C, and a
# small validating JSON generator. YAJL is released under the ISC license.
#
# Home page: https://lloyd.github.io/${ARCH_NAME}/
# Download:  https://fossies.org/linux/www/old/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
