#! /bin/bash

PRGNAME="libdvdnav"

### Libdvdnav (DVD Navigation Library)
# Библиотека, которая позволяет легко использовать сложную навигацию по DVD
# (меню DVD, многоугольное воспроизведение и даже интерактивные DVD игры)

# Required:    libdvdread
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (DVD Navigation Library)
#
# libdvdnav is a library that allows easy use of sophisticated DVD navigation
# features such as DVD menus, multiangle playback and even interactive DVD
# games
#
# Home page: https://www.videolan.org/
# Download:  https://get.videolan.org/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
