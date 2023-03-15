#! /bin/bash

PRGNAME="procps-ng"

### Procps-ng (utilities for displaying process information)
# Программы для мониторинга процессов

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# отключаем сборку утилиты kill, которая будет установлена с пакетом util-linux
#    --disable-kill
./configure           \
    --prefix=/usr     \
    --disable-static  \
    --disable-kill    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
