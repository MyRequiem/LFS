#! /bin/bash

PRGNAME="sbc"

### SBC (Sub Band Codec for bluetooth audio output)
# Цифровой аудиокодер/декодер, используемый для передачи данных в устройства
# вывода звука Bluetooth (наушники, колонки)

# Required:    no
# Recommended: no
# Optional:    libsndfile

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
# Package: ${PRGNAME} (Sub Band Codec for bluetooth audio output)
#
# The SBC is a digital audio encoder and decoder used to transfer data to
# Bluetooth audio output devices like headphones or loudspeakers.
#
# Home page: https://www.kernel.org/pub/linux/bluetooth
# Download:  https://www.kernel.org/pub/linux/bluetooth/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
