#! /bin/bash

PRGNAME="boost"

### Boost (Boost C++ Libraries)
# Набор библиотек классов, использующих функциональность языка C++ и
# предоставляющих удобный кроссплатформенный высокоуровневый интерфейс для
# лаконичного кодирования различных повседневных подзадач программирования
# (работа с данными, алгоритмами, файлами, потоками и т. п.)

# http://www.linuxfromscratch.org/blfs/view/stable/general/boost.html

# Home page: http://www.boost.org/
# Download:  https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.bz2

# Required:    no
# Recommended: which
# Optional:    icu
#              open-mpi (https://www.open-mpi.org/)

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}*.tar.?z*" \
    2>/dev/null | head -n 1 | rev | cut -d . -f 3- | rev | cut -d _ -f 2-)"
VERSION="$(echo "${ARCH_VERSION}" | tr _ .)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}_${ARCH_VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}_${ARCH_VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr"

./bootstrap.sh \
    --prefix=/usr || exit 1

# пакет должен собираться в несколько потоков, если это возможно
NUMJOBS="$(($(nproc) + 1))"
# гарантирует, что Boost будет построен с поддержкой многопоточности
#    threading=multi
# создаем только shared библиотеки, за исключением libboost_exception и
# libboost_test_exec_monitor, которые создаются как статические
#    link=shared
./b2 stage -j"${NUMJOBS}" threading=multi link=shared || exit 1
./b2 install threading=multi link=shared

# ссылка в /usr/include/boost/uuid/ sha1.hpp -> detail/sha1.hpp
(
    cd "/usr/include/boost/uuid/" || exit 1
    ln -svf detail/sha1.hpp sha1.hpp
)

./bootstrap.sh \
    --prefix="${TMP_DIR}/usr" || exit 1

./b2 stage -j"${NUMJOBS}" threading=multi link=shared || exit 1
./b2 install threading=multi link=shared

(
    cd "${TMP_DIR}/usr/include/boost/uuid/" || exit 1
    ln -svf detail/sha1.hpp sha1.hpp
)

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
# Home page: http://www.boost.org/
# Download:  https://dl.bintray.com/boostorg/release/${VERSION}/source/${PRGNAME}_${ARCH_VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
