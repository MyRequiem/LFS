#! /bin/bash

PRGNAME="webp-pixbuf-loader"

### webp-pixbuf-loader (WEBP loader for gdk-pixbuf2)
# Библиотека добавляет поддержку формата изображений WebP в приложения,
# использующие фреймворк GDK Pixbuf, позволяя таким программам, как просмотрщик
# изображений Eye of GNOME или Shotwell, открывать, предпросматривать и
# редактировать WebP файлы

# Required:    gdk-pixbuf
#              libwebp
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# добавим формат WEBP в кеш загрузчиков (обновим кэш)
gdk-pixbuf-query-loaders --update-cache

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (WEBP loader for gdk-pixbuf2)
#
# The webp-pixbuf-loader package contains a library that allows gdk-pixbuf to
# load and process webp images
#
# Home page: https://github.com/aruiz/${PRGNAME}/
# Download:  https://github.com/aruiz/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
