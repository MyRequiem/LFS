#! /bin/bash

PRGNAME="pamixer"

### pamixer (pulseaudio command line mixer)
# Удобная консольная утилита для управления громкостью звука в системе
# PulseAudio. Она позволяет менять громкость или отключать звук для конкретных
# приложений через простые команды в терминале.

# Required:    pulseaudio
#              cxxopts
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
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (pulseaudio command line mixer)
#
# pamixer is a console based mixer for pulseaudio. It can adjust the volume
# levels of the audio sinks.
#
# Home page: https://github.com/cdemoulins/${PRGNAME}
# Download:  https://github.com/MyRequiem/LFS/raw/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
