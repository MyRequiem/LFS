#! /bin/bash

PRGNAME="mypaint-brushes"

### mypaint-brushes (brushes for use with libmypaint)
# Официальный базовый набор художественных кистей и текстур для программ
# цифровой живописи. Эти пресеты позволяют имитировать реальные инструменты
# вроде угля, маркеров или масляных красок.

# Required:    libmypaint    (runtime)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (brushes for use with libmypaint)
#
# The mypaint-brushes package contains brushes used by packages which use
# libmypaint.
#
# Home page: https://github.com/Jehan/${PRGNAME}
# Download:  https://github.com/mypaint/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
