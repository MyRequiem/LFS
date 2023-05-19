#! /bin/bash

PRGNAME="lnav"

### lnav (The Log File Navigator)
# Усовершенствованная утилита для просмотра лог-файлов

# Required:    sqlite
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Log File Navigator)
#
# An enhanced log file viewer that takes advantage of any semantic information
# that can be gleaned from the files being viewed, such as timestamps and log
# levels. Using this extra semantic information, lnav can do things like
# interleaving messages from different files, generate histograms of messages
# over time, and providing hotkeys for navigating through the file. It is hoped
# that these features will allow the user to quickly and efficiently zero in on
# problems.
#
# Home page: https://${PRGNAME}.org
# Download:  https://github.com/tstack/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
