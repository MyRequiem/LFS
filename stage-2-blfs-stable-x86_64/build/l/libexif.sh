#! /bin/bash

PRGNAME="libexif"

### libexif (Exchangeable Image File Format library)
# EXIF - формат файла изображений, который используется для хранения
# дополнительной информации. Большинство цифровых камер создают файлы EXIF,
# представляющие собой файлы JPEG с дополнительными тегами, содержащие
# информацию об изображении. Поддерживаются все теги EXIF, описанные в
# стандарте EXIF 2.1. Библиотека libexif позволяет таким программам, как
# gthumb, анализировать, редактировать и сохранять EXIF данные.

# Required:    no
# Recommended: no
# Optional:    doxygen  (для создания документации)
#              graphviz (для создания документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-security_fixes-1.patch" || exit 1

DOXYGEN="--disable-internal-docs"
# command -v doxygen &>/dev/null && DOXYGEN="--enable-internal-docs"

./configure          \
    --prefix=/usr    \
    --disable-static \
    "${DOXYGEN}"     \
    --with-doc-dir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${PRGNAME}-${VERSION//./_}-release/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
