#! /bin/bash

PRGNAME="taglib"

### Taglib (audio meta-data library)
# Удобная аудиобиблиотека, предназначенная для чтения и редактирования
# метаданных и тегов внутри музыкальных файлов. Поддерживает все популярные
# форматы вроде MP3, FLAC и OGG. Используется такими приложениями как VLC.

# Required:    cmake
#              utfcpp
# Recommended: no
# Optional:    cppunit    (для тестов) https://freedesktop.org/wiki/Software/cppunit/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D BUILD_SHARED_LIBS=ON      \
    .. || exit 1

make || exit 1
# для тестов требуется пакет cppunit
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (audio meta-data library)
#
# TagLib is a library for reading and editing the meta-data of several popular
# audio formats. Currently it supports both ID3v1 and ID3v2 for MP3 files, Ogg
# Vorbis comments and ID3 tags and Vorbis comments in FLAC files. It's used by
# applications such as Amarok and VLC.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
