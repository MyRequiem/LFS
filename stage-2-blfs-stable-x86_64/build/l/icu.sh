#! /bin/bash

PRGNAME="icu"
ARCH_NAME="${PRGNAME}4c"

### ICU (International Components for Unicode)
# Набор C/C++ библиотек International Components for Unicode (ICU).
# Предоставляют надежные и полнофункциональные сервисы Unicode для широкого
# спектра платформ.

# Required:    no
# Recommended: no
# Optional:    doxygen (для сборки документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_VERSION="$(find ${SOURCES} -type f -name "${ARCH_NAME}-*" | rev | \
    cut -d / -f 1 | rev | cut -d - -f 2)"
VERSION="$(echo "${ARCH_VERSION}" | tr _ .)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${ARCH_VERSION}"*.t?z || exit 1
cd "${PRGNAME}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd "source" || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Download:  https://github.com/unicode-org/${PRGNAME}/releases/download/release-${MODVER}/${ARCH_NAME}-${ARCH_VERSION}-src.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
