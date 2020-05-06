#! /bin/bash

PRGNAME="libexif"

### libexif (Exchangeable Image File Format library)
# EXIF - формат файла изображений, который используется для хранения
# дополнительной информации. Большинство цифровых камер создают файлы EXIF,
# представляющие собой файлы JPEG с дополнительными тегами, содержащие
# информацию об изображении. Поддерживаются все теги EXIF, описанные в
# стандарте EXIF 2.1. Библиотека libexif позволяет таким программам, как
# gthumb, анализировать, редактировать и сохранять EXIF данные.

# http://www.linuxfromscratch.org/blfs/view/stable/general/libexif.html

# Home page: https://libexif.github.io/
# Download:  https://downloads.sourceforge.net/libexif/libexif-0.6.21.tar.bz2
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.1/libexif-0.6.21-security_fix-1.patch

# Required: no
# Optional: doxygen
#           graphviz

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим integer overflow проблему
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-security_fix-1.patch" || exit 1

./configure          \
    --prefix=/usr    \
    --disable-static \
    --with-doc-dir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Exchangeable Image File Format library)
#
# EXIF stands for Exchangeable Image File Format, which is a format used to
# store extra information in images. Most digital cameras produce EXIF files,
# which are JPEG files with extra tags that contain information about the
# image. All EXIF tags described in EXIF standard 2.1 are supported. The
# libexif library allows programs such as gthumb to parse, edit, and save EXIF
# data.
#
# Home page: https://libexif.github.io/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
