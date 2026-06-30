#! /bin/bash

PRGNAME="alsa-plugins"

### alsa-plugins (Advanced Linux Sound Architecture Plugins)
# Набор дополнений (плагинов), которые расширяют возможности стандартной
# звуковой системы ALSA. Они позволяют программно изменять звук, смешивать
# потоки от разных приложений и выводить аудио через современные звуковые
# серверы.

# Required:    alsa-lib
# Recommended: no
# Optional:    ffmpeg
#              libsamplerate
#              pulseaudio
#              speex
#              jack             (https://jackaudio.org/)
#              libavtp          (https://github.com/AVnu/libavtp/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Advanced Linux Sound Architecture Plugins)
#
# The ALSA Plugins package contains plugins for various audio libraries and
# sound servers
#
# Home page: https://www.alsa-project.org/
# Download:  https://www.alsa-project.org/files/pub/plugins/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
