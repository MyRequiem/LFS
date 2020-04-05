#! /bin/bash

PRGNAME="autoconf"

### Autoconf
# Пакет макросов m4, которые создают сценарии оболочки для автоматической
# настройки пакетов исходного кода программного обеспечения.

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/autoconf.html

# Home page: http://www.gnu.org/software/autoconf/
# Download:  http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# исправим ошибку генерируемую Perl 5.28
sed '361 s/{/\\{/' -i bin/autoscan.in

./configure \
    --prefix=/usr || exit 1

make || exit 1
# набор тестов не проходит на bash-5 и libtool-2.4.3
make check
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

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

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
