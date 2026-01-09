#! /bin/bash

PRGNAME="libpeas"

### libpeas (GObject Plugin System)
# Основанный на GObject движок плагинов, который позволяет приложениям
# расширять свои возможности. Он используется для добавления новых функций в
# различные программы, такие как текстовый редактор Gedit, музыкальный плеер
# Rhythmbox и другие приложения, разработанные для среды GNOME

# Required:    glib
#              gtk+3
# Recommended: libxml2
# Optional:    python3-gi-docgen
#              glade                (https://glade.gnome.org/)
#              embed                (https://pypi.org/project/embed)
#              lgi                  (https://github.com/pavouk/lgi)
#              luajit или lua       =5.1 (https://www.lua.org/ftp/lua-5.1.5.tar.gz)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                \
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
    -D python3=false       \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GObject Plugin System)
#
# libpeas is a GObject based plugins engine, and is targeted at giving every
# application the chance to assume its own extensibility
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
