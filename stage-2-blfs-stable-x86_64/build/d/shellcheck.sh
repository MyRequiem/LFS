#! /bin/bash

PRGNAME="shellcheck"

### ShellCheck (A shell script static analysis tool)
# Анализатор синтаксиса сценариев оболочки bash/sh. Выдает предупреждения и
# предложения для исправления кода.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 5- | cut -d v -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-v${VERSION}.linux.x86_64"*.tar.?z* || exit 1
cd "${PRGNAME}-v${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MANDIR="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}"{/usr/bin,"${MANDIR}"}

cp "${PRGNAME}" "${TMP_DIR}/usr/bin/"
cp "${SOURCES}/${PRGNAME}.1" "${TMP_DIR}${MANDIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A shell script static analysis tool)
#
# ShellCheck is a GPLv3 tool that gives warnings and suggestions for bash/sh
# shell scripts.
#
# Home page: https://github.com/koalaman/${PRGNAME}/
# Download:  https://github.com/koalaman/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-v${VERSION}.linux.x86_64.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
