#! /bin/bash

PRGNAME="python3"
ARCH_NAME="Python"

### python3 (object-oriented interpreted programming language)
# Python 3 интерпретатор

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

# связываться с уже установленной системной версией Expat
#    --with-system-expat
# связываться с уже установленной системной версией libffi
#    --with-system-ffi
./configure                \
    --prefix=/usr          \
    --enable-shared        \
    --with-system-expat    \
    --enable-optimizations \
    --without-static-libpython || exit 1

make || make -j1 || exit 1
# make test TESTOPTS="--timeout 120"
make install DESTDIR="${TMP_DIR}"

cat << EOF > "${TMP_DIR}/etc/pip.conf"
[global]
# do not display warnings when running from root
root-user-action = ignore
# do not display warnings about the presence of a newer pip3 version
disable-pip-version-check = true
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (object-oriented interpreted programming language)
#
# Python is an interpreted, interactive, object-oriented programming language
# that combines remarkable power with very clear syntax. Python's basic power
# can be extended with your own modules written in C or C++. Python is also
# adaptable as an extension language for existing applications.
#
# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/${VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
