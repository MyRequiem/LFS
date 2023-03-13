#! /bin/bash

PRGNAME="less"

### Less (file pager)
# Средство просмотра текстовых файлов (Pager)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || make -j1 || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (file pager)
#
# Less is a paginator similar to more, but which allows backward movement in
# the file as well as forward movement. Also, less does not have to read the
# entire input file before starting, so with large input files it starts up
# faster than text editors like vi.
#
# Home page: http://www.greenwoodsoftware.com/${PRGNAME}/
# Download:  http://www.greenwoodsoftware.com/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
