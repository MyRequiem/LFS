#! /bin/bash

PRGNAME="libao"

### Libao (Audio Output library)
# Кроссплатформенная аудиобиблиотека, которая требуется многим программам и
# другим библиотекам, которые используют аудио форматы ogg123, GAIM, Ogg и др.
# Пакет содержит плагины для файлов WAV, OSS, ESD, NAS, aRts, ALSA и
# PulseAudio.

# Required:    no
# Recommended: no
# Optional:    Graphical Environments
#              alsa-lib
#              pulseaudio

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим ошибку сборки с gcc>=14
sed -i '/limits.h/a #include <time.h>' src/plugins/pulse/ao_pulse.c || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Audio Output library)
#
# Libao is a cross-platform audio library which required by many programs and
# other libraries that use audio. Some examples include ogg123, GAIM, Ogg
# Vorbis libraries. This package provides plugins for WAV files, OSS (Open
# Sound System), ESD (Enlighten Sound Daemon), NAS (Network Audio system), aRts
# (analog Real-Time Synthesizer), ALSA (Advanced Linux Sound Architecture) and
# PulseAudio (next generation GNOME sound architecture). You will need to
# install the supporting libraries for any plugins you want to use.
#
# Home page: https://www.xiph.org/ao/
# Download:  https://downloads.xiph.org/releases/ao/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
