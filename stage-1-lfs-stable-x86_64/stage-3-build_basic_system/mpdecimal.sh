#! /bin/bash

PRGNAME="mpdecimal"

### mpdecimal (Arbitrary precision decimal floating point library)
# Библиотека на C/C++ для высокоточных вычислений с десятичными числами
# произвольной разрядности, исключающая ошибки округления двоичной арифметики.
# Является основой стандартного модуля decimal в языке Python.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
# make check_local
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}stripping.sh"      || exit 1
source "${ROOT}update-info-db.sh" || exit 1
source "${ROOT}clean-locales.sh"  || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Arbitrary precision decimal floating point library)
#
# mpdecimal is a package for correctly-rounded arbitrary precision decimal
# floating point arithmetic. It delivers complete support for the IEEE 754
# decimal formats and arbitrary precision arithmetic.
#
# This library is an essential dependency for the Python standard library
# 'decimal' module in newer Python versions.
#
# Home page: https://www.bytereef.org/${PRGNAME}/
# Download:  https://www.bytereef.org/software/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
