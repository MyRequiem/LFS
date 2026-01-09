#! /bin/bash

PRGNAME="gnome-color-manager"

### GNOME Color Manager (GNOME Color Manager)
# Набор утилит и фреймворк для среды рабочего стола GNOME, который позволяет
# пользователям легко управлять, устанавливать и создавать цветовые профили
# (ICC-профили) для своих мониторов, принтеров и других устройств, обеспечивая
# точную и согласованную цветопередачу.

# Required:    colord
#              gtk+3
#              itstool
#              lcms2
# Recommended: desktop-file-utils
# Optional:    docbook-utils        (в настоящее время приводит к сбою сборки)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# если установлен пакет docbook-utils, отключим установку man-страниц, чтобы
# избежать сбоя сборки
sed /subdir\(\'man/d -i meson.build || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# тесты нужно запускать в запущенной X сессии
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Color Manager)
#
# GNOME Color Manager is a session framework for the GNOME desktop environment
# that makes it easy to manage, install and generate color profiles
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
