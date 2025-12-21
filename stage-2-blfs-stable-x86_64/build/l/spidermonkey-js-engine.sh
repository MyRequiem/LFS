#! /bin/bash

PRGNAME="spidermonkey-js-engine"
ARCH_NAME="firefox"

### mozjs (Mozillas JavaScript engine)
# JS движок SpiderMonkey от Mozilla, который используется для выполнения
# JavaScript в браузере Firefox, а также в других приложениях, например, в
# Node.js при использовании движка v8

# Required:    cbindgen
#              icu
#              which
# Recommended: llvm
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
        -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
        cut -d - -f 2 | rev | cut -d . -f 4- | rev | cut -d e -f 1)"

### NOTE
# извлечение архива от пользователя root приведет к сбросу разрешений текущего
# каталога на 0755. Если мы будет извлекать в директории, где установлен
# "липкий" бит (drwxrwxrwt), например, в каталоге /tmp, то это закончится
# сообщениями об ошибках и "липкий" бит сбросится
#    tar: .: Cannot utime: Operation not permitted
#    tar: .: Cannot change mode to rwxr-xr-t: Operation not permitted
#    tar: Exiting with failure status due to previous errors
#
# По этой причине будем распаковывать и собирать в каталоге /root/src/lfs
###

BUILD_DIR="${ROOT}/build-${PRGNAME}-${VERSION}"
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
../js/src/configure         \
    --prefix=/usr           \
    --disable-debug-symbols \
    --disable-jemalloc      \
    --enable-readline       \
    --enable-rust-simd      \
    --with-intl-api         \
    --with-system-icu       \
    --with-system-zlib || exit 1

make || exit 1

# JS тесты
# make -C js/src check-jstests JSTESTS_EXTRA_ARGS="--timeout 300 --wpt=disabled"
# JIT тесты
# make -C js/src check-jit-test JITTEST_EXTRA_ARGS="--timeout 300"

# JS тесты
# make -C js/src check-jstests \
#     JSTESTS_EXTRA_ARGS="--timeout 300 --wpt=disabled" | tee jstest.log
# JIT тесты
# make -C js/src check-jit-test

# процесс установки приводит к сбою любой работающей программы, которая
# ссылается на библиотеку libmozjs (например, GNOME Shell), поэтому перед
# установкой удалим старую версию библиотеки
rm -fv /usr/lib/libmozjs-*.so

make install DESTDIR="${TMP_DIR}"

# удалим достаточно большую статическую библиотеку, которая не используется ни
# одним пакетом в BLFS
rm -vf "${TMP_DIR}/usr/lib/libjs_static.ajs"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"

chmod 644 "${TMP_DIR}/usr/lib/pkgconfig/mozjs-${MAJ_VERSION}.pc"

# запретим jsXXX-config использовать ошибочные CFLAGS
sed -i '/@NSPR_CFLAGS@/d' \
    "${TMP_DIR}/usr/bin/js${MAJ_VERSION}-config" || exit 1

# исправим проблему с заголовком js-config.h
sed '$i#define XP_UNIX' -i \
    "${TMP_DIR}/usr/include/mozjs-${MAJ_VERSION}/js-config.h" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Mozillas JavaScript engine)
#
# SpiderMonkey is Mozilla's JavaScript and WebAssembly Engine, written in C++
# and Rust. The source code of SpiderMonkey is taken from Firefox
#
# Home page: https://archive.mozilla.org/pub/${ARCH_NAME}/releases/
# Download:  https://archive.mozilla.org/pub/${ARCH_NAME}/releases/${VERSION}esr/source/${ARCH_NAME}-${VERSION}esr.source.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
