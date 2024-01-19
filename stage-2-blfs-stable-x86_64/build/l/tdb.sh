#! /bin/bash

PRGNAME="tdb"

### tdb (a trivial database library)
# Простой API базы данных для совместного использования структур между частями
# Samba. Интерфейс основан на gdbm

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
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a trivial database library)
#
# Tdb is a simple database API. It was inspired by the realisation that in
# Samba there were several ad-hoc bits of code that essentially implement small
# databases for sharing structures.
#
# Home page: https://${PRGNAME}.samba.org/
# Download:  https://www.samba.org/ftp/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
