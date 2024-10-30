#! /bin/bash

PRGNAME="pavucontrol"

### pavucontrol (PulseAudio Volume Controller)
# Звуковой микшер для PulseAudio на основе GTK. В отличие от классических
# микшеров, pavucontrol позволяет контролировать как громкость аппаратных
# устройств, так и громкость каждого потока воспроизведения в отдельности.

# Required:    gtkmm
#              json-glib
#              libcanberra
#              libsigc++2
#              pulseaudio
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PulseAudio Volume Controller)
#
# It is a simple GTK based volume control tool("mixer") for PulseAudio sound
# server. In contrast to classic mixer tools, this one allows you to control
# both the volume of hardware devices and of each playback stream separately.
#
# Home page: https://freedesktop.org/software/pulseaudio/${PRGNAME}/
# Download:  http://freedesktop.org/software/pulseaudio/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
