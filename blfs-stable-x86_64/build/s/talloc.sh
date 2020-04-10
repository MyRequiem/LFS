#! /bin/bash

PRGNAME="talloc"

### Talloc (memory pool system)
# Иерархическая система пулов памяти со счетчиками и деструкторами. Является
# основной системой выделения памяти, используемой в Samba

# http://www.linuxfromscratch.org/blfs/view/9.0/general/talloc.html

# Home page: http://talloc.samba.org/
# Download:  https://www.samba.org/ftp/talloc/talloc-2.2.0.tar.gz

# Required: no
# Optional: docbook-xml
#           docbook-xsl
#           libxslt (для создания man-страниц),
#           python2 (для создания Python2 модулей)
#           gdb
#           git
#           xfsprogs
#           libtirpc
#           valgrind

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (memory pool system)
#
# Talloc provides a hierarchical, reference counted memory pool system with
# destructors. It is the core memory allocator used in Samba
#
# Home page: http://talloc.samba.org/
# Download:  https://www.samba.org/ftp/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
