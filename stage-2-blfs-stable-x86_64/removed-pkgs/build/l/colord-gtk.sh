#! /bin/bash

PRGNAME="colord-gtk"

### colord-gtk (GTK integration for libcolord)
# Обеспечивает интеграцию системы управления цветом (colord) с графическим
# тулкитом GTK. Он включает в себя GTK-виджеты для управления цветовыми
# профилями и позволяет приложениям, использующим GTK, взаимодействовать с
# демоном colord для точного управления цветом устройств.

# Required:    colord
#              gtk+3
# Recommended: glib
#              gtk4
#              vala
# Optional:    --- для man-страниц ---
#              docbook-xml
#              docbook-xsl-ns
#              libxslt
#              --- для документации ---
#              gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

###
# Warning
#    Если создаем документацию, то сборка должна быть в один поток (-j1)
###

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D gtk4=true        \
    -D vapi=true        \
    -D docs=false       \
    -D man=false        \
    .. || exit 1

ninja || exit 1
# тесты должны запускаться в графическом сеансе
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GTK integration for libcolord)
#
# The Colord GTK package contains GTK+ bindings for Colord
#
# Home page: https://www.freedesktop.org/software/colord/
# Download:  https://www.freedesktop.org/software/colord/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
