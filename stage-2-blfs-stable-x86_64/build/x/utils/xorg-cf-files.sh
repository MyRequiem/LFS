#! /bin/bash

PRGNAME="xorg-cf-files"

### xorg-cf-files (X11 config files for imake)
# Файлы данных для утилиты imake, определяющие настройки для самых разных
# платформ и библиотек.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
# Download:  https://www.x.org/archive/individual/util/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
