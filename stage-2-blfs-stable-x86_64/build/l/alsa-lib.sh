#! /bin/bash

PRGNAME="alsa-lib"

### alsa-lib (Advanced Linux Sound Architecture library)
# Библиотеки обеспечивающие аудио и MIDI функциональность в Linux

# Required:    no
# Recommended: elogind
# Optional:    doxygen
#              python2    (https://www.python.org/downloads/release/python-2718/)

### Конфигурация ядра
#    CONFIG_SOUND=y|m
#    CONFIG_SND=y|m

### Конфиги
#    /etc/asound.conf
#    ~/.asoundrc
#
# см. http://www.alsa-project.org/main/index.php/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

# удалим тест, который не проходит с gcc>=15
sed 's/playmidi1//' -i test/Makefile.am && \
    autoreconf -fi

./configure || exit 1
make        || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# конфигурационные файлы
tar -C "${TMP_DIR}/usr/share/alsa" --strip-components=1 \
    -xf "${SOURCES}/alsa-ucm-conf-${VERSION}.tar.bz2" || exit 1

ASOUND_CONF="/etc/asound.conf"
cat << EOF > "${TMP_DIR}${ASOUND_CONF}"
# ALSA system-wide config file
# By default, redirect to PulseAudio:
pcm.default pulse
ctl.default pulse
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Advanced Linux Sound Architecture library)
#
# The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI
# functionality to the Linux operating system. Package contains the ALSA
# library (libasound) used by programs (including ALSA Utilities) requiring
# access to the ALSA sound interface.
#
# Home page: https://alsa-project.org
# Download:  https://www.alsa-project.org/files/pub/lib/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
