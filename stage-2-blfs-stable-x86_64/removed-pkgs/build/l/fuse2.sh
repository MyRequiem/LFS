#! /bin/bash

PRGNAME="fuse2"
ARCH_NAME="fuse"

### Fuse (Filesystem in Userspace)
# Технология, позволяющая программам создавать свои виртуальные диски и
# файловые системы без вмешательства в глубокие настройки ядра системы.

# Required:    no
# Recommended: no
# Optional:    no

### Конфигурация ядра
#    CONFIG_FUSE_FS=y|m
#    CONFIG_CUSE=y|m

###
# Тесты
###
#    Можно сразу очень быстро проверить работоспособность fuse2 вот таким
#    смешным способом:). В исходниках лежит <path_to_src_dir>/example/hello.c,
#    после компиляции данного пакета генерируется бинарник hello
#    $ mkdir -p /tmp/fuse2-test
#    $ <path_to_src_dir>/example/hello /tmp/fuse2-test
#    Монтируется директория /tmp/fuse2-test и в ней должен лежать текстовый
#    файл hellow содержащий текст "Hello World!"
#    $ ls /tmp/fuse2-test/
#    hello
#    $ cat /tmp/fuse2-test/hello
#    Hello World!
#
#    Все Ok, отмонтируем:
#    $ fusermount -u /tmp/fuse2-test
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-2*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-fix-build-with-glibc-2.34.patch" || \
        exit 1

# исправим ошибку, которую в данном случае выдает autoreconf
#    possibly undefined macro: AM_ICONV
sed 's/^AM_ICONV/#AM_ICONV/' -i configure.ac || exit 1
autoreconf -vif || exit 1

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --enable-lib         \
    --enable-util        \
    --disable-static     \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

(
    cd "${TMP_DIR}" || exit 1
    rm -rf dev etc usr/share/{doc,gtk-doc,help}

    # /sbin все равно остается, переместим в /usr/
    [ -d sbin ] && mv sbin usr/
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Filesystem in Userspace)
#
# FUSE is a simple interface for userspace programs to export a virtual
# filesystem to the Linux kernel. FUSE also aims to provide a secure method for
# non privileged users to create and mount their own filesystem
# implementations.
#
# Home page: https://github.com/libfuse/libfuse/
# Download:  https://github.com/libfuse/libfuse/releases/download/${ARCH_NAME}-${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
