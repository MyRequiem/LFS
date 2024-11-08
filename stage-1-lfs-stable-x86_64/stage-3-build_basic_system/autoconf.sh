#! /bin/bash

PRGNAME="autoconf"

### Autoconf (generate configuration scripts)
# Пакет макросов m4, которые создают сценарии оболочки для автоматической
# настройки пакетов исходного кода программного обеспечения.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (generate configuration scripts)
#
# GNU autoconf is an extensible package of m4 macros that produce shell scripts
# to automatically configure software source code packages. These scripts can
# adapt the packages to many kinds of UNIX-like systems without manual user
# intervention. Autoconf creates a configuration script for a package from a
# template file that lists the operating system features that the package can
# use, in the form of m4 macro calls. You must install the "m4" package to be
# able to use autoconf.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
