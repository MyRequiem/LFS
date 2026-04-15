#! /bin/bash

PRGNAME="glycin"

### glycin (sandboxed and extendable image loading framework)
# Библиотека для безопасного декодирования изображений, которая открывает файлы
# (например, JPEG или PNG) в изолированной «песочнице». Она защищает систему от
# вредоносного кода, который может быть спрятан в коде картинки, используя для
# этого bubblewrap.

# Required:    bubblewrap           (runtime)
#              fontconfig
#              glib
#              lcms2
#              libseccomp
#              rustc
# Recommended: libheif
#              libjxl
#              librsvg
#              vala
# Optional:    python3-gi-docgen
#              gtk4                 (для сборки libglycin-gtk4 и тестов)
#              libopenraw           (https://libopenraw.freedesktop.org/)

###
# NOTE:
#    Для сборки пакета требуется интернет.
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

###
# NOTE
#    Во время сборки скачиваются Rust зависимости. Подготовим их сразу во
#    избежании Download ERROR во время сборки.
###

# Скачает и распакует все зависимости в директорию vendor
cargo vendor || exit 1

# Настройка cargo для использования локальных (vendored) зависимостей без сети
# (мы уже их скачали и распаковали)
mkdir -pv .cargo
cat << EOF > .cargo/config.toml
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"
EOF

# Патчим основной Cargo.toml (чтобы он видел изменения в vendor/glycin) Это
# нужно, если мы меняем код внутри vendor/
cat << EOF >> Cargo.toml

[patch.crates-io]
glycin = { path = "vendor/glycin" }
EOF

# Правим пути в исходниках сандбокса (если X11 не в /usr). Если всё в /usr,
# этот шаг можно пропустить, но если нужно прокинуть либы внутрь пузыря,
# используем sed:
sed -i 's|/tmp-run"|/tmp-run", "/usr/lib", "/usr/lib"|' \
    vendor/glycin/src/sandbox.rs

# исправим ошибку сборки, когда libglycin не установлен в систему
sed -i \
    "s/get_option('libglycin-gtk4')/(& or get_option('glycin-thumbnailer'))/" \
    meson.build

mkdir build
cd build || exit 1

meson setup ..              \
    --prefix=/usr           \
    --buildtype=release     \
    -D libglycin-gtk4=false \
    -D tests=false          \
    -D glycin-loaders=true  \
    -D loaders="glycin-image-rs,glycin-raw,glycin-svg" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (sandboxed and extendable image loading framework)
#
# The glycin package contains a sandboxed and extendable image loading
# framework.
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
