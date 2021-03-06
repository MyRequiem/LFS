#! /bin/bash

PRGNAME="mpc"

### Mpc (Multiple Precision Complex Library)
# Пакет содержит библиотеку для арифметики комплексных чисел с произвольно
# высокой точностью и правильным округлением результата.

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
# сборка html-документации
# make html || exit 1

# make check

make install DESTDIR="${TMP_DIR}"
# make install-html DESTDIR="${TMP_DIR}"

rm -f "${TMP_DIR}/usr/share/info/dir"

/bin/cp -vR "${TMP_DIR}"/* /

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Multiple Precision Complex Library)
#
# mpc is a complex floating-point library with exact rounding. It is based on
# the GNU MPFR floating-point library, which is itself based on the GNU MP
# library. Package contains a library for the arithmetic of complex numbers
# with arbitrarily high precision and correct rounding of the result.
#
# Home page: http://www.multiprecision.org/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
