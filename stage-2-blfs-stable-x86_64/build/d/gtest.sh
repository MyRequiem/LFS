#! /bin/bash

PRGNAME="gtest"
ARCH_NAME="googletest"

### gtest (Google C++ Testing Framework)
# Google Framework для написания C++ тестов на различных платформах
# (Linux, Mac OS X, Windows, Cygwin, Windows CE и Symbian)

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D BUILD_SHARED_LIBS=ON      \
    -D CMAKE_SKIP_RPATH=ON       \
    -D CMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Google C++ Testing Framework)
#
# Google's framework for writing C++ tests on a variety of platforms (Linux,
# Mac OS X, Windows, Cygwin, Windows CE, and Symbian). Based on the xUnit
# architecture. Supports automatic test discovery, a rich set of assertions,
# user-defined assertions, death tests, fatal and non-fatal failures, value-
# and type-parameterized tests, various options for running the tests, and XML
# test report generation.
#
# Home page: https://github.com/google/${ARCH_NAME}
# Download:  https://github.com/google/${ARCH_NAME}/releases/download/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
