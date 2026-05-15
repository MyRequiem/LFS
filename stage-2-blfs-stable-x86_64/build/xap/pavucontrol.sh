#! /bin/bash

PRGNAME="pavucontrol"

### pavucontrol (PulseAudio Volume Controller)
# Графический звуковой микшер для PulseAudio на основе GTK. Позволяет отдельно
# настраивать громкость для каждого приложения, перенаправлять звук на разные
# колонки или наушники, а также управлять микрофонами.

# Required:    gtkmm4
#              json-glib
#              libsigc++3
#              pulseaudio
# Recommended: no
# Optional:    libcanberra
#              lynx             (для создания README файла)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D lynx=disabled || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PulseAudio Volume Controller)
#
# It is a simple GTK based volume control tool("mixer") for PulseAudio sound
# server. In contrast to classic mixer tools, this one allows you to control
# both the volume of hardware devices and of each playback stream separately.
#
# Home page: https://freedesktop.org/software/pulseaudio/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/pulseaudio/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
