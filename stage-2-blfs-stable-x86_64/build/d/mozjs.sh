#! /bin/bash

PRGNAME="mozjs"
ARCH_NAME="firefox"

### mozjs (Mozillas JavaScript engine)
# Движок Mozilla JavaScript, написанный на C. Включает в себя интерпретатор
# JavaScript и библиотеки.

# Required:    icu
#              rustc
#              which
# Recommended: no
# Optional:    no

### NOTE:
# Перед обновлением рекомендуется удалить пакет из системы

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

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir obj
cd obj || exit 1

# обязательно передаем в окружение переменную SHELL, иначе конфигурация
# завершится ошибкой
SHELL=/bin/bash
export SHELL

# система сборки firefox ищет файл llvm-objdump, но поскольку мы строим
# автономный движок JS, а не весь браузер, llvm практически не используется,
# поэтому переопределим переменную для сборки движка без llvm
#    LLVM_OBJDUMP=/bin/false
# jemalloc который содержит mozjs конфликтует с malloc из glibc, поэтому
# отключаем его
#    --disable-jemalloc
sh ../js/src/configure.in       \
    --prefix=/usr               \
    --with-intl-api             \
    --with-system-zlib          \
    --with-system-icu           \
    --disable-jemalloc          \
    --disable-debug-symbols     \
    --enable-readline || exit 1

make || exit 1

# JS тесты
# make -C js/src check-jstests JSTESTS_EXTRA_ARGS="--timeout 300 --wpt=disabled"
# JIT тесты
# make -C js/src check-jit-test JITTEST_EXTRA_ARGS="--timeout 300"

# процесс установки приводит к сбою любой работающей программы, которая
# ссылается на библиотеку JS102 (например, GNOME Shell), поэтому перед
# установкой удалим старую версию библиотеки:
rm -fv /usr/lib/libmozjs-102.so
make install DESTDIR="${TMP_DIR}"

# удалим достаточно большую статическую библиотеку, которая не используется ни
# одним пакетом в BLFS
rm -vf "${TMP_DIR}/usr/lib/libjs_static.ajs"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
chmod 644 "${TMP_DIR}/usr/lib/pkgconfig/mozjs-${MAJ_VERSION}.pc"

# запретим jsXXX-config использовать ошибочные CFLAGS
sed -i '/@NSPR_CFLAGS@/d' "${TMP_DIR}/usr/bin/js${MAJ_VERSION}-config"

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
