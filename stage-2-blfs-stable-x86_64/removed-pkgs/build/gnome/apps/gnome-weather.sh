#! /bin/bash

PRGNAME="gnome-weather"

### GNOME Weather (GNOME Weather)
# Приложение входящее в среду рабочего стола GNOME, которое позволяет
# отслеживать текущую погоду и получать подробные прогнозы для вашего города
# или любой точки мира, используя различные интернет-сервисы

# Required:    geoclue
#              gjs
#              libadwaita
#              libgweather
# Recommended: no
# Optional:    appstream-glib

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

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Weather)
#
# GNOME Weather is a small application that allows you to monitor the current
# weather conditions for your city, or anywhere in the world, and to access
# updated forecasts provided by various internet services
#
# Home page:  https://github.com/GNOME/${PRGNAME}
# Download:   https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
