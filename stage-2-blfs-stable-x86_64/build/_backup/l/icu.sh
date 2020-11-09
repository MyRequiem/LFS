#! /bin/bash

PRGNAME="icu"
VERSION="65.1"
ARCH_NAME="${PRGNAME}4c"
ARCH_VERSION="$(echo "${VERSION}" | tr . _)"

### ICU (International Components for Unicode)
# Набор C/C++ библиотек International Components for Unicode (ICU).
# Предоставляют надежные и полнофункциональные сервисы Unicode для широкого
# спектра платформ.

# http://www.linuxfromscratch.org/blfs/view/stable/general/icu.html

# Home page: https://home.unicode.org/
# Download:  http://github.com/unicode-org/icu/releases/download/release-65-1/icu4c-65_1-src.tgz

# Required: no
# Optional: llvm    (должен быть собран с clang)
#           doxygen (для документации)

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

SOURCES="/root/src"
tar xvf "${SOURCES}/${ARCH_NAME}-${ARCH_VERSION}-src"*.t?z || exit 1
cd "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd "source" || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

MODVER="$(echo "${VERSION}" | tr . -)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (International Components for Unicode)
#
# The International Components for Unicode (ICU) package is a mature, widely
# used set of C/C++ libraries providing Unicode and Globalization support for
# software applications. ICU is widely portable and gives applications the same
# results on all platforms.
#
# Home page: https://home.unicode.org/
# Download:  http://github.com/unicode-org/${PRGNAME}/releases/download/release-${MODVER}/${ARCH_NAME}-${ARCH_VERSION}-src.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
