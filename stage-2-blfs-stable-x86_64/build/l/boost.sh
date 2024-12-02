#! /bin/bash

PRGNAME="boost"

### Boost (Boost C++ Libraries)
# Набор библиотек классов, использующих функциональность языка C++ и
# предоставляющих удобный кроссплатформенный высокоуровневый интерфейс для
# лаконичного кодирования различных повседневных подзадач программирования
# (работа с данными, алгоритмами, файлами, потоками и т. п.)

# Required:    no
# Recommended: which
# Optional:    icu
#              python3-numpy
#              open-mpi      (https://www.open-mpi.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}-*.tar.?z*" \
    2>/dev/null | head -n 1 | rev | cut -d - -f 3 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr"

# исправим проблему сборки boost с python3-numpy
patch --verbose -Np1 \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-upstream_fixes-1.patch" || exit 1

# пакет лучше собирать в несколько потоков
NUMJOBS="${MAKEFLAGS}"
[ -z "${NUMJOBS}" ] && NUMJOBS="-j$(nproc)"

./bootstrap.sh    \
    --prefix=/usr \
    --with-python=python3 || exit 1

# гарантирует, что Boost будет построен с поддержкой многопоточности
#    threading=multi
# создаем только shared библиотеки, за исключением libboost_exception и
# libboost_test_exec_monitor, которые создаются как статические
#    link=shared
./b2 stage "${NUMJOBS}" \
    threading=multi     \
    link=shared || exit 1

# тесты
# pushd tools/build/test || exit 1
# python3 test_all.py
# popd || exit 1

# Boost устанавливает множество каталогов в /usr/lib/cmake. Если новая версия
# Boost установливается поверх предыдущей версии, старые каталоги cmake должны
# быть явно удалены:
rm -rf /usr/lib/cmake/[Bb]oost*

./b2 install        \
    threading=multi \
    link=shared     \
    --prefix="${TMP_DIR}/usr"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Boost C++ Libraries)
#
# Boost provides free peer-reviewed portable C++ source libraries. The emphasis
# is on libraries that work well with the C++ Standard Library. One goal is to
# establish "existing practice" and provide reference implementations so that
# the Boost libraries are suitable for eventual standardization. It includes
# libraries for linear algebra, pseudorandom number generation, multithreading,
# image processing, regular expressions and unit testing.
#
# Home page: http://www.${PRGNAME}.org/
# Download:  https://github.com/boostorg/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}-b2-nodocs.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
