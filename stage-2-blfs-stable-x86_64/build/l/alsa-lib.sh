#! /bin/bash

PRGNAME="alsa-lib"

### alsa-lib (Advanced Linux Sound Architecture library)
# Библиотеки обеспечивающие аудио и MIDI функциональность в Linux

# Required:    no
# Recommended: no
# Optional:    doxygen
#              python2

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
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

API_DOCS="false"
# command -v doxygen &>/dev/null && API_DOCS="true"

./configure || exit 1
make || exit 1

if [[ "x${API_DOCS}" == "xtrue" ]]; then
    make doc || exit 1
fi

# make check

make install DESTDIR="${TMP_DIR}"

if [[ "x${API_DOCS}" == "xtrue" ]]; then
    DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -d -m755 "${TMP_DIR}${DOC_PATH}/html/search"

    install -v -m644 doc/doxygen/html/*.* \
        "${TMP_DIR}${DOC_PATH}/html"
    install -v -m644 doc/doxygen/html/search/* \
        "${TMP_DIR}${DOC_PATH}/html/search"
fi

ASOUND_CONF="/etc/asound.conf"
cat << EOF > "${TMP_DIR}${ASOUND_CONF}"
# ALSA system-wide config file
# By default, redirect to PulseAudio:
pcm.default pulse
ctl.default pulse
EOF

if [ -f "${ASOUND_CONF}" ]; then
    mv "${ASOUND_CONF}" "${ASOUND_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${ASOUND_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Advanced Linux Sound Architecture library)
#
# The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI
# functionality to the Linux operating system. Package contains the ALSA
# library (libasound) used by programs (including ALSA Utilities) requiring
# access to the ALSA sound interface.
#
# Home page: http://alsa-project.org
# Download:  https://www.alsa-project.org/files/pub/lib/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
