#! /bin/bash

PRGNAME="htop"

### htop (ncurses-based interactive process viewer)
# ncurses утилита для просмотра и управления процессами. Похожа на 'top', но
# более удобная и мощная

# Required:    no
# Recommended: no
# Optional:    lm-sensors
#              hwloc (https://www.open-mpi.org/projects/hwloc/)
#              libcap
#              libnl

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

if [ ! -r configure ]; then
    if [ -x ./autogen.sh ]; then
        NOCONFIGURE=1 ./autogen.sh
    else
        autoreconf -vif
    fi
fi

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ncurses-based interactive process viewer)
#
# htop is a free (GPL) ncurses-based process viewer that is similar to the
# well-known "top" program, but allows to scroll the list vertically and
# horizontally to see all processes and their full command lines. Tasks related
# to processes (killing, renicing) can be done without entering their PIDs.
#
# Home page: https://${PRGNAME}.dev/
# Download:  https://github.com/${PRGNAME}-dev/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
