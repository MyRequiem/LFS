#! /bin/bash

PRGNAME="talloc"

### Talloc (memory pool system library)
# Предоставляет иерархическую систему пула памяти с подсчетом ссылок и
# деструкторами. Является основным распределителем памяти, используемым в Samba

# Required:    no
# Recommended: no
# Optional:    docbook-xml (для генерации man-страниц)
#              docbook-xsl (для генерации man-страниц)
#              libxslt     (для генерации man-страниц)
#              python2     (для сборки python-2 модуля) https://www.python.org/downloads/release/python-2718/
#              gdb
#              git
#              libnsl
#              libtirpc
#              valgrind
#              xfsprogs

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (memory pool system library)
#
# Talloc provides a hierarchical, reference counted memory pool system with
# destructors. It is the core memory allocator used in Samba.
#
# Home page: https://${PRGNAME}.samba.org
# Download:  https://www.samba.org/ftp/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
