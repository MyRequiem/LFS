#! /bin/bash

PRGNAME="libgweather"

### libgweather (weather library for GNOME)
# Библиотека, используемая для доступа к информации о погоде из онлайн-сервисов

# Required:    geocode-glib
#              gtk+3
#              libsoup3
#              python3-pygobject3
# Recommended: glib
#              libxml2
#              vala
# Optional:    python3-gi-docgen
#              llvm
#              pylint               (https://pypi.org/project/pylint/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему с отправкой данных геолокации
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-upstream_fix-1.patch" || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false    \
    .. || exit 1

ninja || exit 1
# LC_ALL=C ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (weather library for GNOME)
#
# The libgweather package is a library used to access weather information from
# online services for numerous locations
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
