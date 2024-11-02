#! /bin/bash

PRGNAME="gmp"

### Gmp (GNU multiple precision arithmetic library)
# Содержит математические библиотеки, в которых содержатся полезные функции для
# арифметики произвольной точности

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

###
# Внимание !!!
###
# Код в gmp высоко оптимизирован для процессора, на котором он собран. Иногда
# код, обнаруживающий процессор, неверно определяет возможности системы, и в
# тестах или других приложениях, использующих библиотеки gmp возникают ошибки с
# сообщением "Illegal instruction". В этом случае gmp следует сконфигурировать
# с параметром --build=x86_64-unknown-linux-gnu, где unknown это slackware, lfs
# и т.д., а затем пересобрать

# включаем поддержку C++
#    --enable-cxx
./configure          \
    --prefix=/usr    \
    --enable-cxx     \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# Набор тестов для Gmp на данном этапе считается критическим. Нельзя пропускать
# его ни при каких обстоятельствах
# make check 2>&1 | tee gmp-check-log

# убедимся, что все 199 тестов в наборе пройдены
# echo ""
# echo "======================= Test results ======================="
# echo "There must be 199 tests passed:"
# awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
# echo    "============================================================"
# echo -n "View the results and then press any key... "
# read -r JUNK
# echo "${JUNK}" > /dev/null

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU multiple precision arithmetic library)
#
# GNU MP is a library for arbitrary precision arithmetic, operating on signed
# integers, rational numbers, and floating point numbers. It has a rich set of
# functions, and the functions have a regular interface.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
