#! /bin/bash

PRGNAME="opus"

### Opus (Audio Codec)
# Универсальный аудиокодек, стандартизированный Internet Engineering Task Force
# (IETF). Кодек особенно подходит для интерактивной передачи речи и звука через
# Интернет.

# Required:    no
# Recommended: no
# Optional:    --- для документации ---
#              doxygen
#              texlive or install-tl-unx

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

API_DOCS="--disable-doc"

./configure          \
    --prefix=/usr    \
    --disable-static \
    "${API_DOCS}"    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Audio Codec)
#
# Opus is a totally open, royalty-free, highly versatile audio codec. It is
# standardized by the Internet Engineering Task Force (IETF) and is
# particularly suitable for interactive speech and audio transmission over the
# Internet.
#
# Home page: https://${PRGNAME}-codec.org/
# Download:  https://archive.mozilla.org/pub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
