#! /bin/bash

PRGNAME="alsa-oss"

### alsa-oss (library/wrapper to use OSS programs with ALSA)
# OSS - это старая звуковая система для Linux, которую заменила ALSA. С ее
# помощью можно использовать программы, которые поддерживают только OSS с ALSA
# без необходимости загружать OSS модули ядра.

# Required:    alsa-lib
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library/wrapper to use OSS programs with ALSA)
#
# The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI
# functionality to the Linux operating system.  OSS (Open Sound System) is an
# older sound system for Linux that ALSA is replacing.  Using the aoss wrapper
# you can use programs that only support OSS with ALSA without having to load
# the OSS compatibility kernel modules.
#
# Home page: https://www.alsa-project.org/
# Download:  https://www.alsa-project.org/files/pub/oss-lib/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
