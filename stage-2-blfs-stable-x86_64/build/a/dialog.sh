#! /bin/bash

PRGNAME="dialog"

### dialog (display dialog boxes from shell scripts)
# утилита для создания диалоговых окон из сценариев оболочки

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION_ORIG="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1,2 | rev)"

VERSION=${VERSION_ORIG/-/.}
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION_ORIG}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION_ORIG}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# исправим проблемы форматирования
zcat "${SOURCES}/${PRGNAME}.all.use_height.diff.gz" | \
    patch -p1 --verbose || exit 1
zcat "${SOURCES}/${PRGNAME}.smaller.min.height.diff.gz" | \
    patch -p1 --verbose || exit 1
zcat "${SOURCES}/${PRGNAME}.no.aspect.ratio.autoajust.patch.gz" | \
    patch -p1 --verbose || exit 1

./configure          \
    --prefix=/usr    \
    --disable-static \
    --enable-nls     \
    --with-ncurses   \
    --enable-widec || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# удалим статическую библиотеку
if [ -f "${TMP_DIR}/usr/lib/libdialog.a" ]; then
    rm -f "${TMP_DIR}/usr/lib/libdialog.a"
    rmdir "${TMP_DIR}/usr/lib" 2>/dev/null
fi

cat samples/slackware.rc > "${TMP_DIR}/etc/dialogrc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (display dialog boxes from shell scripts)
#
# Dialog is a program to present a variety of questions or display messages
# using dialog boxes from a shell script
#
# Home page: https://invisible-island.net/${PRGNAME}/
# Download:  https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}/${PRGNAME}-${VERSION_ORIG}.tar.lz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
