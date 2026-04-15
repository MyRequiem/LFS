#! /bin/bash

PRGNAME="librsvg"

### librsvg (SVG library)
# Библиотека и инструменты для управления, преобразования и отрисовки
# масштабируемой векторной графики (SVG). Благодаря им иконки в меню выглядят
# идеально четкими при любом масштабе.

# Required:    cairo
#              cargo-c
#              pango
#              gdk-pixbuf           (в BLFS указана как Recommended, но без
#                                       него не собирается, поэтому указываю
#                                       как Required)
# Recommended: glib
#              vala
# Optional:    python3-docutils     (для генерации man-страниц)
#              python3-gi-docgen    (для документации)
#              dav1d                (для поддержки встроенного AVIF в SVG)

###
# NOTE:
#    при сборке скачиваются дополнительные файлы из сети Internet, поэтому
#    пакет необходимо собирать в чистой среде LFS (не в среде chroot хоста)
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим путь установки API документации
sed -e "/OUTDIR/s|,| / 'librsvg-2.62.1', '--no-namespace-dir',|" \
    -e '/output/s|Rsvg-2.0|librsvg-2.62.1|'                      \
    -i doc/meson.build || exit 1

###
# NOTE
#    Во время сборки скачиваются Rust зависимости. Подготовим их сразу во
#    избежании Download ERROR во время сборки.
###

# скачает и распакует все зависимости в директорию vendor
cargo vendor || exit 1

# настройка cargo для использования локальных (vendored) зависимостей без сети
# (мы уже их скачали и распаковали)
mkdir -pv .cargo
cat << EOF > .cargo/config.toml
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"
EOF

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# meson test -v
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновляем файл /usr/lib/gdk-pixbuf-x.x/x.x.x/loaders.cache
command -v gdk-pixbuf-query-loaders && \
    gdk-pixbuf-query-loaders --update-cache

# очистим rust кэш, мусор не нужен
rm -rf /root/.cargo

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SVG library)
#
# The librsvg package contains a library and tools used to manipulate, convert
# and view Scalable Vector Graphic (SVG) images
#
# Home page: https://wiki.gnome.org/Projects/LibRsvg
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
