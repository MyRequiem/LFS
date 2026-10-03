#! /bin/bash

PRGNAME="archivemount"

### archivemount (mounts an archive for access as a file system)
# Основанная на FUSE утилита для монтирования архивов, позволяющая открывать и
# изменять содержимое архива так же просто, как файлы в обычной директории.

# Required:    libarchive
#              fuse3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    cut -d _ -f 2 | cut -d . -f 1)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}_${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-ng-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Исправляем ошибку в man-странице: заменяем стандартный 'umount' на
# 'fusermount -u', так как FUSE-диски правильно размонтировать именно им.
sed -i '/^\.Li.*umount/s,umount,fusermount Fl u,' "${PRGNAME}.1.in" || exit 1

# Обходим привязку к .git в Makefile: фиксируем версию и дату для man-страницы.
# VERSION и SOURCE_DATE_EPOCH передаются вручную, так как исходники берутся из
# тарболла, а не из git-репозитория. Это предотвращает не критичные ошибки
# сборки 'fatal: не найден git репозиторий' и 'date: invalid date', а также
# корректно прописывает дату сборки в man-страницу.
make                     \
    VERSION="${VERSION}" \
    SOURCE_DATE_EPOCH="$(stat -c %Y archivemount.1.in)" || exit 1

make PREFIX=/usr install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (mounts an archive for access as a file system)
#
# archivemount is a FUSE based file system. Its purpose is to mount an archive
# on a mount point where it can be read from or written to as with any other
# file system. This makes accessing the contents of the archive, which may be
# compressed, transparent to other programs, without decompressing them.
# Supported archive formats: tar, pax, cpio, iso9660 (CD-ROM) images, zip,
# shar. Other archive types such as rar and 7z may also work.
#
# Home page: https://sr.ht/~nabijaczleweli/${PRGNAME}-ng/
# Download:  https://deb.debian.org/debian/pool/main/a/${PRGNAME}/${PRGNAME}_${VERSION}.orig.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
