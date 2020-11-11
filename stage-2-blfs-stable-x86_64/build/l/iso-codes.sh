#! /bin/bash

PRGNAME="iso-codes"

### ISO Codes (ISO-standard lists)
# Пакет предоставляет списки различных стандартов ISO (страна, язык, названия
# валют и т.д.), которые используются в качестве центральной базы данных для
# доступа к этим данным.

# Required:    no
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
# make check

# если мы устанавливаем пакет поверх предыдущей установленной версии,
# 'make install' потерпит неудачу при создании некоторых символических ссылок.
# Обновим эти ссылки так как нужно:
if [ -d /usr/share/iso-codes ]; then
    sed -i '/^LN_S/s/s/sfvn/' */Makefile
fi

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ISO-standard lists)
#
# This package provides lists of various ISO standards (e.g. country, language,
# language scripts, and currency names) in one place, rather than repeated in
# many programs throughout the system. It is used as a central database for
# accessing this data.
#
# Home page: http://pkg-isocodes.alioth.debian.org/
# Download:  http://anduin.linuxfromscratch.org/BLFS/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
