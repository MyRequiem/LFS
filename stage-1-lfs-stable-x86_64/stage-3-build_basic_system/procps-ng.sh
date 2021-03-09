#! /bin/bash

PRGNAME="procps-ng"

### Procps-ng (utilities for displaying process information)
# Программы для мониторинга процессов

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1

SOURCES="/sources"
VERSION="$(echo "${SOURCES}/${PRGNAME}"-*.tar.?z* | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"
BUILD_DIR="${SOURCES}/build"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
UNPACK_NAME="$(echo ${PRGNAME} | cut -d - -f 1)"
rm -rf "${UNPACK_NAME}-${VERSION}"

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}".tar.?z* || exit 1
cd "${UNPACK_NAME}-${VERSION}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

# отключаем сборку утилиты kill, которая будет установлена с пакетом util-linux
#    --disable-kill
./configure           \
    --prefix=/usr     \
    --exec-prefix=    \
    --libdir=/usr/lib \
    --disable-static  \
    --disable-kill    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# переместим библиотеку libprocps.so из /usr/lib в /lib
mv -v "${TMP_DIR}/usr/lib"/libprocps.so.* "${TMP_DIR}/lib"

# установим ссылку в /usr/lib
# libprocps.so -> ../../lib/libprocps.so.x.x.x
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "../../lib/$(readlink libprocps.so)" libprocps.so
)

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (utilities for displaying process information)
#
# The procps-ng package provides the classic set of utilities used to display
# information about the processes currently running on the machine.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/Production/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
