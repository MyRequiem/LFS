#! /bin/bash

PRGNAME="gnome-system-monitor"

### GNOME System Monitor (GNOME System Monitor)
# Штатная графическая утилита в среде рабочего стола GNOME для просмотра и
# управления системными процессами, а также для мониторинга использования
# системных ресурсов, таких как CPU, оперативная память (RAM), swap (файл
# подкачки) и сетевая активность в реальном времени.

# Required:    adwaita-icon-theme
#              gtkmm4
#              itstool
#              libgtop
#              libadwaita
#              librsvg
# Recommended: no
# Optional:    appstream-glib
#              desktop-file-utils
#              catch2                   (https://github.com/catchorg/Catch2)
#              uncrustify               (https://github.com/uncrustify/uncrustify)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим жесткую зависимость от catch2, которая используется только при
# выполнении модульных тестов
# shellcheck disable=SC2038
find . -name meson.build | xargs sed -i -e '/catch2/d' || exit 1
sed -i '152,162d' src/meson.build                      || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    -D systemd=false    \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/help"
rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME System Monitor)
#
# The GNOME System Monitor package contains GNOME's replacement for gtop
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
