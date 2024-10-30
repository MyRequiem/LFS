#! /bin/bash

PRGNAME="libptytty"

### libptytty (independent and secure pty/tty and utmp/wtmp/lastlog handling)
# библиотека позволяющая безопасную обработка pty/tty и utmp/wtmp/lastlog

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                               \
    -DCMAKE_INSTALL_PREFIX=/usr     \
    -DCMAKE_BUILD_TYPE=Release      \
    -DPT_UTMP_FILE:STRING=/run/utmp \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (independent and secure pty/tty and utmp/wtmp/lastlog handling)
#
# The libptytty package provides a library that allows for OS independent and
# secure pty/tty and utmp/wtmp/lastlog handling.
#
# Home page: https://github.com/yusiwen/${PRGNAME}
# Download:  https://ftp.osuosl.org/pub/blfs/conglomeration/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
