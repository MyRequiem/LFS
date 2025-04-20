#! /bin/bash

PRGNAME="libcap-ng"

### libcap-ng (capabilities library and utilities)
# Библиотека предназначенная для программирования с возможностями POSIX. В
# пакет также входят утилиты, помогающие проанализировать систему на предмет
# запущенных программ, которые могут иметь слишком много привилегий.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --with-python3   \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (capabilities library and utilities)
#
# The libcap-ng library is intended to make programming with POSIX capabilities
# easier. The package also includes utilities to help analyze a system for
# programs that may have too much privilege.
#
# Home page: https://people.redhat.com/sgrubb/${PRGNAME}/
# Download:  https://people.redhat.com/sgrubb/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
