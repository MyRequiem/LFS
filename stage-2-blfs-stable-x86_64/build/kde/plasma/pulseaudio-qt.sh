#! /bin/bash

PRGNAME="pulseaudio-qt"

### pulseaudio-qt (PulseAudio Qt bindings)
# Qt оболочка для PulseAudio

# Required:    kde-frameworks
#              pulseaudio
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                \
    -D CMAKE_INSTALL_PREFIX=/usr     \
    -D CMAKE_PREFIX_PATH="${QT6DIR}" \
    -D CMAKE_SKIP_INSTALL_RPATH=ON   \
    -D CMAKE_BUILD_TYPE=Release      \
    -D BUILD_TESTING=OFF             \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PulseAudio Qt bindings)
#
# This package is a Qt-style wrapper for PulseAudio. It allows querying and
# manipulation of various PulseAudio objects such as Sinks, Sources and
# Streams. It does not wrap the full feature set of libpulse
#
# Home page: https://github.com/KDE/${PRGNAME}
# Download:  https://download.kde.org/stable/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
