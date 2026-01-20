#! /bin/bash

PRGNAME="eog"

### EOG (This is the Eye of GNOME)
# Стандартный, простой и быстрый просмотрщик изображений для среды рабочего
# стола GNOME, позволяющий открывать, масштабировать, вращать картинки,
# просматривать их в виде слайд-шоу и видеть метаданные (EXIF)

# Required:    adwaita-icon-theme
#              exempi
#              gnome-desktop
#              libhandy
#              libjpeg-turbo
#              libpeas
#              shared-mime-info
# Recommended: glib
#              lcms2
#              libexif
#              librsvg
#              webp-pixbuf-loader
# Optional:    gtk-doc
#              libportal

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
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

ln -s eog/libeog.so "${TMP_DIR}/usr/lib/libeog.so"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим MIME кэш
update-desktop-database

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (This is the Eye of GNOME)
#
# EOG is an application used for viewing and cataloging image files on the
# GNOME Desktop. It also has basic editing capabilities
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
