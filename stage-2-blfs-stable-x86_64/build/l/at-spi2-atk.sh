#! /bin/bash

PRGNAME="at-spi2-atk"

### At-Spi2 Atk (AT-SPI2 bridge to ATK)
# Библиотека, которая связывает ATK с сервисом At-Spi2 D-Bus

# Required:    at-spi2-core
#              atk
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

TESTS="false"

mkdir build
cd build || exit 1

meson                  \
    --prefix=/usr      \
    -Dtests="${TESTS}" \
    .. || exit 1

ninja || exit 1

# для тестов меняем переменную TESTS выше на true
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# создадим/обновим /usr/share/glib-2.0/schemas/gschemas.compiled (если в
# директории присутствуют файлы схем *.xml)
glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (AT-SPI2 bridge to ATK)
#
# The At-Spi2 Atk package contains a library that bridges ATK to the At-Spi2
# D-Bus service.
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
