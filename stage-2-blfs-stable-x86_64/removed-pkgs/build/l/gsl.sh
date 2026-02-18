#! /bin/bash

PRGNAME="gsl"

### Gsl (a numerical library for C and C++ programmers)
# C-библиотека для числовых и научных вычислений, предоставляющая сотни функций
# для работы с математикой, статистикой, генераторами случайных чисел,
# специальными функциями и многим другим, что делает ее мощным инструментом для
# программистов, работающих в области науки и инженерии под Linux и другими ОС

# Required:    no
# Recommended: no
# Optional:    python3-sphinx-rtd-theme    (для создания документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a numerical library for C and C++ programmers)
#
# The GNU Scientific Library (GSL) is a numerical library for C and C++
# programmers. It provides a wide range of mathematical routines such as random
# number generators, special functions and least-squares fitting
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
