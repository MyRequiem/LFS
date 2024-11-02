#! /bin/bash

PRGNAME="libxcrypt"

### libxcrypt (library for one-way hashing of passwords)
# современная библиотека для одностороннего хеширования паролей

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure                      \
    --prefix=/usr                \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=no     \
    --disable-static             \
    --disable-failure-tokens || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for one-way hashing of passwords)
#
# The Libxcrypt package contains a modern library for one-way hashing of
# passwords
#
# Home page: https://github.com/besser82/${PRGNAME}/
# Download:  https://github.com/besser82/${PRGNAME}/releases/download/v4.4.36/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
