#! /bin/bash

PRGNAME="xsel"

### XSel (program for getting/setting the contents of the X selection)
# Утилита командной строки для получения содержимого выделения в X и его
# помещения/вставки в/из clipboard

# Required:    xorg-libraries
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

autoreconf -vif || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (program for getting/setting the contents of the X selection)
#
# XSel is a command-line program for getting and setting the contents of the X
# selection. Normally this is only accessible by manually highlighting
# information and pasting it with the middle mouse button.
#
# Home page: https://vergenet.net/~conrad/software/${PRGNAME}/
# Download:  https://github.com/kfish/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
