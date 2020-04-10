#! /bin/bash

PRGNAME="mpfr"

### Mpfr (Multiple-Precision Floating-Point Reliable Library)
# Библиотека содержит подпрограммы для математических вычислений с
# множественной точностью.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/mpfr.html

# Home page: https://www.mpfr.org/
# Download:  http://www.mpfr.org/mpfr-4.0.2/mpfr-4.0.2.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --disable-static     \
    --enable-thread-safe \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# сборка документации
make html || exit 1

###
# Важно !!!
###
# Набор тестов для Mpfr на данном этапе считается критическим. Нельзя
# пропускать его ни при каких обстоятельствах
make check

# установка пакета и документации
make install
make install-html
make install DESTDIR="${TMP_DIR}"
make install-html DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Multiple-Precision Floating-Point Reliable Library)
#
# The MPFR library is a C library for multiple-precision floating-point
# computations with exact rounding (also called correct rounding). It is based
# on the GMP multiple-precision library. The main goal of MPFR is to provide a
# library for multiple-precision floating-point computation which is both
# efficient and has well-defined semantics.
#
# Home page: https://www.mpfr.org/
# Download:  http://www.mpfr.org/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
