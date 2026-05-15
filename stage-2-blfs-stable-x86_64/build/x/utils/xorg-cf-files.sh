#! /bin/bash

PRGNAME="xorg-cf-files"

### xorg-cf-files (X11 config files for imake)
# Набор старых конфигурационных файлов, которые необходимы для сборки
# классического софта c помощью системы сборки imake. Это своего рода «архив
# чертежей», без которых не соберутся некоторые старые программы.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..    \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X11 config files for imake)
#
# The xorg-cf-files package contains the data files for the imake utility,
# defining the known settings for a wide variety of platforms (many of which
# have not been verified or tested in over a decade) and for many of the
# libraries formerly delivered in the X.Org monolithic releases.
#
# Home page: https://www.x.org/archive/individual/util/
# Download:  https://www.x.org/archive/individual/util/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
