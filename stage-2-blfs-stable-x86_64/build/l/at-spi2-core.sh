#! /bin/bash

PRGNAME="at-spi2-core"

### At-Spi2 Core (Assistive Technology Service Provider Interface core)
# At-Spi2 Core предоставляет фреймворк для обеспечения двунаправленной связи
# между вспомогательными технологиями (AT) и приложениями. Является стандартом
# для обеспечения доступности открытых рабочих столов под руководством проекта
# GNOME

# Required:    dbus
#              glib
#              xorg-libraries
# Recommended: no
# Optional:    gobject-introspection
#              gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

mkdir build
cd build || exit 1

# помещаем файл модуля systemd в /tmp, откуда мы его потом удаляем, т.к.
# System V не может использовать этот файл
#    -Dsystemd_user_dir=/tmp
meson                                  \
    --prefix=/usr                      \
    -Ddocs="${DOCS}"                   \
    -Dsystemd_user_dir=/tmp            \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/tmp"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Assistive Technology Service Provider Interface core)
#
# The At-Spi2 Core package is a part of the GNOME Accessibility Project. It
# provides a service provider interface for the assistive technologies
# available on the GNOME platform and a library against which applications can
# be linked.
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
