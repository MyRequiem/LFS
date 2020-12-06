#! /bin/bash

PRGNAME="mozjs"
ARCH_NAME="firefox"

### mozjs (Mozillas JavaScript engine)
# Движок Mozilla JavaScript, написанный на C. Включает в себя интерпретатор
# JavaScript и библиотеки.

# Required:    autoconf213
#              icu
#              python2
#              which
# Recommended: no
# Optional:    llvm    (собранный с clang)
#              nasm
#              doxygen (для создания документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
        -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
        cut -d - -f 2 | rev | cut -d . -f 4- | rev | cut -d e -f 1)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# система сборки Firefox выполняет поиск rustc и cargo. Поскольку мы строим
# автономный движок JS, а не весь браузер, они фактически не используются,
# поэтому удалим ссылку на них, чтобы мы могли собрать mozjs без rustc и cargo
sed '21,+4d' -i js/moz.configure || exit 1

mkdir mozjs-build
cd mozjs-build || exit 1

# обязательно передаем в окружение переменную SHELL, иначе конфигурация
# завершится ошибкой
SHELL=/bin/bash
export SHELL

# система сборки Firefox теперь предпочитает clang, поэтому переопределим его
#    CC=gcc CXX=g++
# система сборки firefox ищет файл llvm-objdump, но поскольку мы строим
# автономный движок JS, а не весь браузер, llvm практически не используется,
# поэтому переопределим переменную для сборки движка без llvm
#    LLVM_OBJDUMP=/bin/false
# jemalloc который содержит mozjs конфликтует с malloc из glibc, поэтому
# отключаем его
#    --disable-jemalloc
CC=gcc CXX=g++ LLVM_OBJDUMP=/bin/false \
../js/src/configure                    \
    --prefix=/usr                      \
    --with-intl-api                    \
    --with-system-zlib                 \
    --with-system-icu                  \
    --disable-jemalloc                 \
    --disable-debug-symbols            \
    --enable-readline                  \
    --enable-unaligned-private-values || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

# удалим достаточно большую статическую библиотеку, которая не используется ни
# одним пакетом в BLFS
rm -vf "${TMP_DIR}/usr/lib/libjs_static.ajs"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
chmod 644 "${TMP_DIR}/usr/lib/pkgconfig/mozjs-${MAJ_VERSION}.pc"

# установим ссылки в /usr/bin
#    js        -> js${MAJ_VERSION}
#    js-config -> js${MAJ_VERSION}-config
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -svf "js${MAJ_VERSION}" js
    ln -svf "js${MAJ_VERSION}-config" js-config
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Mozillas JavaScript engine)
#
# Mozillas JavaScript engine written in C. It include JavaScript interpreter
# and libraries.
#
# Home page: http://ftp.gnome.org/pub/gnome/teams/releng/tarballs-needing-help/${PRGNAME}/
# Download:  https://archive.mozilla.org/pub/${ARCH_NAME}/releases/${VERSION}esr/source/${ARCH_NAME}-${VERSION}esr.source.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
