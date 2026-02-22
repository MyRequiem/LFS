#! /bin/bash

PRGNAME="phonon"

### Phonon (multimedia framework for KDE)
# Мультимедийный API для KDE

# Required:    cmake
#              extra-cmake-modules
#              glib
#              qt6
# Recommended: no
# Optional:    pulseaudio

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D PHONON_BUILD_QT5=OFF      \
    -W no-dev                    \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (multimedia framework for KDE)
#
# Phonon is the multimedia API for KDE. It replaces the old aRts package.
# Phonon needs the VLC backend
#
# Home page: https://www.${PRGNAME}.io/
# Download:  https://download.kde.org/stable/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
