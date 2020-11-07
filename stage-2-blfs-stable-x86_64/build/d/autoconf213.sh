#! /bin/bash

PRGNAME="autoconf213"
ARCH_NAME="autoconf"

### autoconf213 (generate configuration scripts)
# Пакет макросов m4, которые создают сценарии оболочки для автоматической
# настройки пакетов исходного кода программного обеспечения.

# Required:    no
# Recommended: no
# Optional:    no

###
# autoconf213 является старой версией Autoconf. Эта версия принимает флаги
# сборки, которые не действительны в более поздних версиях. Данная версия
# требуется для сборки Firefox и некоторых других программ.

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-consolidated_fixes-1.patch" || exit 1

mv -v autoconf.texi "${PRGNAME}.texi"
rm -v autoconf.info

./configure       \
    --prefix=/usr \
    --program-suffix="${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

install -v -m644 "${PRGNAME}.info" "${TMP_DIR}/usr/share/info"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Home page: http://www.gnu.org/software/${ARCH_NAME}/
# Download:  https://ftp.gnu.org/gnu/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
