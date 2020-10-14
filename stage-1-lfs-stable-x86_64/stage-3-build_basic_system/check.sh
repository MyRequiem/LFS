#! /bin/bash

PRGNAME="check"

### Check (unit testing framework for C)
# Фреймворк для тестов на C

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || make -j1 || exit 1

# make check

make                                              \
    docdir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    install DESTDIR="${TMP_DIR}"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (unit testing framework for C)
#
# Check is a unit testing framework for C.
#
# Home page: https://libcheck.github.io/${PRGNAME}
# Download:  https://github.com/libcheck/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
